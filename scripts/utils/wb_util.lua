
-- ===========================================================================================
-- LIST
-- ===========================================================================================

-- 遍历元素
local function ForEach (list, fn, length)
  length = length or #list
  for i = 1, length, 1 do
    fn(list[i], i)
  end
  return nil
end

-- 筛选元素
local function Filter (list, fn, length)
  length = length or #list
  local result = {}
  for i = 1, length, 1 do
    if fn(list[i], i) == true then
      table.insert(result, list[i])
    end
  end
  return result
end

-- 查找元素
local function Find (list, fn, length)
  length = length or #list
  for i = 1, length, 1 do
    if fn(list[i], i) == true then
      return list[i], i
    end
  end
  return nil
end

-- 查找元素
local function IndexOf (list, value, length)
  local item, index Find(list, function (item, index)
    return item == value
  end, length)
  return index
end

-- 用于检测数组中的元素是否满足指定条件（函数提供）
local function Some (list, fn, length)
  length = length or #list
  for i = 1, length, 1 do
    if fn(list[i], i) == true then
      return true
    end
  end
  return false
end

-- 用于检测列表所有元素是否都符合指定条件（通过函数提供）
local function Every (list, fn, length)
  length = length or #list
  for i = 1, length, 1 do
    if fn(list[i], i) ~= true then
      return false
    end
  end
  return true
end

-- Map
local function Map (list, fn, length)
  length = length or #list
  local result = {}
  for i = 1, length, 1 do
    table.insert(result, i, fn(list[i], i))
  end
  return result
end

-- 判断列表是否存在值
local function Includes (list, value, length)
  local item, index = Find(list, function (item)
    return item == value
  end, length)
  return item ~= nil
end

-- 结合
local function Join (list, divider, length)
  length = length or #list
  local result = ''
  for i = 1, length, 1 do
    if i ~= 1 then
      result = result .. divider
    end
    result = result .. list[i]
  end
  return result
end
-- ===========================================================================================
-- TABLE
-- ===========================================================================================

-- 查找符合指定条件的元素Key（通过函数提供）
local function FindKey (object, fn)
  for key, item in pairs(object) do
    if fn(item, key) == true then
      return key
    end
  end
  return nil
end

-- ===========================================================================================
-- FUNCTION
-- ===========================================================================================

-- 创建一个调用func的函数，func函数会接收partials附加参数。
local function Bind(func, ...)
  local args = ...
  return function (...)
    return func(args, ...)
  end
end

-- 创建一个函数。提供的 value 包装在 wrapper 函数的第一个参数里。 任何附加的参数都提供给 wrapper 函数。
local function Wrap(value, wrapper)
  if type(value) ~= 'function' then return nil end
  return Bind(wrapper, value)
end




-- ===========================================================================================
-- NUMBER
-- ===========================================================================================


local function Floor (number, precision)
  if type(number) ~= "number" then
    return number
  end
  if math.floor(number) == number then
    return number
  end
  if precision == nil then
    precision = 1
  end
  local n_decimal = 10 ^ precision
  local n_temp = math.floor(number * n_decimal)
  local n_ret = n_temp / n_decimal
  return n_ret
end






return {
  ForEach = ForEach,
  Filter = Filter,
  Find = Find,
  IndexOf = IndexOf,
  Some = Some,
  Every = Every,
  Map = Map,
  Includes = Includes,
  Join = Join,

  FindKey = FindKey,

  Bind = Bind,
  Wrap = Wrap,

  Floor = Floor,
}



