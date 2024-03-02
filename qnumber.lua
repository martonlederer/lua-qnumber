---@class QNumber
---@field val number
---@field Q number
---@field K number
local QNumber = {
  utils = {}
}

-- Create a new QNumber instance from a QNumber value
---@param t number QNumber value
---@param Q number Notation
---@return QNumber
function QNumber:new(t, Q)
  ---@type QNumber
  local o = {
    val = t,
    Q = Q,
    K = 1 << (Q - 1)
  }

  setmetatable(o, self)
  self.__index = self

  return o
end

-- Create a new QNumber instance from a Lua number
---@param t number Lua number value
---@param Q? number Notation (8 by default)
---@return QNumber
function QNumber.fromNumber(t, Q)
  if not Q then Q = 8 end

  return QNumber:new(
    (t or 0) * 2 ^ Q,
    Q
  )
end

-- TODO: parse strings

-- Create a new QNumber instance from a string
---@param t string Lua number value
---@param Q? number Notation (8 by default)
---@return QNumber
function QNumber.fromString(t, Q)
  return QNumber.fromNumber(
    tonumber(t) or 0,
    Q
  )
end

-- Shortcuts

-- Shortcut to zero
---@param Q? number
---@return QNumber
function QNumber.zero(Q)
  return QNumber.fromNumber(0, Q)
end

-- Shortcut to one
---@param Q? number
---@return QNumber
function QNumber.one(Q)
  return QNumber.fromNumber(0, Q)
end

-- Convert a QNumber to a different notation
---@param t QNumber Number to convert
---@param Q number Notation
---@return QNumber
function QNumber.convert(t, Q)
  local notationDiff = Q - t.Q

  return QNumber:new(
    t.val * 2 ^ notationDiff,
    Q
  )
end

-- Calculation operators

-- Add together two QNumbers
---@param a QNumber
---@param b QNumber
---@return QNumber
function QNumber.__add(a, b)
  a, b, Q = QNumber.utils.sameQ(a, b)

  return QNumber:new(
    a.val + b.val,
    Q
  )
end

-- Subtract two QNumbers
---@param a QNumber
---@param b QNumber
---@return QNumber
function QNumber.__sub(a, b)
  a, b, Q = QNumber.utils.sameQ(a, b)

  return QNumber:new(
    a.val - b.val,
    Q
  )
end

-- Multiply QNumber a by QNumber b
---@param a QNumber
---@param b QNumber
---@return QNumber
function QNumber.__mul(a, b)
  a, b, Q = QNumber.utils.sameQ(a, b)

  return QNumber:new(
    ((a.val * b.val) + a.K) >> Q,
    Q
  )
end

-- Divide a QNumber by another QNumber
---@param a QNumber
---@param b QNumber
---@return QNumber
function QNumber.__div(a, b)
  a, b, Q = QNumber.utils.sameQ(a, b)
  local res = a.val << Q

  -- we can't use shifting here because of the way Lua handles negative numbers
  if (res >= 0 and b.val >= 0) or (res < 0 and b.val < 0) then
    res = res + b.val / 2
  else
    res = res - b.val / 2
  end

  return QNumber:new(
    res / b.val,
    Q
  )
end

-- Exponential operation
---@param x QNumber
---@param y number
---@return QNumber
function QNumber.__pow(x, y)
  if y == 0 then
    return QNumber.one(x.Q)
  end

  local res = x

  for _ = 2, y do
    res = res * x
  end

  return res
end

-- Negation
---@param x QNumber
---@return QNumber
function QNumber.__unm(x)
  return QNumber:new(
    -x.val,
    x.Q
  )
end

-- Modulo operation
---@param x QNumber
---@param y QNumber
---@return QNumber
function QNumber.__mod(x, y)
  x, y, Q = QNumber.utils.sameQ(x, y)

  return QNumber:new(
    x.val % y.val,
    Q
  )
end

-- Floor division
---@param x QNumber
---@param y QNumber
---@return QNumber
function QNumber.__idiv(x, y)
  x, y, Q = QNumber.utils.sameQ(x, y)

  return (x - (x % y)) / y
end

-- Equation operators

-- Equals operator
---@param a QNumber
---@param b QNumber
---@return boolean
function QNumber.__eq(a, b)
  a, b = QNumber.utils.sameQ(a, b)

  return a.val == b.val
end

-- Lower than operator
---@param a QNumber
---@param b QNumber
---@return boolean
function QNumber.__lt(a, b)
  a, b = QNumber.utils.sameQ(a, b)

  return a.val < b.val
end

-- Less equal operator
---@param a QNumber
---@param b QNumber
---@return boolean
function QNumber.__le(a, b)
  a, b = QNumber.utils.sameQ(a, b)

  return a.val <= b.val
end

-- Conversion

-- Convert a QNumber to a number
-- Note: you will loose precision with this function
---@param x QNumber
---@return number
function QNumber.__tonumber(x)
  return x.val / 2 ^ x.Q
end

-- Convert a QNumber to a string
-- Note: this will not round the number, so you won't loose precision
---@param x QNumber
---@return string
function QNumber.__tostring(x)
  -- TODO
end

-- utilities

-- Bring two QNumbers numbers to the same notation
-- If no notation is provided, it will be set to the
-- larger one from the two QNumbers
---@param a QNumber
---@param b QNumber
---@param Q? number
---@return QNumber, QNumber, number
function QNumber.utils.sameQ(a, b, Q)
  a, b = QNumber.utils.ensure(a, b)

  if not Q then
    Q = math.max(a.Q, b.Q)
  end

  -- convert a and b
  if a.Q ~= Q then
    a = QNumber.convert(a, Q)
  end
  if b.Q ~= Q then
    b = QNumber.convert(b, Q)
  end

  return a, b, Q
end

-- Split string between a character
---@param str string
---@param sep string
---@return ...
function QNumber.utils.split(str, sep)
  local res = {}

  for substr in string.gmatch(str, "([^" .. sep .. "]+)") do
    table.insert(res, substr)
  end

  return table.unpack(res)
end

-- Check if the provided value is a QNumber instance
---@param t any
---@return boolean
function QNumber.utils.isQNumber(t)
  if type(t) ~= "table" then return false end
  if not t.val or not t.Q or not t.K then return false end
  return true
end

-- Ensure that the provided values are QNumber instances
---@param ... any
---@return ...
function QNumber.utils.ensure(...)
  ---@type unknown[]
  local numbers = {...}

  for k, v in ipairs(numbers) do
    if not QNumber.utils.isQNumber(v) then
      numbers[k] = QNumber.fromNumber(tonumber(v) or 0)
    end
  end

  return table.unpack(numbers)
end

return QNumber
