# create-contact-jotform.ps1
# Creates the Aspire Veterinary Hospital contact form in JotForm using DE's API workflow:
#   1. POST /form to create the form with questions
#   2. POST /form/{FORM_ID}/properties to set practice-notification + client-autoresponder emails
#
# After this runs, paste the printed Form ID + question IDs back into Cowork.
#
# Run: .\create-contact-jotform.ps1

$ErrorActionPreference = 'Stop'

# --- DE JotForm credentials ---
$apiKey = '2936c2dbafb9bec4a92867a347c1b18d'

# --- Practice details ---
$practiceName    = 'Aspire Veterinary Hospital'
$practiceEmail   = 'info@aspirevethospital.com'
$practicePhone   = '301-366-0040'
$practiceAddress = '14112 Darnestown Road, Germantown, MD 20874'
$practiceHours   = 'Mon-Fri 8am-6pm, Sat 9am-1pm, Closed Sunday'
$formTitle       = "$practiceName - Contact Form"

# ====================================================================================
# STEP 1 - Create the form + questions
# ====================================================================================

Write-Host "Step 1: Creating form via POST /form..." -ForegroundColor Cyan

$createBody = @{
  'properties[title]'    = $formTitle
  'properties[height]'   = '600'

  # Q1 - Full Name (short text)
  'questions[1][type]'     = 'control_textbox'
  'questions[1][text]'     = 'Full Name'
  'questions[1][order]'    = '1'
  'questions[1][name]'     = 'fullName'
  'questions[1][required]' = 'Yes'

  # Q2 - Email
  'questions[2][type]'     = 'control_email'
  'questions[2][text]'     = 'Email'
  'questions[2][order]'    = '2'
  'questions[2][name]'     = 'email'
  'questions[2][required]' = 'Yes'

  # Q3 - Phone
  'questions[3][type]'     = 'control_phone'
  'questions[3][text]'     = 'Phone'
  'questions[3][order]'    = '3'
  'questions[3][name]'     = 'phone'
  'questions[3][required]' = 'Yes'

  # Q4 - Pet Name (optional)
  'questions[4][type]'     = 'control_textbox'
  'questions[4][text]'     = 'Pet Name'
  'questions[4][order]'    = '4'
  'questions[4][name]'     = 'petName'
  'questions[4][required]' = 'No'

  # Q5 - Reason for Contact (dropdown)
  'questions[5][type]'     = 'control_dropdown'
  'questions[5][text]'     = 'Reason for Contact'
  'questions[5][order]'    = '5'
  'questions[5][name]'     = 'reasonForContact'
  'questions[5][options]'  = 'General Question|New Client Inquiry|Appointment Request|Prescription Refill|Medical Records Request|Feedback|Other'
  'questions[5][required]' = 'Yes'

  # Q6 - Message (long text)
  'questions[6][type]'     = 'control_textarea'
  'questions[6][text]'     = 'Message'
  'questions[6][order]'    = '6'
  'questions[6][name]'     = 'message'
  'questions[6][required]' = 'Yes'
}

try {
  $createResp = Invoke-RestMethod `
    -Uri "https://api.jotform.com/form?apiKey=$apiKey" `
    -Method Post `
    -Body $createBody `
    -ContentType 'application/x-www-form-urlencoded'
}
catch {
  Write-Host "POST /form failed:" -ForegroundColor Red
  Write-Host $_.Exception.Message -ForegroundColor Red
  if ($_.ErrorDetails) { Write-Host $_.ErrorDetails.Message -ForegroundColor Red }
  exit 1
}

if ($createResp.responseCode -ne 200) {
  Write-Host "JotForm returned an error:" -ForegroundColor Red
  $createResp | ConvertTo-Json -Depth 6 | Write-Host
  exit 1
}

$formId = $createResp.content.id
Write-Host "  Form created. ID = $formId" -ForegroundColor Green

# ====================================================================================
# STEP 2 - Fetch the question IDs (qids) so we can reference them in the emails
# ====================================================================================

Write-Host "Step 2: Fetching question IDs..." -ForegroundColor Cyan

$questionsResp = Invoke-RestMethod -Uri "https://api.jotform.com/form/$formId/questions?apiKey=$apiKey" -Method Get
if ($questionsResp.responseCode -ne 200) {
  Write-Host "Could not fetch questions:" -ForegroundColor Red
  $questionsResp | ConvertTo-Json -Depth 6 | Write-Host
  exit 1
}

# Build a name -> qid map (e.g. fullName -> 1, email -> 2, ...).
$nameToQid = @{}
$qidsByName = [ordered]@{}
foreach ($prop in $questionsResp.content.PSObject.Properties) {
  $q = $prop.Value
  if ($q.name) {
    $nameToQid[$q.name] = $q.qid
    $qidsByName[$q.name] = "q$($q.qid)_$($q.name)"
  }
}

Write-Host "  Question IDs:" -ForegroundColor Green
$qidsByName.GetEnumerator() | Sort-Object { [int]$nameToQid[$_.Key] } | ForEach-Object {
  Write-Host ("    {0,-20} -> {1}" -f $_.Key, $_.Value) -ForegroundColor Green
}

# ====================================================================================
# STEP 3 - Build the email bodies + set them via POST /form/{id}/properties
# ====================================================================================

Write-Host "Step 3: Configuring emails (notification + autoresponder)..." -ForegroundColor Cyan

# Substitution tokens use the form `{questionName}` (JotForm replaces them with submitted values)
$qFull   = '{fullName}'
$qEmail  = '{email}'
$qPhone  = '{phone}'
$qPet    = '{petName}'
$qReason = '{reasonForContact}'
$qMsg    = '{message}'

# --- Practice notification email ---
$notificationSubject = "New Contact Form Submission: $qReason - $qFull"

$notificationHtml = @"
<div style="font-family: Arial, sans-serif; color:#333333; max-width:600px;">
  <h2 style="color:#2F4157; font-family: Georgia, serif; margin:0 0 12px;">New Contact Form Submission</h2>
  <p style="color:#808080; margin:0 0 18px;">A new message just came in from the website.</p>

  <table cellpadding="10" cellspacing="0" style="width:100%; border-collapse:collapse; background:#F9F7F4;">
    <tr><td style="font-weight:bold; width:40%; border-bottom:1px solid #ECE6DF;">Full Name</td><td style="border-bottom:1px solid #ECE6DF;">$qFull</td></tr>
    <tr><td style="font-weight:bold; border-bottom:1px solid #ECE6DF;">Email</td><td style="border-bottom:1px solid #ECE6DF;">$qEmail</td></tr>
    <tr><td style="font-weight:bold; border-bottom:1px solid #ECE6DF;">Phone</td><td style="border-bottom:1px solid #ECE6DF;">$qPhone</td></tr>
    <tr><td style="font-weight:bold; border-bottom:1px solid #ECE6DF;">Pet Name</td><td style="border-bottom:1px solid #ECE6DF;">$qPet</td></tr>
    <tr><td style="font-weight:bold; border-bottom:1px solid #ECE6DF;">Reason</td><td style="border-bottom:1px solid #ECE6DF;">$qReason</td></tr>
    <tr><td style="font-weight:bold; vertical-align:top;">Message</td><td style="white-space:pre-wrap;">$qMsg</td></tr>
  </table>

  <p style="font-size:12px; color:#999999; margin-top:24px;">$practiceName - submitted via aspirevethospital.com</p>
</div>
"@

# --- Client confirmation autoresponder ---
$autoSubject = "We received your message - $practiceName"

$autoHtml = @"
<div style="font-family: Arial, sans-serif; color:#333333; max-width:600px; line-height:1.5;">
  <h2 style="color:#B3977B; font-family: Georgia, serif; margin:0 0 12px;">Thank you, $qFull.</h2>
  <p>We received your message and a member of our team will reach out within one business day during our regular hours.</p>

  <p style="margin:18px 0 6px; font-weight:bold; color:#2F4157;">Here is a copy of what you sent us:</p>
  <table cellpadding="8" cellspacing="0" style="width:100%; border-collapse:collapse; background:#F9F7F4; font-size:14px;">
    <tr><td style="font-weight:bold; width:40%; border-bottom:1px solid #ECE6DF;">Reason</td><td style="border-bottom:1px solid #ECE6DF;">$qReason</td></tr>
    <tr><td style="font-weight:bold; border-bottom:1px solid #ECE6DF;">Pet Name</td><td style="border-bottom:1px solid #ECE6DF;">$qPet</td></tr>
    <tr><td style="font-weight:bold; vertical-align:top;">Message</td><td style="white-space:pre-wrap;">$qMsg</td></tr>
  </table>

  <div style="background:#FFF4E5; border-left:3px solid #B3977B; padding:14px 18px; margin:24px 0; border-radius:4px;">
    <strong style="color:#2F4157;">Medical emergency?</strong>
    Please call us directly at <a href="tel:$practicePhone" style="color:#2F4157;">$practicePhone</a> or visit your nearest emergency veterinary hospital. This contact form is not monitored after hours.
  </div>

  <hr style="border:0; border-top:1px solid #ECE6DF; margin:28px 0;">

  <div style="font-size:13px; color:#808080; line-height:1.6;">
    <strong style="color:#2F4157;">$practiceName</strong><br>
    $practiceAddress<br>
    Phone: <a href="tel:$practicePhone" style="color:#808080;">$practicePhone</a><br>
    Hours: $practiceHours
  </div>
</div>
"@

# Build the emails array as JSON and send it via POST /form/{id}/properties
$emailsArray = @(
  @{
    type    = 'notification'
    name    = 'Practice Notification'
    from    = 'noreply@jotform.com'
    to      = $practiceEmail
    subject = $notificationSubject
    html    = 'Yes'
    body    = $notificationHtml
  },
  @{
    type    = 'autoresponder'
    name    = 'Client Confirmation'
    from    = 'noreply@jotform.com'
    to      = $qEmail
    replyTo = $practiceEmail
    subject = $autoSubject
    html    = 'Yes'
    body    = $autoHtml
  }
)

$emailsJson = $emailsArray | ConvertTo-Json -Depth 6 -Compress

try {
  $propsResp = Invoke-RestMethod `
    -Uri "https://api.jotform.com/form/$formId/properties?apiKey=$apiKey" `
    -Method Post `
    -Body @{ 'properties[emails]' = $emailsJson } `
    -ContentType 'application/x-www-form-urlencoded'
}
catch {
  Write-Host "Setting emails via /form/$formId/properties failed:" -ForegroundColor Red
  Write-Host $_.Exception.Message -ForegroundColor Red
  if ($_.ErrorDetails) { Write-Host $_.ErrorDetails.Message -ForegroundColor Red }
  exit 1
}

if ($propsResp.responseCode -ne 200) {
  Write-Host "JotForm returned an error setting emails:" -ForegroundColor Red
  $propsResp | ConvertTo-Json -Depth 6 | Write-Host
  exit 1
}

Write-Host "  Emails configured." -ForegroundColor Green

# ====================================================================================
# FINAL OUTPUT
# ====================================================================================

$formUrl     = "https://form.jotform.com/$formId"
$builderUrl  = "https://www.jotform.com/build/$formId"
$submitUrl   = "https://submit.jotform.com/submit/$formId"

Write-Host ""
Write-Host "==============================================================" -ForegroundColor Green
Write-Host "DONE" -ForegroundColor Green
Write-Host "==============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "Form ID:      $formId"
Write-Host "Builder URL:  $builderUrl"
Write-Host "Public URL:   $formUrl"
Write-Host "Submit URL:   $submitUrl"
Write-Host ""
Write-Host "Field names for custom HTML form (use these as the name attr on inputs):"
$qidsByName.GetEnumerator() | Sort-Object { [int]$nameToQid[$_.Key] } | ForEach-Object {
  Write-Host ("  {0,-22} -> name=`"{1}`"" -f $_.Key, $_.Value)
}
Write-Host ""
Write-Host "Emails configured:"
Write-Host "  Practice notification -> $practiceEmail"
Write-Host "  Client autoresponder  -> form submitter (replyTo: $practiceEmail)"
Write-Host ""
Write-Host "REMINDER:" -ForegroundColor Yellow
Write-Host "  Open the builder URL above, go to Settings -> Emails, and update the sender name"
Write-Host "  from 'Jotform' to '$practiceName' on both emails. The API does not allow writing"
Write-Host "  the 'from name' field, so this must be done manually in the dashboard." -ForegroundColor Yellow
Write-Host ""
Write-Host "Then paste the Form ID and the field names list back into Cowork chat and I will wire"
Write-Host "the custom HTML form into src/pages/contact.astro." -ForegroundColor Cyan
Write-Host ""
