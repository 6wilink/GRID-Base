-- default values
-- by Qige
-- 2016.04.05 - 2017.03.23

local _uci = require 'uci'

local conf = {}


conf.limit = {}

conf.limit.userinput = {}
conf.limit.userinput.length = 128

-- regex for parser
conf.reg = {}
conf.reg.kv1 = "(%w+)%s*:%s*(%w+)"
conf.reg.kv2 = "(%w+)%s*:%s*(%d+)"
conf.reg.kv3 = "(%w+)%s*=%s*(%w+)"

-- read param/option from conf file
conf.file = {}
function conf.file.get(conf, sec, opt)
	if (_uci ~= nil) then
		if (conf ~= nil and sec ~= nil and opt ~= nil) then
			local x = _uci.cursor()
			return x:get(conf, sec, opt)
		end
	end
	return nil
end
function conf.file.all(conf, sec)
	if (_uci ~= nil) then
		if (conf ~= nil and sec ~= nil) then
			local x = _uci.cursor()
			return x:get_all(conf, sec)
		end
	end
	return nil
end

-- todo: need to be verified
function conf.file.set(conf, sec, opt, val)
	if (_uci ~= nil) then
		if (conf ~= nil and sec ~= nil and opt ~= nil and val ~= nil) then
			local x = _uci.cursor()
			x:set(conf, sec, opt, val)
		end
	end
end

return conf

