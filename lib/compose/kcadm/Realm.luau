local Meta = require('core/Meta')

local Realm = {
  __type = 'Realm',
  name = '',
}

function Realm:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Realm:from(name: string)
  return Realm:new({
    name = name,
  })
end

function Realm:unwrap()
  return {
    name = self.name,
  }
end

return Realm
