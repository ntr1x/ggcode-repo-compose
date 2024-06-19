local Project = require('core/Project')
local Meta = require('core/Meta')
local Database = require('compose/postgres/Database')

local Postgres = {
  __type = 'Postgres',

  Database = Database,

  project = nil,
  databases = nil,
}

function Postgres:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Postgres:from(project: Project)
  assert(project ~= nil)
  return Postgres
    :new({
      project = project,
      databases = Meta:array {}
    })
end

function Postgres:with_rules(children: table)
  children = children or {}

  for _, child in children do
    if child.__type == 'Database' then
      self.databases[#self.databases + 1] = child
    end
  end

  return self
end

function Postgres:unwrap_array(array: table)
  local children = Meta:array {}
  for _, child in array do
    children[#children + 1] = child:unwrap()
  end
  return children
end

function Postgres:unwrap()
  return {
    project = self.project:unwrap_project(),
    databases = self:unwrap_array(self.databases),
  }
end

return Postgres
