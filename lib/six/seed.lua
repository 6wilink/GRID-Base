-- random
-- by Qige
-- 2017.01.05 - 2017.03.23

local seed = {}

function seed.seed()
  return tostring(os.time()):reverse():sub(1, 6)
end

function seed.random(from, to)
  math.randomseed(seed.seed())
  return math.random(from, to)
end

return seed
