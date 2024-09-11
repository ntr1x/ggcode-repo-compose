local Project = require('core/Project')
local Meta = require('core/Meta')
local Server = require('compose/pgadmin/Server')

local Pgadmin = {
  __type = 'Pgadmin',

  Server = Server,

  project = nil,
  servers = nil,
}

function Pgadmin:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Pgadmin:from(project: Project)
  assert(project ~= nil)
  return Pgadmin
    :new({
      project = project,
      servers = Meta:array {}
    })
end

function Pgadmin:with_rules(children: table)
  children = children or {}

  for _, child in children do
    if child.__type == 'Server' then
      self.servers[#self.servers + 1] = child
    end
  end

  return self
end

function Pgadmin:unwrap_array(array: table)
  local children = Meta:array {}
  for _, child in array do
    children[#children + 1] = child:unwrap()
  end
  return children
end

function Pgadmin:unwrap()
  return {
    project = self.project:unwrap_project(),
    servers = self:unwrap_array(self.servers),
  }
end

return Pgadmin