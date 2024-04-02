local Meta = require('core/Meta')

local Group = {
  __type = 'Group',
  name = nil,
}

function Group:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Group:from(name: string)
  return Group:new({
    name = name,
  })
end

function Group:unwrap()
  return {
    name = self.name,
  }
end

return Group
