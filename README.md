# AFK for Bo2 Zombies!
Decided to go with my own take on the AFK script. I tried to make this as customizable as possible. With future ideas planned in the future.

Despite me making my mods in mod form, this will stick to script to make it more universal.

Current Features:
- AFK toggle
- Kick or Auto Disable if AFK too long (duration configurable)
- Cooldown between AFK
- Announce if a player is afk or not

Future Plans:
- Put players in spectate as an option
- Hide the afk player and place a model in-place and/or an icon above to show the players AFK

## Configuration
This script has alot of dvars! Use "set dvar value" in console or in server config to configure!

- afk_cooldown_duration (Default: 120) - Duration to use the AFK command again. Value in seconds.
- afk_kick_emabled (Default: 1) - Toggle AFK Kick, which will kick (or auto disable if that option is enabled) if the player is afk for too long.
- afk_disableInsteadOfKick (Default: 0) - Instead of kicking the player the AFK will auto disable. If youre the host this will be enabled regardless. (You can't kick hosts)
- afk_announce_status (Default: 1) - Announce when the player is afk or no longer afk or kicked for being afk for too long.
- afk_kick_duration (Default: 640) - How long before the player gets kicked or auto disabled afk. Value in seconds.
- afk_kick_warning_duration (Default: 240) - At what time should the players whos afk gets notified that they will be kicked once the timer is up. Value in seconds. (For Example, 60 will have the message pop up once 60 seconds are left)
- debug_text (Default: 0) - Development purposes but will show the debug text, here it will show the countdown and warning number.
