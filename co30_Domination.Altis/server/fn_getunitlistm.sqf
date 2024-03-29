// by Xeno
//#define __DEBUG__
#define THIS_FILE "fn_getunitlistm.sqf"
#include "..\x_setup.sqf"

__TRACE_1("","_this")

params ["_grptype", "_side"];

private _ret =+ selectRandom (missionNamespace getVariable format ["d_%1_%2", _grptype, [switch (_side) do {case opfor: {"E"};case blufor: {"W"};case independent: {"G"};case civilian: {"W"};}, _side] select (_side isEqualType "")]);

__TRACE_2("1","count _ret","_ret")

// for now reduce inf groups to 5 or 7 units max to save a little bit performance
private _cm = [selectRandom [5, 6, 7], selectRandom [4, 5, 6]] select (_grptype == "specops");
if (count _ret > _cm) then {
	while {count _ret > _cm} do {
		_ret deleteAt (ceil (random (count _ret - 1)));
	};
};
__TRACE_2("2","count _ret","_ret")

_ret
