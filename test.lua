-- denominator
local n = 8
local K = 1 << (n - 1)

-- convert number represented in Q notation to a Lua float (loose precision)
local function convert(val)
  return val / 2 ^ n
end

-- 1.5 represented in Q notation
local val1 = 384

-- 2 represented in Q notation
local val2 = 512

-- test addition
do
  -- add together two numbers represented in Q notation 
  local result = val1 + val2

  -- it should be 3.5
  assert(convert(result) == 3.5)
end

-- test subtraction
do
  -- subtract two numbers represented in Q notation
  local result = val2 - val1

  -- it should be 0.5
  assert(convert(result) == 0.5)
end

-- test multiplication
do
  -- multiply two numbers represented in Q notation
  local result = ((val1 * val2) + K) >> n

  -- it should be 3
  assert(convert(result) == 3)
end

-- test division
do
  -- divide two numbers represented in Q notation (val1 / val2)
  local a = val1
  local b = val2
  a = a << n

  if (a >= 0 and b >= 0) or (a < 0 and b < 0) then
    a = a + b / 2
  else
    a = a - b / 2
  end

  local res = a / b

  -- it should be 0.75
  assert(convert(res) == 0.75)
end