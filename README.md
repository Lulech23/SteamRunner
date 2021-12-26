<p align="center">
    <img width="160" height="160" src="https://github.com/Lulech23/SteamRunner/blob/main/bin/SteamRunner.ico?raw=true" title="SteamRunner" style="max-width:100%;">
</p>

# SteamRunner for Storefronts
> Universal game runner for Steam

PC gaming is overrun with launchers. While competition is a good thing, not all launchers have the same feature set, and to date, no launcher has more features than Steam. PC gamers should be free to buy games from whichever launcher they want and still have the benefit of features like **universal controller support**, an **in-game overlay** with chat and a web browser, and **screenshot functionality**.

With SteamRunner, now you can!

SteamRunner manages the execution of games added to Steam from third-party libraries. Processes launched through SteamRunner will be attached to Steam and inherit full Steam Input and Steam Overlay functionality *no matter which store they came from*. This includes stores which are notoriously difficult to import to Steam at all.

**Currently supported storefronts include:** `BattleNet`, `EA`, `Epic`, `GOG`, `Uplay`

# How to use
As SteamRunner is written in PowerShell, it can be operated in one of two ways: as a PowerShell script, or as a compiled EXE with [PS2EXE](https://github.com/MScholtes/PS2EXE) (recommended). As the former comes with a number of additional quirks, this guide will only cover the latter. Advanced users may view PowerShell usage details within the script file itself.

> **Important:** SteamRunner assumes you are already signed in to each platform before starting a game. If you are signed out, SteamRunner will likely detect the target game as not running and exit prematurely. Make sure all platforms are signed in before proceeding.

1. Download and extract the latest version of SteamRunner from [releases](https://github.com/Lulech23/SteamRunner/releases/latest)
2. Create a new shortcut in Steam via the **Games** \> **Add a Non-Steam Game to My Library...** menu. The actual subject of the shortcut doesn't matter, since it must be modified anyway. However, because the menu does not allow for importing the same item multiple times, you must select any application *besides* SteamRunner.
3. Next, modify the new shortcut by right-clicking on it and choosing **Properties**.
4. Set the shortcut **name** to the name of the game you wish to import. You may also add an icon from the game's directory here.
5. Set the shortcut **target** to the full path for wherever you extracted `SteamRunner.exe`. If the path has any spaces or special characters, enclose in quotes. (Ex: `"C:\My Folder\SteamRunner.exe"`)
6. Set the shortcut **start in** directory to the root directory of your game.
7. Set the shortcut **launch options** according to the following syntax:

> `Store` `Path` `GameName`

## Runner Parameters
The exact values represented by the syntax above varies slightly depending on which storefront your game is launching from (see details below).

In addition, note that the `GameName` parameter is a **filter** which tells SteamRunner which process(es) to monitor. Multiple processes can be matched by using a wildcard (`*`) or pipe separator (`|`). For example, in the Kingdom Hearts HD collection, there are separate executables for each game in the collection, plus a loading screen application to hide transitions between each. Rather than name all 7+ executables manually, we can match them programmatically with just `"KINGDOM HEARTS*|WaitTitleProject"`. This will match any processes starting with the words "KINGDOM HEARTS", and also the exact process "WaitTitleProject". `GameName` filters should **not** have an extension (e.g. `.exe`).

### Battle.net
> `BattleNet "C:\Program Files (x86)\Overwatch\_retail_\Overwatch.exe" "Overwatch"`

Store name must be input as "BattleNet" **without** a dot. If applicable, use the main game executable rather than a launcher executable.

### EA Desktop
> `EA "C:\Program Files (x86)\EA Games\Mass Effect Legendary Edition\Game\MassEffectLauncher.exe" "MassEffect*"`

Supports EA Desktop **only**, not Origin. If you see a warning that EABackgroundService.exe could not be closed, you will have to restart and exit the current running instance of EA Desktop manually.

### Epic Games
> `Epic "com.epicgames.launcher://apps/68c214c58f694ae88c2dab6f209b43e4?action=launch&silent=true" "KINGDOM HEARTS*|WaitTitleProject"`

Uses URLs instead of executable paths. URLs have the format `com.epicgames.launcher://apps/{AppName}?action=launch&silent=true`, where `AppName` can be obtained from `%PROGRAMDATA%\Epic\EpicGamesLauncher\Data\Manifests` (open manifests with your preferred text editor). Alternatively, create a desktop shortcut from the Epic Games store and copy the URL from the shortcut properties.

URLs **must** be enclosed in quotes.

### GOG Galaxy
> `GOG "C:\Program Files (x86)\GOG Galaxy\Games\SWAT 4" "Swat4"`

Uses paths to a **root directory only**, not to executables. (Executables are obtained from game IDs which are handled by SteamRunner and GOG Galaxy themselves.) `GameName` must still match the executable name, not the root directory name.

### Uplay/Ubisoft Connect
> `Uplay "C:\Program Files (x86)\Ubisoft\Assassin's Creed 1\AssassinsCreed_Game.exe" "Assassins*"`

Despite rebranding to "Ubisoft Connect", Ubisoft's platform is still internally referred to as "Uplay", so that's how it's referred to by SteamRunner.

# To-Do
* Add Bethesda support.
* Add Rockstar support.
* Add Xbox/Microsoft Store support.
    * Can use URLs such as `shell:AppsFolder\Microsoft.MicrosoftSolitaireCollection_8wekyb3d8bbwe!App` to launch games from Steam, but will not inherit Steam Overlay/Steam Input/etc.

#### Disclaimer
> *SteamRunner is provided as-is and comes without warranty or support. Steam, Battle.net, EA Desktop, Epic Games, GOG Galaxy, & Uplay are property of their respective owners. Icon based on designs by [itim2101](https://freeicons.io/plumber-tools-icon-set-2/valve-pipes-water-industry-gas-pipe-icon-266605)*