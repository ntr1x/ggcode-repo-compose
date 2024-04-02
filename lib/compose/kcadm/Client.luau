local Meta = require('core/Meta')

local Client = {
  __type = 'Client',
  name = nil,
  secret = nil,
}

function Client:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Client:from(name: string, secret: string)
  return Client:new({
    name = name,
    secret = secret,
  })
end

function Client:unwrap()
  return {
    name = self.name,
    secret = self.secret,
  }
end

return Client
