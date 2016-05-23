# edit this file with: npp $profile
# reload profile in PowerShell with: . $profile
# get help with (including creation of ) profiles with: Get-Help about_Profiles -ShowWindow

# PSReadline goodness (Ctrl + Space makes zsh-style completion guide)
# more at https://rkeithhill.wordpress.com/2013/10/18/psreadline-a-better-line-editing-experience-for-the-powershell-console/
Import-Module PSReadline

# See all KeyHandlers with Get-PSReadlineKeyHandler
Set-PSReadlineKeyHandler -Key Ctrl+P -Function PreviousHistory
Set-PSReadlineKeyHandler -Key Ctrl+N -Function NextHistory
Set-PSReadlineKeyHandler -Key Ctrl+U -Function BackwardDeleteLine

# Load posh-git example profile
. 'C:\Users\Ben\Documents\WindowsPowerShell\Modules\posh-git\profile.example.ps1'

Set-Alias npp "C:\Program Files (x86)\Notepad++\notepad++.exe"

Set-Alias msbuild "C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe"

# override profile
Set-Variable -Force PROFILE $MyInvocation.MyCommand.Path

Set-Variable CurrentProject "E:\Git Repos\Bens-Game"

# when using this, surround call with parens: if ( (Is-Admin) ) { # whatever... }
function Is-Admin() {
	If (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
	{
		return $true
	}
	return $false
}

function Set-DevPrompt() {
	#Set environment variables for Visual Studio Command Prompt
	pushd 'c:\Program Files (x86)\Microsoft Visual Studio 14.0\VC'
	cmd /c "vcvarsall.bat&set" |
	foreach {
	  if ($_ -match "=") {
		$v = $_.split("="); set-item -force -path "ENV:\$($v[0])"  -value "$($v[1])"
	  }
	}
	popd
	write-host "`nVisual Studio 2015 Command Prompt variables set." -ForegroundColor Yellow
}

function Show-Path() {($env:Path).Replace(';',"`n")}

# which from BASH. Returns the path of the program named
function which($name) {(Get-Command $name).path}

# Creates new files...
function New-File() {
	foreach ($name in $args) {
		New-Item $name -type file
	}
}

function poweroff([int]$minutes) {
	if(!$minutes) {Write-Output "Number of minutes is a required parameter"; return}
	$seconds = $minutes * 60
	$add_to_date = New-TimeSpan -Minutes $minutes
	$shutdown_date = (Get-date) + $add_to_date
	shutdown /s /t $seconds
	Write-Output "Enter shutdown /a to abort shutdown in $minutes minutes at $shutdown_date"
}

# open Admin PowerShell for choco :)
function Start-PSAdmin {Start-Process PowerShell -Verb RunAs}

#Choco Installs
function Install-Choco([string]$name, 
                       [string]$log_dir="$env:USERPROFILE\Documents\Choco_Install_Logs")
{

	if (! (Is-Admin) )
	{
		Write-Host "Run as admin!" -ForegroundColor Red
		return
	}
	$log_path = "$log_dir\$name.log"
	$date = Get-Date
	Write-Output "Date: $date" > $log_path
	# -append requires newer powershell
	choco install -y $name | Tee-Object -append -file $log_path
}
