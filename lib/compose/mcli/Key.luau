local Meta = require('core/Meta')

local Key = {
  __type = 'Key',
  username = nil,
  access_key = nil,
  secret_key = nil,
}

function Key:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Key:from(username: string, access_key: string, secret_key: string)
  return Key:new({
    username = username,
    access_key = access_key,
    secret_key = secret_key,
  })
end

function Key:unwrap()
  return {
    username = self.username,
    access_key = self.access_key,
    secret_key = self.secret_key,
  }
end

return Key
