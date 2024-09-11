local Meta = require('core/Meta')

local Grant = {
  __type = 'Grant',
  policy = nil,
  username = nil,
}

function Grant:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Grant:from(username: string, policy: string)
  return Grant:new({
    username = username,
    policy = policy,
  })
end

function Grant:unwrap()
  return {
    username = self.username,
    policy = self.policy,
  }
end

return Grant
