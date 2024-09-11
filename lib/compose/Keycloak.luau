local Project = require('core/Project')
local Meta = require('core/Meta')
local Path = require('core/Path')
local URI = require('core/URI')

local Keycloak = {
  __type = 'Keycloak',

  project = nil,
  environment = nil,
  depends_on = nil,
  links = nil,
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
      environment = Meta:table {},
      depends_on = Meta:array {},
      links = Meta:array {},
    })
    :with_datasource(datasource)
end

function Keycloak:with_env_variables(environment: table)
  environment = environment or Meta:table {}

  for name, value in environment do
    self.environment[name] = value
  end

  return self
end

function Keycloak:with_env_variable(name: string, value: string)
  self.environment[name] = value
  return self
end

function Keycloak:with_datasource(datasource: table)
  assert(datasource.uri ~= nil)
  local uri = URI:parse_jdbc(datasource.uri)
  local database = Path:parse(uri.path):normalize():path()
  self.environment.KEYCLOAK_DATABASE_HOST = uri.hostname
  self.environment.KEYCLOAK_DATABASE_PORT = tonumber(uri.port)
  self.environment.KEYCLOAK_DATABASE_NAME = database
  self.environment.KEYCLOAK_DATABASE_USER = datasource.username
  self.environment.KEYCLOAK_DATABASE_PASSWORD = datasource.password
  return self
end

function Keycloak:with_depends_on(name: string)
  self.depends_on[#self.depends_on + 1] = name
  return self
end

function Keycloak:with_link(link: string)
  self.links[#self.links + 1] = link
  return self
end

function Keycloak:unwrap_depends_on()
  if #self.depends_on > 0 then
    return self.depends_on
  end

  return nil
end

function Keycloak:unwrap_links()
  if #self.links > 0 then
    return self.links
  end

  return nil
end

function Keycloak:unwrap()
  return {
    project = self.project:unwrap_project(),
    service = {
      manifest = {
        environment = self.environment,
        depends_on = self:unwrap_depends_on(),
        links = self:unwrap_links()
      }
    },
  }
end

return Keycloak
