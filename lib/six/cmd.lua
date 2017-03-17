-- by Qige
-- 2016.04.05
-- 2017.01.03/2017.03.04
-- 2017.03.13: add local, change "require 'six.cmd'" to "local cmd = require 'six.cmd'"

local cmd = {}

function cmd.exec(_pstring)
	local _result

	if (_pstring and string.len(_pstring) > 0) then
		local _sys = io.popen(_pstring)
		_result = _sys:read("*all")

		io.close(_sys)
	end

	return _result
end

function cmd.sleep(sec)
	cmd.exec(string.format("sleep %d", sec))
end

return cmd
