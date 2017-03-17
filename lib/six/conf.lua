-- default values
-- by Qige
-- 2016.04.05/2017.01.03
-- 2017.01.09/2017.03.13
-- 2017.03.13: add local, change "require 'six.conf'" to "local conf = require 'six.conf'"

local _uci = require 'uci'

local conf = {}

conf.default = {}

conf.default.grid = {}
conf.default.grid.lite = {}
conf.default.grid.lite.user = {}
conf.default.grid.lite.file = 'grid-lite'
conf.default.grid.lite.user.session = '/tmp/.grid_safe_remote'
conf.default.grid.lite.user.username = 'root'
conf.default.grid.lite.user.password = '6Harmonics'
--conf.default.grid.lite.user.remote = '192.168.1.1'

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
	local x = _uci.cursor()
	return x:get(conf, sec, opt)
end
function conf.file.all(conf, sec)
	local x = _uci.cursor()
	return x:get_all(conf, sec)
end

return conf

