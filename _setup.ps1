$baseConfigDir = "C:\config\"
$coreProfileName = "core"


$profileData = Get-Content -Raw -Path $($baseConfigDir + "profiles.json") | ConvertFrom-Json

function Install-Packages($packages){
    
    Write-Host "Installing packages" -ForegroundColor Yellow
    
    foreach($pkg in $packages){
            Write-Host "Installing" $pkg -ForegroundColor Yellow
            Write-Host
            winget install $pkg
            Write-Host
            Write-Host "Installed" $pkg -ForegroundColor Green
    }

    Write-Host "Finished installing packages!" -ForegroundColor Green
}

function Add-StartupFiles($files){
    
    Write-Host "Adding startup files" -ForegroundColor Yellow

    $Shell = New-Object -ComObject ("WScript.Shell")

    foreach($file in $files){
            Write-Host "Adding file to startup" $file -ForegroundColor Yellow
            
            $splitName = $file -split "/"
            $fileName = $splitName[$splitName.Count - 1]
            
            $ShortCut = $Shell.CreateShortcut($env:USERPROFILE + "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\" + $fileName + ".lnk")
            $ShortCut.TargetPath=$baseConfigDir + $file
            $ShortCut.Save()
            
            Write-Host "Installed to startup" $file -ForegroundColor Green
    }

    Write-Host "Finished adding startup files!" -ForegroundColor Green
}

function Set-PowershellProfile($fileName){
    
    Write-Host "Setting PowerShell profile" -ForegroundColor Yellow

    if($fileName){
        Set-Content -Path $profile -Value $('. ' +  $baseConfigDir + $fileName)
    }
    else{
        Set-Content -Path $profile -Value $('. ' +  $baseConfigDir + 'psprofile.ps1')    
    }

    Write-Host "PowerShell profile setup!" -ForegroundColor Green
}


Write-Host
Write-Host "========= SETUP SCRIPT =========" -ForegroundColor Yellow 
Write-Host
Write-Host "Available Profiles:"
foreach($p in $profileData){
    Write-Host $p.name
}
Write-Host

$profilesRaw = Read-Host -Prompt "Profiles to setup"

$runningProfiles = [System.Collections.ArrayList]@($profilesRaw -split ",")
$runningProfiles += $coreProfileName

$psProfileSet = $false

foreach($p in $profileData){
    if($runningProfiles -contains $p.name){
        Write-Host 
        Write-Host "== Running" $p.name -ForegroundColor Yellow
        Write-Host

        if($psProfileSet -eq $False -and $p.psProfile){
            Set-PowershellProfile $p.psProfile
            $psProfileSet = $true
        }
        else{
            Write-Host "Powershell profile already set / not defined in profile"
        }

        Install-Packages $p.packages

        Add-StartupFiles $p.startupFiles

        Write-Host "== Profile" $p.name "complete!" -ForegroundColor Green
    }
}


