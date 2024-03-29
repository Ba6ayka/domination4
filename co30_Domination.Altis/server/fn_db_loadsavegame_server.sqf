// by Xeno
//#define __DEBUG__
#define THIS_FILE "fn_db_loadsavegame_server.sqf"
#include "..\x_setup.sqf"

params ["_sname", "_sender"];

__TRACE_1("","_sname")

private _dbresult = [];

if (!d_tt_ver) then {
#ifndef __INTERCEPTDB__
	_dbresult = if (_sender != objNull) then {
		parseSimpleArray ("extdb3" callExtension format ["0:dom:missionGet:%1", toLower (worldName + _sname)]);
	} else {
		__TRACE("Before")
		_res = parseSimpleArray ("extdb3" callExtension format ["0:dom:missionGet2:%1", tolower (worldName + _sname + briefingname)]);
		__TRACE_1("","_res")
		_res
	};
	if (_dbresult # 0 == 1) then {
		_dbresult = _dbresult # 1;
	} else {
		_dbresult = [];
	};
#else
	if (d_interceptdb) then {
		if (_sender != objNull) then {
			_dbresult = ["missionGet", [toLower (worldName + _sname)]] call dsi_fnc_queryconfig;
		} else {
			_dbresult = ["missionGet2", [toLower (worldName + _sname + briefingname)]] call dsi_fnc_queryconfig;
		};
	};
#endif
} else {
#ifndef __INTERCEPTDB__
	_dbresult = if (_sender != objNull) then {
		parseSimpleArray ("extdb3" callExtension format ["0:dom:missionttGet:%1", tolower (worldName + _sname)]);
	} else {
		parseSimpleArray ("extdb3" callExtension format ["0:dom:missionttGet2:%1", tolower (worldName + _sname + briefingname)]);
	};
	if (_dbresult # 0 == 1) then {
		_dbresult = _dbresult # 1;
	} else {
		_dbresult = [];
	};
#else
	if (d_interceptdb) then {
		if (_sender != objNull) then {
			_dbresult = ["missionttGet", [toLower (worldName + _sname)]] call dsi_fnc_queryconfig;
		} else {
			_dbresult = ["missionttGet2", [toLower (worldName + _sname + briefingname)]] call dsi_fnc_queryconfig;
		};
	};
#endif
};

__TRACE_1("","_dbresult")

#ifdef __DEBUG__
{
	diag_log _x;
} forEach (_dbresult # 0);
#endif

if (_dbresult isEqualTo []) exitWith {
	if (!isNull _sender) then {
		[format [localize "STR_DOM_MISSIONSTRING_1752", _sname], "GLOBAL"] remoteExecCall ["d_fnc_HintChatMsg", _sender];
	} else {
		diag_log format [localize "STR_DOM_MISSIONSTRING_1752", _sname];
	};
};

_dbresult params ["_ar"];

#ifndef __TT__
d_maintargets = _ar # 0;
publicVariable "d_MainTargets";
d_maintargets_list = _ar # 1;
//d_current_target_index = _ar # 2;
//publicVariable "d_current_target_index";
//d_cur_sm_idx = _ar # 3;
//publicVariable "d_cur_sm_idx";
d_resolved_targets = _ar # 4;
publicVariable "d_resolved_targets";
if (d_with_targetselect == 0) then {
	d_mttargets_ar = [];
	{
		if !((_x # 3) in d_resolved_targets) then {
			d_mttargets_ar pushBack _x;
		};
	} forEach d_target_names;
};
__TRACE_1("","d_resolved_targets")
d_side_missions_random = _ar # 6;
d_current_mission_counter = _ar # 7;
d_searchintel = _ar # 8;
publicVariable "d_searchintel";
d_bonus_vecs_db = _ar # 9;
{
	private _vec = createVehicle [_x, d_bonus_create_pos, [], 0, "NONE"];
	if (unitIsUAV _vec) then {
		private _uavgrp = createVehicleCrew _vec;
		_uavgrp deleteGroupWhenEmpty true;
		_vec allowCrewInImmobile true;
		[_vec, 7] call d_fnc_setekmode;
		if (isClass (configFile>>"CfgVehicles">>_vec_type>>"Components">>"TransportPylonsComponent")) then {
			_vec remoteExecCall ["d_fnc_addpylon_action", [0, -2] select isDedicated];
		};
	};
	_vec setVariable ["d_isspecialvec", true, true];
	private ["_endpos", "_dir"];
	if (_vec isKindOf "Air") then {
		if (d_bonus_air_positions_carrier isEqualTo []) then {
			_endpos = (d_bonus_air_positions # d_bap_counter) # 0;
			_dir = (d_bonus_air_positions # d_bap_counter) # 1;
			d_bap_counter = d_bap_counter + 1;
			if (d_bap_counter > (count d_bonus_air_positions - 1)) then {d_bap_counter = 0};
		} else {
			if (getNumber(configFile >> "CfgVehicles" >> _x >> "tailHook") != 1) then {
				_endpos = (d_bonus_air_positions # d_bap_counter) # 0;
				_dir = (d_bonus_air_positions # d_bap_counter) # 1;
				d_bap_counter = d_bap_counter + 1;
				if (d_bap_counter > (count d_bonus_air_positions - 1)) then {d_bap_counter = 0};
			} else {
				_endpos = (d_bonus_air_positions_carrier # d_bacp_counter) # 0;
				private _aslheight = d_the_carrier getVariable "d_asl_height";
				if (isNil "_aslheight") then {
					_aslheight = (getPosASL d_FLAG_BASE) # 2;
				};
				_endpos set [2, _aslheight];
				_dir = (d_bonus_air_positions_carrier # d_bacp_counter) # 1;
				_vec setVariable ["d_oncarrier", true];
				d_bacp_counter = d_bacp_counter + 1;
				if (d_bacp_counter > (count d_bonus_air_positions_carrier - 1)) then {d_bacp_counter = 0};
			};
		};
	} else {
		_endpos = (d_bonus_vec_positions # d_bvp_counter) # 0;
		_dir = (d_bonus_vec_positions # d_bvp_counter) # 1;
		d_bvp_counter = d_bvp_counter + 1;
		if (d_bvp_counter > (count d_bonus_vec_positions - 1)) then {d_bvp_counter = 0};
		_vec setVariable ["d_liftit", true, true];
	};


	_vec setDir _dir;
	_vec setVehiclePosition [_endpos, [], 0, "NONE"];

	[_vec, 11] call d_fnc_setekmode;

	_vec addEventHandler ["getIn", {_this call d_fnc_sgetinvec}];

	_vec addEventHandler ["getOut", {_this call d_fnc_sgetoutvec}];
	d_bonus_vecs_db set [_forEachIndex, _vec];
} forEach d_bonus_vecs_db;
#else
d_maintargets = _ar # 0;
publicVariable "d_maintargets";
d_maintargets_list = _ar # 1;
//d_current_target_index = _ar # 2;
//publicVariable "d_current_target_index";
//d_cur_sm_idx = _ar # 3;
//publicVariable "d_cur_sm_idx";
d_resolved_targets = _ar # 4;
publicVariable "d_resolved_targets";
d_side_missions_random = _ar # 6;
d_current_mission_counter = _ar # 7;
d_searchintel = _ar # 8;
publicVariable "d_searchintel";

_fnc_tt_bonusvec = {
	params ["_vec_type", "_d_bonus_create_pos", "_d_bonus_air_positions", "_d_bap_counter", "_d_bonus_vec_positions", "_d_bvp_counter", "_side"];
	private _vec = createVehicle [_vec_type, _d_bonus_create_pos, [], 0, "NONE"];
	private ["_endpos", "_dir"];
	if (_vec isKindOf "Air") then {
		_endpos = (_d_bonus_air_positions # _d_bap_counter) # 0;
		_dir = (_d_bonus_air_positions # _d_bap_counter) # 1;
		_vec setVariable ["D_VEC_SIDE", _side];
		if (_side == 1) then {
			d_bap_counter_e = d_bap_counter_e + 1;
			if (d_bap_counter_e > (count _d_bonus_air_positions - 1)) then {d_bap_counter_e = 0};
		} else {
			d_bap_counter_w = d_bap_counter_w + 1;
			if (d_bap_counter_w > (count _d_bonus_air_positions - 1)) then {d_bap_counter_w = 0};
		};
	} else {
		_endpos = (_d_bonus_vec_positions # _d_bvp_counter) # 0;
		_dir = (_d_bonus_vec_positions # _d_bvp_counter) # 1;
		_vec setVariable ["D_VEC_SIDE", _side];
		if (_side == 1) then {
			d_bvp_counter_e = d_bvp_counter_e + 1;
			if (d_bvp_counter_e > (count _d_bonus_vec_positions - 1)) then {d_bvp_counter_e = 0};
		} else {
			d_bvp_counter_w = d_bvp_counter_w + 1;
			if (d_bvp_counter_w > (count _d_bonus_vec_positions - 1)) then {d_bvp_counter_w = 0};
		};
		_vec setVariable ["d_liftit", true, true];
	};

	_vec setDir _dir;
	_vec setVehiclePosition [_endpos, [], 0, "NONE"];
	_vec setVariable ["d_WreckMaxRepair", d_WreckMaxRepair, true];
	_vec setVariable ["d_isspecialvec", true, true];
	[_vec, 11] call d_fnc_setekmode;
	_vec addEventHandler ["getIn", {_this call d_fnc_sgetinvec}];

	_vec addEventHandler ["getOut", {_this call d_fnc_sgetoutvec}];

	_vec
};

d_bonus_vecs_db_w = _ar # 9;
{
	d_bonus_vecs_db set [_forEachIndex, [_x, d_bonus_create_pos_w, d_bonus_air_positions_w, d_bap_counter_w, d_bonus_vec_positions_w, d_bvp_counter_w, 2] call _fnc_tt_bonusvec];
} forEach d_bonus_vecs_db_w;
d_bonus_vecs_db_e = _ar # 10;
{
	d_bonus_vecs_db set [_forEachIndex, [_x, d_bonus_create_pos_e, d_bonus_air_positions_e, d_bap_counter_e, d_bonus_vec_positions_e, d_bvp_counter_e, 2] call _fnc_tt_bonusvec];
} forEach d_bonus_vecs_db_e;
d_points_blufor = _ar # 11;
d_points_opfor = _ar # 12;
d_kill_points_blufor = _ar # 13;
d_kill_points_opfor = _ar # 14;
d_points_array = _ar # 15;
publicVariable "d_points_array";
#endif

{
#ifndef __TT__
	private _res = _x;
#else
	private _res = _x # 0;
#endif

	private _tgt_ar = d_target_names # _res;
	private _mar = format ["d_%1_dommtm", _tgt_ar # 1];
	[_mar, _tgt_ar # 0, "ELLIPSE", "ColorGreen", [ _tgt_ar # 2,  _tgt_ar # 2]] call d_fnc_CreateMarkerGlobal;
	_mar setMarkerAlpha d_e_marker_color_alpha;
} forEach d_resolved_targets;


if (!isNull _sender) then {
	[_sender, ["dDBLoad", [localize "STR_DOM_MISSIONSTRING_1750", "<font face='RobotoCondensed' size=24 color='#ffffff'>" + format [localize "STR_DOM_MISSIONSTRING_1753", _sname] + "</font>"]]] remoteExecCall ["createDiaryRecord", _sender];
};
