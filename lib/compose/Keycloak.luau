local Project = require('core/Project')
local Manifest = require('compose/keycloak/Manifest')

local Keycloak = {
  __type = 'Keycloak',

  Manifest = Manifest,

  project = nil,
  manifest = nil,
}

function Keycloak:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Keycloak:from(project: Project, datasource: table)
  assert(project ~= nil)
  return Keycloak
    :new({
      project = project,
      manifest = datasource and Manifest:from_datasource(datasource) or nil
    })
end

function Keycloak:with_manifest(manifest: Manifest)
  self.manifest = manifest
  return self
end

function Keycloak:with_datasource(datasource: table)
  self.manifest = Manifest:from_datasource(datasource)
  return self
end

function Keycloak:with_rules(children: table)
  children = children or {}

  for _, child in children do
    if child.__type == 'Manifest' then
      self.manifest = manifest
    end
  end

  return self
end

function Keycloak:unwrap_service()
  return {
    manifest = self.manifest:unwrap()
  }
end

function Keycloak:unwrap_toolbar()
  local name = self.name
  return {
    name = name,
    name = name,
    snake_name = name,
    camel_name = case.snakeToCamel(name),
    pascal_name = case.snakeToPascal(name),
    kebab_name = case.snakeToKebab(name),
    title_name = case.snakeToTitle(name),
  }
end

function Keycloak:unwrap()
  return {
    project = self.project:unwrap_project(),
    service = self:unwrap_service(),
  }
end

return Keycloak
