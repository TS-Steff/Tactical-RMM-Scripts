<#
.SYNOPSIS
    Set Windows Patches to Ignore by KB Number
    This will automatically be ran on every Agent

.REQUIREMENTS
    - You will need an API key from Tactical RMM which should be passed as parameters (DO NOT hard code in script). Do not run this on each agent (see notes).

.NOTES
    - This scirpt is designed to ron on a single computer. Ideally, it should be run on the Tactical RMM server or other trusted device.
    - This script sycles through each agent setting given KB to ignore
    - KB2267602 is Windows Defender Update

.PARAMETERS
    - $ApiKeyTactical   - Tactical API Key
    - $ApiUrlTactical   - Tactical API Url
    - $WinKBtoIgnore    - KBs to ignore

.EXAMPLE
    - Win_KB_Ignore_ByKB.ps1 -ApiKeyTactical 1234567 -ApiUrlTactical api.yourdomain.com -$WinKBtoIgnore 2267602,2267603

.VERSION
    - V1.0 Initial Release by TS-Management GmbH | https://ts-man.ch | https://github.com/TS-Steff/Tactical-RMM-Scripts
#>

param(
    [string] $ApiKeyTactical,
    [string] $ApiUrlTactical,
    [string[]] $WinKBtoIgnore=$()
)

if ([string]::IsNullOrEmpty($ApiKeyTactical)) {
    throw "ApiKeyTactical must be defined. Use -ApiKeyTactical <value> to pass it."
}

if ([string]::IsNullOrEmpty($ApiUrlTactical)) {
    throw "ApiUrlTactical must be defined. Use -ApiUrlTactical <value> to pass it."
}

if ([string]::IsNullOrEmpty($WinKBtoIgnore)){
    throw "WinKBtoIgnore must be defined. Use -WinKBtoIgnore <value>,<value> to pass it."
}

$headers= @{
    'X-API-KEY' = $ApiKeyTactical
}

# Get all agents
try {
    $agentsResult = Invoke-RestMethod -Method 'Get' -Uri "https://$ApiUrlTactical/agents" -Headers $headers -ContentType "application/json"
}
catch {
    throw "Error invoking get all agents on Tactical RMM with error: $($PSItem.ToString())"
}

foreach ($agents in $agentsResult){

    $agentId        = $agents.agent_id
    $agentHostname  = $agents.hostname

    # Get agent updates
    try {
        $agentUpdateResult = Invoke-RestMethod -Method 'Get' -Uri "https://$ApiUrlTactical/winupdate/$agentId/" -Headers $headers -ContentType "application/json"
    }
    catch {
        Write-Error "Error invoking winupdate on agent $agentHostname - $agentId with error: $($PSItem.ToString())"
    }

    foreach ($update in $agentUpdateResult){
        $updateId       = $update.id
        $updateKb       = $update.kb
        $updateAction   = $update.action
        $updateTitle    = $update.title

        foreach ($KBIgnore in $WinKBtoIgnore){
            if($KBIgnore -eq $update.kb){
                #write-host "$KBIgnore found for Host $agentHostname" -ForegroundColor Green
                
                # Set Ignore KB
                $body = @{
                    "action"   = "ignore"
                }
                try {
                    $updateIgnoreKb = Invoke-RestMethod -Method 'Put' -Uri "https://$ApiUrlTactical/winupdate/$updateId/" -Body ($body|ConvertTo-Json) -Headers $headers -ContentType "application/json"
                    Write-Host "Agent $agentHostname toggling ignore of $updateKB"
                }
                catch {
                    Write-Error "Error invoking Ignore KB on agent $agentHostname - $agentId with error: $($PSItem.ToString())"
                }

            }
        }
        #write-host $update.kb
    }
}