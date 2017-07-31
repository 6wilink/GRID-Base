-- GWS Controller
-- read config file "/etc/config/gws_radio" > "radio" > "gws3k|gws4k|gws5k"
-- by Qige
-- 2017.02.23 - 2017.03.23

local conf = require 'six.conf'
local cmd = require 'six.cmd'
local fmt = require 'six.fmt'

local _num = fmt.param

local GWS5K = {}

GWS5K.conf = {}
GWS5K.conf.file = 'gws_radio'
GWS5K.conf.platform = conf.file.get(GWS5K.conf.file, 'v1', 'radio')


-- handle GWS5K get
GWS5K.get = {}
GWS5K.get.rfinfo = 'gws > /tmp/.grid_cache_rfinfo'
GWS5K.get.wait = 'sleep 1'
GWS5K.get.region = 'cat /tmp/.grid_cache_rfinfo | grep Region -m1 | awk \'{print $2}\''
GWS5K.get.channel = 'cat /tmp/.grid_cache_rfinfo | grep Chan -m1 | awk \'{print $2}\''
GWS5K.get.txpwr = 'cat /tmp/.grid_cache_rfinfo | grep Power -m1 | awk \'{print $2}\''
GWS5K.get.chbw = 'getchanbw | grep Radio | awk \'{print $2}\''
GWS5K.get.agc = 'cat /tmp/.grid_cache_rfinfo | grep AGC | grep ON'
GWS5K.get.rxgain = 'cat /tmp/.grid_cache_rfinfo | grep RxGain | awk \'{print $2}\''
GWS5K.get.note = 'cat /tmp/.grid_cache_rfinfo'

function GWS5K.RAW()
	local _gws = {}

	-- cat rfinfo into temp file
	cmd.exec(GWS5K.get.rfinfo)

	--cmd.exec(GWS5K.cmd.wait)

	_gws.rgn = _num(cmd.exec(GWS5K.get.region)) or -1
	_gws.ch = _num(cmd.exec(GWS5K.get.channel)) or -1
	_gws.chbw = _num(cmd.exec(GWS5K.get.chbw)) or -1
	_gws.txpwr = _num(cmd.exec(GWS5K.get.txpwr)) or -1
	_gws.rxg = _num(cmd.exec(GWS5K.get.rxgain)) or -1
	_gws.tpc = -1

	local _agc = cmd.exec(GWS5K.get.agc) or ''
	if (string.len(_agc) > 0) then
		_gws.agc = 1
	else
		_gws.agc = 0
	end
	_gws.note = '(gws5001)'

	return _gws
end


-- handle GWS5K set
GWS5K.set = {}
GWS5K.set.rxgain = 'gws -G %s'
GWS5K.set.region = 'gws -R %s'
GWS5K.set.channel = 'gws -C %s'
GWS5K.set.txpwr = 'gws -P %s'

function GWS5K.Save(_item, _val)
	local _result
	local _fmt = ''
	if (_item == 'rxg') then
		_fmt = GWS5K.set.rxgain
	elseif (_item == 'rgn') then
		_fmt = GWS5K.set.region
	elseif (_item == 'ch') then
		_fmt = GWS5K.set.channel
	elseif (_item == 'txpwr') then
		_fmt = GWS5K.set.txpwr
	end
	if (_fmt and _val) then
		local _cmd = string.format(_fmt, _val)
		_result = cmd.exec(_cmd)
		_result = string.format('{"error": null, "cmd": "%s", "result": "%s"}', _cmd, _result or 'null')
	else
		local _error = string.format('{"error": "failed", "result": "gws5k: %s=%s failed"}', _item, _val)
		_result = _error
	end

	--io.write(_result)
	return _result
end


return GWS5K
