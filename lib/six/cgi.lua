-- cgi module
-- by Qige
-- 2016.04.05/2017.01.03/2017.01.06
-- 2017.03.13: add local, change "require 'six.cgi'" to "local cgi = require 'six.cgi'"


local conf = require 'six.conf'
local html = require 'six.html'

local cgi = {}

cgi.data = {}
cgi.data._remote = nil
cgi.data._post = nil
cgi.data._get = nil
cgi.data._ts = nil


function cgi.data.remote()
	return os.getenv("REMOTE_ADDR")
end
function cgi.data.ts()
  return tostring(os.time())
end
function cgi.data.post()
	local bytes2read = math.min(tonumber(os.getenv("CONTENT_LENGTH")), tonumber(conf.limit.userinput.length))
	cgi._post = io.read(bytes2read)
	if (cgi._post) then
		return cgi._post
	end
	return nil
end
function cgi.data.get()
	local data = os.getenv("QUERY_STRING")
	if (data and string.len(data) <= conf.limit.userDataLength) then
	--if (data) then
		cgi._get = data
		return cgi._get
	end
	return nil
end


function cgi.Save()
	cgi.data._remote = nil
	cgi.data._post = nil
	cgi.data._get = nil
	cgi.data._ts = nil

	cgi.data._remote = cgi.data.remote()
	cgi.data._post = cgi.data.post()
	cgi.data._get = cgi.data.get()
	cgi.data._ts = cgi.data.ts()
end



cgi.out = {}
function cgi.out.Reply(text)
	io.write("Content-type: text/html\n\n")
	if (text) then
		io.write(text .. '\n')
	end
end

function cgi.out.Echo(text)
  if (text) then
    io.write(text)
  end
end

function cgi.out.Goto(text, url, delay)
	local html = html.goto(url, delay, text)
	if (html) then
		cgi.out.Reply(html)
	else
		cgi.out.Yell()
	end
end

function cgi.out.Yell(msg)
  cgi.out.Reply(string.format('500: server internal error (%s)', msg or '*unknown*'))
end


return cgi

