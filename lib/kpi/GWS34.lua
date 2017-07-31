-- GWS Controller
-- read config file "/etc/config/gws_radio" > "radio" > "GWS4K|gws4k|gws5k"
-- by Qige
-- 2017.02.23 - 2017.03.23

local conf = require 'six.conf'
local cmd = require 'six.cmd'
local fmt = require 'six.fmt'

local _num = fmt.param

local GWS34 = {}

-- GWS3000
GWS34.conf = {}
GWS34.conf.rfinfo = 'rfinfo | grep [0-9\.\-] -o'
GWS34.conf.region = 'getregion'
GWS34.conf.channel = 'getchan'
GWS34.conf.chanbw = 'getchanbw'
GWS34.conf.txpwr = 'gettxpwr | grep "^Tx" -m1 | grep [0-9\.\-]* -o'
GWS34.conf.note = 'gettemp | tr -d "\n"'


function GWS34.RAW()
	local _gws = {}

	_gws.rgn = _num(cmd.exec(GWS34.conf.region)) or -1
	_gws.ch = _num(cmd.exec(GWS34.conf.channel)) or -1
	_gws.chbw = _num(cmd.exec(GWS34.conf.chanbw)) or -1
	_gws.txpwr = _num(cmd.exec(GWS34.conf.txpwr)) or -1
	_gws.rxg = -99
	_gws.tpc = -1
	_gws.agc = -1
	_gws.note = _num(cmd.exec(GWS34.conf.note)) or ''

	return _gws
end

return GWS34
