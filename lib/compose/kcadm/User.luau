local Meta = require('core/Meta')
local URI = require('core/URI')

local User = {
  __type = 'User',
  email = nil,
  username = nil,
  password = nil,
}

function User:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function User:from_credentials(email: string, password: string)
  local username, host = email:match("([^@]*)@(.*)")
  return User:new({
    username = username,
    email = email,
    password = password
  })
end

function User:unwrap()
  return {
    email = self.email,
    username = self.username,
    password = self.password,
  }
end

return User
