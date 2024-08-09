local Meta = require('core/Meta')

local Bucket = {
  __type = 'Bucket',
  name = nil,
  anonymous_access = nil,
}

function Bucket:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Bucket:from(name: string)
  return Bucket:new({
    name = name,
    anonymous_access = Meta:array {},
    events = Meta:array {},
  })
end

function Bucket:with_anonymous_access(command: string)
  self.anonymous_access[#self.anonymous_access + 1] = command
  return self
end

function Bucket:unwrap()
  return {
    name = self.name,
    anonymous_access = self.anonymous_access,
  }
end

return Bucket
