-- http.find()
-- str.split(), str.trim()
-- table.haskey()
-- echo(), s(), n()
-- by Qige
-- 2016.04.05 - 2017.03.23

local fmt = {}

-- http key=value pairs
-- @return string/nil
fmt.http = {}
function fmt.http.find(key, data)
  if (key and data) then
    local _,_,val = string.find(data, key.."=([%w\.\-\_]*)")
    if (val) then
      return val
    end
  end
  return nil
end

fmt.str = {}
-- string split()
-- @return table/nil
-- @from http://zhaiku.blog.51cto.com/2489043/1163077
function fmt.str.split(delim, str)
  local rt= {}
  if (delim ~= nil and str ~= nil) then
    string.gsub(str, '[^'..delim..']+', function(w) table.insert(rt, w) end)
  end
  return rt
end

-- TODO: trim()
-- @return string/nil
function fmt.str.trim(str)
  if (str ~= nil) then
    local _,_,val = string.find(str, "([a-zA-Z0-9\b]*)")
    if (val) then
      return val
    end
  end
  return str
end

fmt.table = {}
function fmt.table.haskey(table, key)
  return type(table[key] ~= nil)
end


-- printf()
function fmt.echo(fmt, ...)
  io.write(string.format(fmt, ...))
end

-- @return string/"?"
function fmt.s(s)
  if (s == nil) then
    return "?"
  else
    return tostring(s)
  end
end

-- @return integer/0
function fmt.n(x)
  if (x == nil) then
    return 0
  else
    return tonumber(x)
  end
end

return fmt