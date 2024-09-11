local Meta = require('core/Meta')

local Member = {
  __type = 'Member',
  username = nil,
  group = nil
}

function Member:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Member:from(username: string, group: string)
  return Member:new({
    username = username,
    group = group
  })
end

function Member:unwrap()
  return {
    username = self.username,
    group = self.group
  }
end

return Member
