-- denominator
local n = 8
local K = 1 << (n - 1)

-- convert number represented in Q notation to a Lua float (loose precision)
local function convert(val)
  return val / 2 ^ n
end

local function encode(val)
  return val * 2 ^ n
end

-- 1.5 represented in Q notation
local val1 = encode(1.5)

-- 2 represented in Q notation
local val2 = encode(2)

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
  print(convert(res))
  --assert(convert(res) == 0.75)
end

local QNumber = require "qnumber"

do
  local a = QNumber.fromNumber(2)
  local b = QNumber.fromNumber(3)

  ---@type QNumber
  local res = a + b

  print(tostring(QNumber.__tonumber(res)))
end

do
  local a = QNumber.fromNumber(5)
  local b = QNumber.fromNumber(3)

  ---@type QNumber
  local res = a - b

  print(tostring(QNumber.__tonumber(res)))
end

do
  local a = QNumber.fromNumber(7)
  local b = QNumber.fromNumber(3)

  ---@type QNumber
  local res = a * b

  print(tostring(QNumber.__tonumber(res)))
end

do
  local a = QNumber.fromNumber(18)
  local b = QNumber.fromNumber(3)

  ---@type QNumber
  local res = a / b

  print(tostring(QNumber.__tonumber(res)))
end

do
  local a = QNumber.fromNumber(17)
  local b = QNumber.fromNumber(14)
  local c = QNumber.fromNumber(14)

  assert((a == b) == false)
  assert(b < a)
  assert(b <= c)
  assert((a < b) == false)
end

do
  local x = QNumber.fromNumber(2)

  print(QNumber.__tonumber(x ^ 2))
end

do
  local x = QNumber.fromNumber(6)

  print(QNumber.__tonumber(-x))
end

do
  local x = QNumber.fromNumber(1.7)
  local y = QNumber.fromNumber(1)

  print(QNumber.__tonumber(x % y))
end