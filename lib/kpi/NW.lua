-- by Qige
-- 2017.03.01 - 2017.03.23

local cmd = require 'six.cmd'
local conf = require 'six.conf'
local fmt = require 'six.fmt'

local ABB = require 'kpi.ABB'


local NW = {}

NW.conf = {}
NW.conf.eth_ifname = 'eth0'
NW.conf.wls_ifname = 'wlan0'
NW.conf.ap_ifname = 'br-lan'


NW.cache = {}

NW.cache._bridge = 0
NW.cache._eth_ip = ''
NW.cache._wls_ip = ''

NW.cache._eth_txb = 0
NW.cache._eth_rxb = 0
NW.cache._wls_txb = 0
NW.cache._wls_rxb = 0

NW.cache.ts = os.time()



function NW.RAW()
	local _data = NW.raw.read()
	return _data
end

function NW.JSON()
	local _result
	local _fmt = '{"bridge": %d, "wan_ip": "%s", "lan_ip": "%s"'
	_fmt = _fmt .. ' ,"eth_rxb": %d, "eth_txb": %d, "wls_rxb": %d, "wls_txb": %d }'

	local _data = NW.RAW()
	_result = string.format(_fmt, _data.bridge or 1, 
		_data.wan_ip or '-', _data.lan_ip or '-', 
		_data.eth_rxb or 0, _data.eth_txb or 0, 
		_data.wls_rxb or 0, _data.wls_txb or 0)

	return _result
end




NW.cli = {}

-- read rxbytes, txbytes
-- /proc/net/dev col2=rxbytes, col10=txbytes
function NW.cli.rxbtxb(ifname)
	local _fmt = "cat /proc/net/dev | grep %s -m1 | awk '{print $2,$10}'\n"
	local _cmd = string.format(_fmt, ifname)

	local _bytes = cmd.exec(_cmd)

	local _rxbtxb
	if (_bytes) then
		_rxbtxb = fmt.str.split(' ', _bytes)
	end

	return _rxbtxb
end



NW.sync = {}

function NW.sync.conf()
	if (conf.file.get('network', 'lan', 'type') == 'bridge') then
		NW.cache._bridge = 1
	else
		NW.cache._bridge = 0
	end
	NW.cache._wls_ip = conf.file.get('network', 'lan', 'ipaddr')
	NW.cache._eth_ip = conf.file.get('network', 'wan', 'ipaddr')
end

-- TODO: fix CAR with muilti EARs
function NW.sync.thrpt()
	local wls_mode = ABB.raw.mode()
	if (wls_mode == 'CAR' or wls_mode == 'Mesh') then
		wls_ifname = NW.conf.ap_ifname
		eth_ifname = NW.conf.eth_ifname
	else
		wls_ifname = NW.conf.wls_ifname
		eth_ifname = NW.conf.eth_ifname
	end

	-- read LAN rxbytes, txbytes
	local _wls_rxbtxb = NW.cli.rxbtxb(wls_ifname)
	if (_wls_rxbtxb and #_wls_rxbtxb >= 2) then
		NW.cache._wls_rxb = _wls_rxbtxb[1]
		NW.cache._wls_txb = _wls_rxbtxb[2]
	else
		NW.cache._wls_rxb = 0
		NW.cache._wls_txb = 0
	end

	-- read WAN rxbytes, txbytes
	local _eth_rxbtxb = NW.cli.rxbtxb(eth_ifname)
	if (_eth_rxbtxb and #_eth_rxbtxb >= 2) then
		NW.cache._eth_rxb = _eth_rxbtxb[1]
		NW.cache._eth_txb = _eth_rxbtxb[2]
	else
		NW.cache._eth_rxb = 0
		NW.cache._eth_txb = 0
	end
end

NW.raw = {}
function NW.raw.read()
	local _nw = {}
	
	-- call for update
	NW.sync.conf()
	NW.sync.thrpt()

	_nw.bridge = NW.cache._bridge
	_nw.wan_ip = NW.cache._eth_ip
	_nw.lan_ip = NW.cache._wls_ip

	_nw.eth_rxb = fmt.n(NW.cache._eth_rxb)
	_nw.eth_txb = fmt.n(NW.cache._eth_txb)
	_nw.wls_rxb = fmt.n(NW.cache._wls_rxb)
	_nw.wls_txb = fmt.n(NW.cache._wls_txb)

	return _nw
end


return NW