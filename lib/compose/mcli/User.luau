local Meta = require('core/Meta')

local User = {
  __type = 'User',
  username = nil,
  password = nil,
}

function User:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function User:from(username: string, password: string)
  return User:new({
    username = username,
    password = password,
  })
end

function User:unwrap()
  return {
    username = self.username,
    password = self.password,
  }
end

return User
