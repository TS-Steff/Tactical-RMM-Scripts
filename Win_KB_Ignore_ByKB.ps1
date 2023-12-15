<#
.SYNOPSIS
    Set Windows Patches to Ignore by KB Number

.REQUIREMENTS
    - You will need an API key from Tactical RMM which should be passed as parameters (DO NOT hard code in script). Do not run this on each agent (see notes).

.NOTES
    - This scirpt is designed to ron on a single computer. Ideally, it should be run on the Tactical RMM server or other trusted device.
    - This script sycles through each agent setting given KB to ignore

.PARAMETERS
    - $ApiKeyTactical   - Tactical API Key
    - $ApiUrlTactical   - Tactical API Url
    - $WinKBtoIgnore    - KBs to ignore

.EXAMPLE
    - Win_KB_Ignore_ByKB.ps1 -ApiKeyTactical 1234567 -ApiUrlTactical api.yourdomain.com -$WinKBtoIgnore 2267602,2267603

.VERSION
    - V1.0 Initial Release by 
#>