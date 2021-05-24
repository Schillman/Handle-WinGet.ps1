$Apps = @(
    'Discord.Discord'
    'Git.Git'
    'Microsoft.AzureCLI'
    'Microsoft.PowerShell-Preview'
    'Microsoft.Teams'
    #'Microsoft.VisualStudioCode'
    'Mozilla.FireFox'
    'Python.Python'
    'SlackTechnologies.Slack'
    'soroushchehresa.unsplash-wallpapers'
    'Yubico.Authenticator'
    #'Yubico.YubikeyManager'
)

function Handle-WinGet {
<#
.Synopsis
   A way to install/upgrade or Uninstall Apps utilising WinGet
.EXAMPLE
   The following example upgrades all apps located in the object "$Apps" and also configures the WinGet settings to my preferd settings. 
    Handle-WinGet -Trigger Upgrade -Apps $Apps -ConfigureSettings
.EXAMPLE
    The following example will ask you for a trigger input. Either Install, Upgrade or Uninstall and then apply command/trigger accordingly.
    Handle-WinGet -Apps $Apps
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,
            Position = 0)]
        $Apps,

        [Parameter(Mandatory,
            Position = 1)]
        [ValidateSet('install','upgrade','uninstall',IgnoreCase)]
        [string]
        $Trigger,

        [Parameter(Mandatory = $false,
            Position = 2)]
        [switch]
        $ConfigureSettings
    )
    "`n`n" # Moving Down the output. Makes it possible to see the output.
    $error.Clear()
    $EAPref = $ErrorActionPreference
    $ErrorActionPreference = 'SilentlyContinue'
    $ControlWinGet = WinGet --version
    if ($error -or $ControlWinGet -notlike 'v*') {
        return 'WinGet missing'
    }
    $ErrorActionPreference = $EAPref

    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        $choice = $null
        Write-Warning 'For best experience run this script as admin'
        while ($choice -notmatch 'y|n') {
            $choice = Read-Host 'Do you want to continue anyway? [y/n]'
        }
        if ($choice -eq 'n') {
            Write-Output 'Quiting... Feel free to run the code as admin for best experiance' ; Start-Sleep 5 ; return
        }
    }

    if ($ConfigureSettings.IsPresent) {
        $LocationPath = (WinGet --info | Select-String 'Logs:') -replace 'Logs: ', ''
        if ($LocationPath -like '%LOCALAPPDATA%*') {
            $LocationPath = (Split-Path (($LocationPath -replace '%LOCALAPPDATA%', $env:LOCALAPPDATA))) + '\settings.json'
        } else {
            return 'WinGet Settings file not found'
        }
        Write-Verbose "Setting WinGet config`n$LocationPath"
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
        
        $Settings | Set-Content -Path ((Split-Path $LocationPath) + '\settings.json')
    }

    $Total = $Apps.Count
    $Count = 0
    $Apps.ForEach( {
            $_
            $Count++
            $percentComplete = ($Count / $Total) * 100
            Write-Progress -Activity "Running '$Trigger' for $_ - [$Count/$Total]..." -CurrentOperation $_ -PercentComplete $percentComplete -Status $Count
            WinGet $Trigger --name "$_" --exact --silent
        })
}

Handle-WinGet -Apps $Apps -ConfigureSettings