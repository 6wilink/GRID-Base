-- abb Controller
-- by Qige
-- 2017.02.23 - 2017.03.23

local _iwinfo = require "iwinfo"
local fmt = require 'six.fmt'
local cmd = require 'six.cmd'


local ABB = {}

-- todo: add chanbw, dev, api to .conf file
ABB.conf = {}
ABB.conf.chbw = 8
ABB.conf.dev = 'wlan0'
ABB.conf.api = 'nl80211'
ABB.conf.bar_inactive = 3000

-- limit min time interval
-- with 2s, return last cache
-- over 2s, read new
ABB.conf.intl = 2


-- todo: cache data into files
ABB.cache = {}
ABB.cache._iw = nil
ABB.cache._abb_file = nil
ABB.cache._ts = nil


-- get
function ABB.RAW()
	ABB.init()

	local _data = ABB.raw.read()
	local _peer = ABB.raw.peers()

	_data.peers = _peer or {}

	return _data
end

function ABB.JSON_Peers(_peers)
	local _fmt_peer = '{"mac": "%s", "ip": "%s", "signal": %d, "noise": %d, '
		.. '"tx_mcs": %d, "tx_br": %.1f, "tx_short_gi": %d, '
		.. '"rx_mcs": %d, "rx_br": %.1f, "rx_short_gi": %d, '
		.. '"inactive": %d }'

	local _json = 'null'
	if (type(_peers) == 'table' and #_peers > 0) then
		_json = '['

		local idx, peer
		for idx, peer in pairs(_peers) do
			if (peer) then
				if (_json ~= '[') then
					_json = _json .. ','
				end

				local _peer_json = string.format(_fmt_peer, peer.mac, peer.ip, peer.signal, peer.noise,
					peer.tx_mcs, peer.tx_br, peer.tx_short_gi,
					peer.rx_mcs, peer.rx_br, peer.rx_short_gi,
					peer.inactive)
				_json = _json .. _peer_json
			end
		end

		_json = _json .. ']'
	end
	return _json
end

function ABB.JSON()
	local abb = ABB.RAW()
	local _fmt_abb = '{"bssid": "%s","ssid":"%s","mode":"%s",'
		.. '"encrypt":"%s","signal":%d,"noise":%d,"peers_qty":%d,"peers":%s}'

	local _peers = abb.peers
	local _peers_json = ABB.JSON_Peers(_peers)
	local _json_abb = string.format(_fmt_abb, abb.bssid or '-', abb.ssid or '-', abb.mode,
			abb.encrypt or '-', abb.signal, abb.noise, #_peers or 0, _peers_json)

	return _json_abb
end



-- init iw when first time use
function ABB.init()
	if (ABB.cache.iw == nil) then
		local _dev = ABB.conf.dev or 'wlan0'
		local _api = ABB.conf.api or 'nl80211'
		ABB.cache._iw = _iwinfo[_api]
	end
end


ABB.raw = {}

function ABB.raw.read()
	local _abb = {}

	local _dev = ABB.conf.dev or 'wlan0'
	local _iw = ABB.cache._iw
	local _bw = ABB.conf.chbw

	local _mode = ABB.raw.mode(_iw.mode(_dev))
	local enc = _iw.encryption(_dev)


	local bssid, ssid
	if (_mode == 'Mesh Point') then
		-- fix issue#22
		bssid = cmd.exec('ifconfig wlan0 | grep wlan0 -m1 | awk \'{print $5}\' | tr -d "\n"')
		ssid = cmd.exec('uci get wireless.@wifi-iface[0].mesh_id > /tmp/.grid_meshid; cat /tmp/.grid_meshid | tr -d "\n"')
	else
		bssid = _iw.bssid(_dev)
		ssid = _iw.ssid(_dev)
	end
	local noise = fmt.n(_iw.noise(_dev))
	if (noise == 0) then
		noise = -101 -- gws4k noise=0
	end

	local signal = fmt.n(_iw.signal(_dev))
	-- fix issue#6
	if (signal == 0) then
		signal = noise
	end
	local br = fmt.n(_iw.bitrate(_dev))/1024*(_bw/20) -- Mbit*(8/20)

	-- get & save
	_abb.ssid = ssid or '(unknown ssid)'
	_abb.bssid = bssid or '(unknown bssid)'
	_abb.signal = signal or noise
	_abb.noise = noise
	_abb.chbw = _bw
	_abb.mode =  _mode
	local _encrypt = enc and enc.description or ''
	if (_encrypt == 'None') then
		_abb.encrypt = '-'
	end

	ABB.cache._abb = _abb
	ABB.cache._ts = os.time()

	return _abb
end

function ABB.raw.Noise()
	local _dev = ABB.conf.dev or 'wlan0'
	local _iw = ABB.cache._iw
	local noise = fmt.n(_iw.noise(_dev))
	if (noise == 0) then
		noise = -101 -- gws4k noise=0
	end
	return noise
end

function ABB.raw.mode(_mode)
	if (_mode == 'Master') then
		return 'CAR'
	elseif (_mode == 'Client') then
		return 'EAR'
	else
		return _mode
	end
end

-- foreach peer(s), save
function ABB.raw.peers()
	local _peers = {}

	local _dev = ABB.conf.dev or 'wlan0'
	local _iw = ABB.cache._iw
	local _bssid = ABB.cache._iw or 'unknown bssid'

	-- 2017.03.06
	local al = _iw.assoclist(_dev)
	local bssid = _iw.bssid(_dev)
	local noise = fmt.n(_iw.noise(_dev))
	if (noise == 0) then
		noise = -101 -- gws4k noise=0
	end

	local ai, ae
	if al and next(al) then
		for ai, ae in pairs(al) do
			local _peer = {}
			_peer.bssid = _bssid
			_peer.mac = fmt.s(ai) or 'unknown device'
			_peer.ip = ''

			_peer.signal = fmt.n(ae.signal)
			if (_peer.signal ~= 0) then
				_peer.noise = noise

				_peer.tx_mcs = fmt.n(ae.tx_mcs) or -1
				_peer.tx_br = fmt.n(ae.tx_rate)/1024*(8/20) or 0
				_peer.tx_short_gi = fmt.n(ae.tx_short_gi) or -1

				_peer.rx_mcs = fmt.n(ae.rx_mcs) or -1
				_peer.rx_br = fmt.n(ae.rx_rate)/1024*(8/20) or 0
				_peer.rx_short_gi = fmt.n(ae.rx_short_gi) or -1

				_peer.inactive = fmt.n(ae.inactive) or -1

				if (_peer.inactive < ABB.conf.bar_inactive) then
					table.insert(_peers, _peer)
				end
			end
		end
	end

	return _peers
end

return ABB
