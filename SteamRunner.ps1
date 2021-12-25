<#
/////////////////////////////////////////////////
//  STEAMRUNNER FOR STOREFRONTS by LULECH23    //
/////////////////////////////////////////////////

SteamRunner manages the execution of games from other storefronts in your Steam library, enabling the use of the Steam Overlay, Steam Input, and screenshot recording features in non-Steam games which otherwise do not support them.

To launch a game with SteamRunner, add a non-Steam game to your library, then edit the shortcut to point to `powershell.exe` and execute SteamRunner as shown in the examples below. See notes on each launcher for detailed differences in syntax and useful info for developers.

Supported launchers include: `BattleNet`, `EA`, `Epic`, `GOG`, `Uplay`

# Usage Info
## Basic Syntax
.\SteamRunner.ps1 Store Path GameName

## Example Steam Shortcut:
Target: "C:\WINDOWS\System32\WindowsPowerShell\v1.0\powershell.exe"
Launch Options: -WindowStyle Hidden -ExecutionPolicy Bypass -Command "C:\SteamRunner.ps1 Epic \"com.epicgames.launcher://apps/68c214c58f694ae88c2dab6f209b43e4?action=launch&silent=true\" \"KINGDOM HEARTS*|WaitTitleProject\""

## SteamRunner:
- GameName is a **filter** to identify the game executable process(es). Some games may use multiple executables (e.g. Kingdom Hearts HD), in which case wildcards (*) and pipe separators (|) may be used to monitor all matching processes.
    - Wildcards match all processes which begin with the same string.
    - Pipe separators match multiple processes with different names.
    - **Do not** include a file extension in GameName!
- Games that require account elevation will launch, but will not inherit Steam features.
    - Relaunch Steam as an administrator to bypass this limitation.
- To include quotes within quotes in Steam shortcuts, escape inner quotes with a backslash (\).
    - This is different from standard PowerShell convention, which uses backticks (`) as an escape character instead.

## PowerShell:
- PowerShell scripts must be enabled on your system for SteamRunner to work!
    - Prepend shortcut arguments with `-ExecutionPolicy Bypass` to temporarily enable PowerShell scripts.
- Prepend shortcut arguments with `-WindowStyle Hidden` to hide the PowerShell window during execution.
    - It is recommended to test shortcuts first, as this will also hide error output, if any.
- `Path` and `GameName` must be enclosed in quotes if they contain spaces or special characters.

# Launcher Info
## Battle.net:
- Store name must be input as "BattleNet" **without** a dot.
- Path to game executable must be fully-qualified.
- If available, use the main game executable rather than a launcher executable.
- Installation location can be obtained from "%APPDATA%\Battle.net\Battle.net.config" under "Client.Install.DefaultInstallPath".

## EA Desktop:
- Path to game executable must be fully-qualified.
- Installation location can be obtained from "%LOCALAPPDATA%\Electronic Arts\EA Desktop\user_####################.ini".

## Epic Games:
- Uses URLs instead of paths. URLs have the format "com.epicgames.launcher://apps/{AppName}?action=launch&silent=true".
- AppName can be obtained from "%PROGRAMDATA%\Epic\EpicGamesLauncher\Data\Manifests".
    - Manifests can be opened in any text editor.
- Steam will show the launched game as still running for several seconds after exiting. Although "QUIT" is displayed, **do not press it**. Simply wait for cloud syncing to complete and the game will exit normally.

## GOG Galaxy:
- Path must be a fully-qualified **root game directory** only, not a direct link to an executable.
    - GOG uses Game IDs which are obtained from the root directory. Galaxy handles the executable.
- Installations can be obtained from "%PROGRAMDATA%\GOG.com\Galaxy\config.json" under "libraryPath".

## Uplay:
- Path to game executable must be fully-qualified.
- Installations can be obtained from "HKLM\SOFTWARE\WOW6432Node\Ubisoft\Launcher\Installs".
- Still referenced internally as "Uplay" despite the brand change to "Ubisoft Connect".

# To-do
- Add Bethesda support.
- Add Rockstar support.
- Add Xbox/Microsoft Store support.
    - Can use URLs such as "shell:AppsFolder\Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe!App" to launch games from Steam, but will not inherit Steam Overlay/Steam Input/etc.
#>

<#
INITIALIZATION
#>

# Validate arguments
if ($args.Length -ne 3) {
    Write-Host "`nERROR: " -NoNewline -ForegroundColor Red
    Write-Host "Incorrect number of arguments supplied!`n"
    Write-Host "Usage: " -NoNewline -ForegroundColor DarkGray
    Write-Host ".\$($MyInvocation.MyCommand) " -NoNewLine
    Write-Host "Store " -NoNewLine -ForegroundColor Magenta
    Write-Host "Path " -NoNewLine -ForegroundColor Cyan
    Write-Host "GameName`n" -ForegroundColor Green
    Write-Host "See script notes for details on supported storefronts and specific usage of each`n"
    Start-Sleep 3
    exit
}

# Parse arguments
$gamePath = $args[1]
$gameArgs = $null
$gameProcess = $args[2].Split("|")
switch ($args[0].ToLower()) { # NOTE: Array order matters! FIFK - First In, First Killed
    "battlenet" {
        $launchProcess = @("Battle.net")
        break
    }
    "ea" {
        $launchProcess = @("EADesktop", "EABackgroundService")
        break
    }
    "epic" {
        $launchProcess = @("EpicGamesLauncher", "EpicWebHelper")
        break
    }
    "gog" {
        $launchProcess = @("GalaxyClient*", "GalaxyCommunication", "GOG Galaxy*")
        break
    }
    "uplay" {
        $launchProcess = @("upc", "Uplay*")
        break
    }
    Default {
        Write-Host "`nERROR: " -NoNewline -ForegroundColor Red
        Write-Host "Invalid game store supplied!`n"
        Start-Sleep 3
        exit
    }
}


<#
LAUNCHER
#>

# Shut down existing launcher process, if any
$process = (Get-Process $launchProcess 2>$null)
if ($process -ne $null) {    
    Write-Host "`nDetected running launcher instance. Restarting..." -ForegroundColor Yellow
    Stop-Process $process
    Start-Sleep 1
}

# Restart launcher, if necessary 
switch ($args[0].ToLower()) {
    "battlenet" {
        Write-Host "`nLaunching Battle.net..."
        try {
            if ([Environment]::Is64BitProcess) {
                $WOW64 = "\WOW6432Node"
            } else {
                $WOW64 = ""
            }
            $BNPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE$($WOW64)\Blizzard Entertainment\Battle.net\Capabilities" -Name "ApplicationIcon").ApplicationIcon
        } catch {
            Write-Host "`nERROR: " -NoNewline -ForegroundColor Red
            Write-Host "Battle.net installation not found!`n"
            Start-Sleep 3
            exit
        }
        $BNPath = $BNPath.Substring(0, $BNPath.Length - 2)
        Start-Process "$BNPath"
        Start-Sleep 10
    }
    "ea" {
        Write-Host "`nLaunching EA Desktop..."
        try {
            $EAPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Electronic Arts\EA Desktop\" -Name "LauncherAppPath").LauncherAppPath
        } catch {
            Write-Host "`nERROR: " -NoNewline -ForegroundColor Red
            Write-Host "EA Desktop installation not found! (Note that this script does not support Origin!)`n"
            Start-Sleep 3
            exit
        }
        Start-Process "$EAPath"
        Start-Sleep 10
    }
    "gog" {
        Write-Host "`nFetching GOG Galaxy game ID..."
        try {
            if ([Environment]::Is64BitProcess) {
                $WOW64 = "\WOW6432Node"
            } else {
                $WOW64 = ""
            }
            $GGPath = (Get-ItemProperty -Path "HKLM:\SOFTWARE$($WOW64)\GOG.com\GalaxyClient\paths" -Name "client").client
        } catch {
            Write-Host "`nERROR: " -NoNewline -ForegroundColor Red
            Write-Host "GOG Galaxy 2.0 installation not found! (Note that this script does not support 1.0!)`n"
            Start-Sleep 3
            exit
        }

        $gameID = ((Get-ChildItem "$gamePath\goggame-*.ico").Name -replace ".*-" -replace ".ico")
        $gameArgs = "/command=runGame /gameId=$gameID /path=`"$gamePath`""
        $gamePath = "$GGPath\GalaxyClient.exe" 
    }
}

# Run game!
Write-Host "`nRunning game..." -ForegroundColor Green
if ($gameArgs -ne $null) {
    &Start-Process "$gamePath" -ArgumentList "$gameArgs"
} else {
    &Start-Process "$gamePath"
}
Start-Sleep 15


<#
MONITOR
#>

# Monitor launched game process(es)
while ($true) {
    Start-Sleep 1
    $process = (Get-Process $gameProcess 2>$null)

    # Close launcher when game is closed (disassociates process from Steam)
    if ($process -eq $null) {
        Write-Host "`nGame ended. " -NoNewline -ForegroundColor Cyan 
        Write-Host "Waiting for cloud sync to exit...`n"
        Start-Sleep 10
        $process = (Get-Process $launchProcess 2>$null)
        if ($process -ne $null) {
            Stop-Process $process
        }
        break
    }
}