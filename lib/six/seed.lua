-- random
-- by Qige
-- 2017.01.05
-- 2017.03.13: add local, change "require 'six.seed'" to "local seed = require 'six.seed'"

local seed = {}

function seed.seed()
  --return math.randomseed(tostring(os.time()):reverse():sub(1, 6))
  return tostring(os.time()):reverse():sub(1, 6)
end

function seed.random(from, to)
  math.randomseed(seed.seed())
  return math.random(from, to)
end

return seed
