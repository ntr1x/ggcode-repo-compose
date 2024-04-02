local Meta = require('core/Meta')
local URI = require('core/URI')

local Role = {
  __type = 'Role',
  name = nil,
  client_name = nil,
}

function Role:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Role:from(name: string)
  return Role:new({
    name = name,
  })
end

function Role:realm(name: string)
  return Role:new({
    name = name,
  })
end

function Role:client(client_name: string, name: string)
  return Role:new({
    name = name,
    client_name = client_name,
  })
end

function Role:unwrap()
  return {
    name = self.name,
    client = self.client_name,
  }
end

return Role
