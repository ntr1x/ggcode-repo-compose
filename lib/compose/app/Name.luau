local Meta = require('core/Meta')

local Name = {
  __type = 'Name',
  name = nil,
}

function Name:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Name:from(name: string)
  return Name:new({
    name = name,
  })
end

function Name:unwrap()
  return {
    name = self.name,
  }
end

return Name
