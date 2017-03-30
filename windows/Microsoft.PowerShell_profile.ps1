# edit this file with: npp $profile
# reload profile in PowerShell with: . $profile
# get help with (including creation of ) profiles with: Get-Help about_Profiles -ShowWindow


# when using this, surround call with parens: if ( (Is-Admin) ) { # whatever... }
function Is-Admin() {
	If (([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
	{
		return $true
	}
	return $false
}

# open Admin PowerShell for choco :)
function Start-PSAdmin {Start-Process PowerShell -Verb RunAs}

function Install-PowerShellGoodies()
{
    # I think cmder installes GetPsGet automatically
    # (new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | iex

    Install-Module PSReadline
    # Don't forget to install git to make this work
    Install-Module posh-git
}

# NOTE: I don't think I need this anymore
function Init-PowerShellGoodies()
{
    # Install the modules if needed
    $posh_git_profile = "c:$env:HOMEPATH\Documents\WindowsPowerShell\Modules\posh-git\profile.example.ps1"

    if (Test-Path $posh_git_profile)
    {
        # If its installed, run customizations

        . $posh_git_profile

        # PSReadline goodness (Ctrl + Space makes zsh-style completion guide)
        # more at https://rkeithhill.wordpress.com/2013/10/18/psreadline-a-better-line-editing-experience-for-the-powershell-console/
        Import-Module PSReadline

        # See all KeyHandlers with Get-PSReadlineKeyHandler
        Set-PSReadlineKeyHandler -Key Ctrl+P -Function PreviousHistory
        Set-PSReadlineKeyHandler -Key Ctrl+N -Function NextHistory
        Set-PSReadlineKeyHandler -Key Ctrl+U -Function BackwardDeleteLine
    }
    else
    {
        $permission = Read-Host "Install PowerShellGoodies (yes)? "
        if ($permission.Equals("yes"))
        {
            Install-PowerShellGoodies
            Write-Host '". $PROFILE"" to load changes' -ForegroundColor blue -BackgroundColor black
            Write-Host 'My favorite tools are stored in $apps. Think about Install-All them' -ForegroundColor Cyan
        }
    }
}



# https://github.com/Microsoft/PTVS/blob/master/PowershellEnvironment.ps1
function Get-Batchfile ($file) {
    $cmd = "`"$file`" & set"
    cmd /c $cmd | Foreach-Object {
        $p, $v = $_.split('=')
        if($p -ne '') {
            Set-Item -path env:$p -value $v
        }
    }
}

function Set-VisualStudioVars32()
{
    #Scan for the most recent version of Visual Studio
    #Order:
    #   Visual Studio 2015
    #   Visual Studio 2013
    #   Visual Studio 2012
    #   Visual Studio 2010
    #
    $vscomntools = (Get-ChildItem env:VS140COMNTOOLS).Value
    if([string]::IsNullOrEmpty($vscomntools)) {
        "Visual Studio 2015 not installed, Falling back to 2013"
        $vscomntools = (Get-ChildItem env:VS120COMNTOOLS).Value
        if([string]::IsNullOrEmpty($vscomntools))
        {
            "Visual Studio 2013 not installed, Falling back to 2012"
            $vscomntools = (Get-ChildItem env:VS110COMNTOOLS).Value
            if([string]::IsNullOrEmpty($vscomntools))
            {
                "Visual Studio 2012 not installed, Falling back to 2010"
                $vscomntools = (Get-ChildItem env:VS100COMNTOOLS).Value
            }
        }
    }

    $batchFile = [System.IO.Path]::Combine($vscomntools, "vsvars32.bat")
    Get-Batchfile $BatchFile
    Write-Host "Visual Studio variables set from $batchFile!" -ForegroundColor yellow
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

function Install-Special([bool]$install=$false)
{
    if( !$install)
    {
        Write-Output "git"
        Write-Output 'Pass $true to Install-Special to actually install'
    }
    else
    {
        if (! (Is-Admin) )
	    {
		    Write-Host "Run as admin!" -ForegroundColor Red
		    return
	    }
        # TODO: actually test this...
        choco install git.install -params '"/GitAndUnixToolsOnPath"'
    }
}

function Install-All([string]$app_list)
{
    $app_list.Split() | foreach { Install-Choco($_) }
}

# http://askubuntu.com/questions/673442/downloading-youtube-playlist-with-youtube-dl-skipping-existing-files
function Update-Songs([string]$dir="c:$env:HOMEPATH\Music\YouTube",
                      [string]$songs="https://www.youtube.com/playlist?list=PL28F0B690233E29E0")
{
    cd $dir -ErrorAction Stop
    youtube-dl --download-archive downloaded.txt --no-post-overwrites --max-downloads 10 -ciwx --audio-format mp3 -o "%(title)s.%(ext)s" $songs
}

# Init-PowerShellGoodies

if (Get-Module -ListAvailable -Name PSReadline) {
    # PSReadline goodness (Ctrl + Space makes zsh-style completion guide)
    # more at https://rkeithhill.wordpress.com/2013/10/18/psreadline-a-better-line-editing-experience-for-the-powershell-console/
    Import-Module PSReadline

    # See all KeyHandlers with Get-PSReadlineKeyHandler
    Set-PSReadlineKeyHandler -Key Ctrl+P -Function PreviousHistory
    Set-PSReadlineKeyHandler -Key Ctrl+N -Function NextHistory
    Set-PSReadlineKeyHandler -Key Ctrl+U -Function BackwardDeleteLine
}
else {
    Write-Host 'Get PSReadline with `Install-Module PSReadline`' -ForegroundColor Cyan
}

# Aliases
Set-Alias npp "C:\Program Files (x86)\Notepad++\notepad++.exe"
Set-Alias msbuild "C:\Windows\Microsoft.NET\Framework\v4.0.30319\msbuild.exe"
Set-Alias open Invoke-Item
Set-Alias touch New-File
Set-Alias VsVars32 Set-VisualStudioVars32

$apps = "
7zip.install
androidstudio
conemu
firefox
gamesavemanager
jdk8
putty
ruby
sharex
skype
vagrant
virtualbox
VisualStudioCode
"
# install git.install with appropriate switches
# that should also install vim
# visual studio can be installed with an xml file too...

# load the new-symlink script
. $PSScriptRoot/New-SymLink.ps1

# override $profile with location of this file
# To originally load this file, source it in original $profile
Set-Variable -Force PROFILE $MyInvocation.MyCommand.Path
