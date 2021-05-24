$Apps = @(
    'Discord.Discord'
    'Git.Git'
    'Microsoft.AzureCLI'
    'Microsoft.PowerShell-Preview'
    'Microsoft.Teams'
    'Microsoft.VisualStudioCode'
    'Mozilla.FireFox'
    'SlackTechnologies.Slack'
    'soroushchehresa.unsplash-wallpapers'
    'Yubico.Authenticator'
    #'Yubico.YubikeyManager'
)

function Handle-WinGet {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
        $Apps,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            Position = 1)]
        [ValidateSet('install', 'upgrade', 'uninstall')]
        [string]
        $Trigger,

        [Parameter(Mandatory,
            ValueFromPipelineByPropertyName = $true,
            Position = 2)]
        [switch]
        $Configure
    )

    $error.Clear()
    $EAPref = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    $ControlWinGet = winget --version
    if ($error -or $ControlWinGet -notlike 'v*') {
        return 'WinGet missing'
    }
    $ErrorActionPreference = $EAPref

    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $choice = $null
        Write-Warning 'For best experience run this script as admin'
        while ($choice -notmatch 'y|n') {
            $choice = Read-Host 'Do you want to continue anyway?'
        }
        if ($choice -eq 'n') {
            Write-Output 'Quiting... Feel free to run the code as admin for best experiance' ; Start-Sleep 5 ; return
        }
    }

    if ($Configure) {
        $Settings = @"
{
    "`$schema": "https://aka.ms/winget-settings.schema.json",
    // For documentation on these settings, see: https://aka.ms/winget-settings
    "source": {
        "autoUpdateIntervalInMinutes": 360
    },
    "experimentalFeatures": {
        "uninstall": true,
        "upgrade": true,
        "list": true,
        "experimentalMSStore": true
    },
    "visual": {
        "progressBar": "rainbow"
    },
    "installBehavior": {
        "preferences": {
        "locale": [
            "en-US",
            "sv-SE"
        ]
        }
    },
    "telemetry": {
        "disable": true
    }
}
"@

        $LocationPath = (winget --info | Select-String 'Logs:') -replace 'Logs: ', ''
        if ($LocationPath -like '%LOCALAPPDATA%*') { $LocationPath = $LocationPath -replace '%LOCALAPPDATA%', $env:LOCALAPPDATA } else { return 'Winget Settings file not found' }
        $Settings | Set-Content -Path ((Split-Path $LocationPath) + '\settings.json')
    }

    $Total = $Apps.Count
    $Count = 0
    $Apps.ForEach( {
            $count++
            $percentComplete = ($Count / $Total) * 100
            Write-Progress -Activity "Currently installing [$Count/$Total]..." -CurrentOperation $_ -PercentComplete $percentComplete -Status $Count
            $null = winget $Trigger $_ --silent
        })
}

Handle-WinGet -Apps $Apps -Trigger