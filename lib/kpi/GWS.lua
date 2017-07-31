-- GWS Controller
-- read config file "/etc/config/gws_radio" > "radio" > "gws3k|gws4k|gws5k"
-- by Qige
-- 2017.02.23 - 2017.03.23

local conf = require 'six.conf'
local cmd = require 'six.cmd'
local fmt = require 'six.fmt'

local gws34 = require 'kpi.GWS34'
local gws5k = require 'kpi.GWS5K'


local GWS = {}

GWS.conf = {}
GWS.conf.file = 'gws_radio'
GWS.conf.platform = conf.file.get(GWS.conf.file, 'v1', 'radio')



-- all functions that for external calling
GWS.ops = {}

-- to different cmds based on different platform
function GWS.RAW()
	local _gws = {}
	
	local _platform = GWS.conf.platform or 'gws5k'
	if (_platform == 'gws3k' or _platform == 'gws4k') then
		_gws = gws34.RAW()
	--elseif (_platform == 'gws5k') then
	else
		_gws = gws5k.RAW()
	end

	return _gws
end


-- answer "GWS.JSON()" called by "grid/Get.lua"
-- eg. rgn/ch/bw/rxg/txpwr/tpc/agc/note
function GWS.JSON()
	local _result
	local _fmt = '{"rgn": %d, "ch": %d, "bw": %d, '
		.. '"txpwr": %d, "tpc": %d, "rxg": %d, "agc": %d, "note": "%s" }'

	local _gws = GWS.RAW()
	_result = string.format(_fmt, _gws.rgn or -1, _gws.ch or -1, _gws.chbw or -1, 
		_gws.txpwr or 0, _gws.tpc or -1, _gws.rxg or 0, _gws.agc or -1, _gws.note or '')

	return _result
end


-- answer "GWS.ops.Set()" called by "grid/Set.lua"
-- eg. rgn/ch/chbw/txpwr/tpc/rxg/agc
function GWS.Save(_item, _val)
	local _result
	
	local _platform = GWS.conf.platform
	if (_platform == 'gws3k' or _platform == 'gws4k') then
		_result = gws34.Save(_item, _val)
	--elseif (_platform == 'gws5k') then
	else
		_result = gws5k.Save(_item, _val)
	end
	return _result
end


return GWS