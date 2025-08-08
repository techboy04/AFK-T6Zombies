#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_globallogic;
#include maps\mp\gametypes_zm\_hostmigration;
#include maps\mp\gametypes_zm\_spectating;
#include maps\mp\gametypes_zm\_globallogic_utils;

init()
{
	level thread playerConnect();
	level thread command_thread();
	create_dvar( "afk_cooldown_duration", 120 );
	create_dvar( "afk_kick_enabled", 1 );
	create_dvar( "afk_disableInsteadOfKick", 0 );
	create_dvar( "afk_announce_status", 1);
	create_dvar( "afk_kick_duration", 640 );
	create_dvar( "afk_kick_warning_duration", 240 );
	create_dvar( "debug_text", 0 );
	if(getDvarInt("afk_cooldown_duration") < 0)
	{
		setDvar("afk_cooldown_duration", 0);
	}
}

playerConnect()
{
	for(;;)
	{
		level waittill ("connected", player);
		player.isafk = 0;
		player.afkcooldown = 0;
		player.kickrisk = 0;
	}
}

create_dvar( dvar, set )
{
    if( getDvar( dvar ) == "" )
		setDvar( dvar, set );
}

command_thread()
{
	level endon( "end_game" );
	while ( true )
	{
		level waittill( "say", message, player, isHidden );
		args = strTok( message, " " );
		command = args[ 0 ];
		switch ( command )
		{
			case ".afk":
				if(player.isafk == 0)
				{
					player afk_enable();
				}
				else
				{
					player afk_disable();
				}
				break;
			default:
				break;
		}
	}
}

afk_enable()
{
	if(self.canafk == 1)
	{
		self.isafk = 1;
		self thread afkmonitor();
		self thread afkHUD();
		self thread timeTillKick();
		foreach(player in level.players)
		{
			if(getDvarInt("afk_announce_status") == 1)
			{
				player iprintln(self.name + " is now afk!");
			}
		}
	}
	else
	{
		self iprintln("You cannot AFK yet! [" + self.afkcooldown + "s left]");
	}
}

afk_disable()
{
	self.isafk = 0;
	self notify ("afk_over");
	self.ignoreme = 0;
	self.kickrisk = 0;
	self DisableInvulnerability();
	self freezeControls(false);
	self thread afkCoolDown();
	foreach(player in level.players)
	{
		if(getDvarInt("afk_announce_status") == 1)
		{
			player iprintln(self.name + " is no longer afk!");
		}
	}
}

afkmonitor()
{
	self endon ("disconnect");
	self endon ("afk_over");
	for(;;)
	{
		if(self.isafk == 1)
		{
			self.ignoreme = 1;
			self EnableInvulnerability();
			self freezeControls(true);
		}
		if(!isgodmode( self ))
		{
			self EnableInvulnerability();
		}
		if(self.ignoreme != 1)
		{
			self.ignoreme = 1;
		}
		wait 0.01;
	}
}

afkHUD()
{	
	if(isDefined(self.afkHUD))
	{
		self.afkHUD destroy();
	}
	
	self.afkHUD = newclienthudelem( self );
    self.afkHUD.alignx = "left";
    self.afkHUD.aligny = "middle";
    self.afkHUD.horzalign = "user_left";
    self.afkHUD.vertalign = "user_center";
    self.afkHUD.y -= 80;
	self.afkHUD.x += 30;
    
    self.afkHUD.foreground = 1;
    self.afkHUD.fontscale = 2;
    self.afkHUD.alpha = 	1;
    self.afkHUD.hidewheninmenu = 0;
    self.afkHUD.font = "default";

	self.afkHUD setText("Youre currently AFK\nType .afk again in the chat to return!");
	
	self waittill ("afk_over");

    self.afkHUD destroy();
}

afkCoolDown()
{
	self.canafk = 0;
	afkCooldownCountdown();
	self.canafk = 1;
	self iprintln("You can now AFK!");
}

afkCooldownCountdown()
{
	self.afkcooldown = getDvarInt("afk_cooldown_duration");
	while(self.afkcooldown > 0)
	{
		self.afkcooldown -= 1;
		wait 1;
	}
}

timeTillKick()
{
	self endon ("afk_over");
	if(getDvarInt("afk_kick_enabled") != 1)
	{
		return;
	}
	count = getDvarInt("afk_kick_duration");
	if(getDvarInt("afk_kick_warning_duration") > getDvarInt("afk_kick_duration"))
	{
		debug_text("Theres an error! afk_kick_warning_duration value cannot be bigger than afk_kick_duration!", self);
		warning_count = count / 4;
	}
	else
	{
		warning_count = getDvarInt("afk_kick_warning_duration");
	}
	while(count > 0)
	{
		count -= 1;
		self iprintln("Countdown:" + count + " - Warning Countdown:" + warning_count);
		if(warning_count == count)
		{
			self.kickrisk = 1;
			if(getDvarInt("afk_disableInsteadOfKick") == 1)
			{
				self.afkHUD setText("Youre currently AFK\nType .afk again in the chat to return!\nYour AFK will be disabled soon!");
			}
			else
			{
				self.afkHUD setText("Youre currently AFK\nType .afk again in the chat to return!\nYou may be kicked if you AFK for too long!");
			}
		}
		wait 1;
	}
	if(getDvarInt("afk_disableInsteadOfKick") == 0)
	{
		if(!self ishost())
		{
			kick( self getentitynumber() );
			foreach(player in level.players)
			{
				if(getDvarInt("afk_announce_status") == 1)
				{
					player iprintln(self.name + " was kicked due to being afk too long!");
				}
			}
		}
		else
		{
			debug_text("Couldnt kick player! - Disabling AFK instead.", self);
			self thread afk_disable();
		}
	}
	else
	{
		self thread afk_disable();
	}
}

debug_text(text, player)
{
	if(getDvarInt("debug_text") != 1)
	{
		return;
	}
	if(isDefined(player))
	{
		foreach(player in level.players)
		{
			debug_text(text, player);
		}
	}
	else
	{
		player iprintln(text);
	}
}