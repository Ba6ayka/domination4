// by Xeno
//#define __DEBUG__
#define THIS_FILE "fn_player_stuff.sqf"
#include "..\x_setup.sqf"

if (!hasInterface) exitWith {};

__TRACE_1("","_this")
d_player_autokick_time = _this select 0;

if (d_WithRevive == 0 && {(_this select 8) == -1 && {xr_max_lives != -1}}) exitWith {
	0 spawn {
		scriptName "spawn_playerstuffparking";
		waitUntil {sleep 0.1; !d_still_in_intro};
		__TRACE("player_stuff, calling park_player")
		player setVariable ["xr_lives", -1, true];
		xr_pl_no_lifes = true;
		[false] spawn xr_fnc_park_player;
	};
};

#ifdef __TT__
_this spawn {
	waitUntil {sleep 0.1; !d_still_in_intro};
	if (!isNil {player getVariable "d_no_side_change"}) then {
		private _rtime = time - (_this select 9);
		[format [localize "STR_DOM_MISSIONSTRING_1871", profileName, _rtime], "GLOBAL"] remoteExecCall ["d_fnc_HintChatMsg", -2];
		0 spawn {
			scriptName "spawn_endmissionloser";
			sleep 1.5;
			endMission "LOSER";
		};
	} else {
		private _prev_side = _this select 5;
		if (_prev_side != sideUnknown && {d_player_side != _prev_side}) then {
			[format [localize "STR_DOM_MISSIONSTRING_641", profileName, _prev_side, d_player_side], "GLOBAL"] remoteExecCall ["d_fnc_HintChatMsg", -2];
		};
	};
};
#endif

private _lo = _this select 11;
__TRACE_1("","_lo")
if !(_lo # 0 isEqualTo []) then {
	_lo spawn {
		scriptName "spawn_player_stuff";
		waitUntil {!isNil "d_player_side"};
		if (_this # 1 == d_player_side) then {
			player setUnitLoadout [_this # 0, false];
			call d_fnc_save_respawngear;
			call d_fnc_save_layoutgear;
		};
	};
};

if (_this select 7 >= d_maxnum_tks_forkick) then {
	0 spawn {
		scriptName "spawn_endmissionloser2";
		hint "You will be kicked back to the lobby because of too much teamkilling!!!!";
		titleText "You will be kicked back to the lobby because of too much teamkilling!!!!";
		sleep 5;
		endMission "LOSER";
	};
};