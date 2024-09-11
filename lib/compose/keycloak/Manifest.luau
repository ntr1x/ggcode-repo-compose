local Path = require('core/Path')
local URI = require('core/URI')

local Manifest = {
  __type = 'Manifest',
  environment = {}
}

function Manifest:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Manifest:from_datasource(datasource: table)
  return Manifest
    :new(o)
    :with_datasource(datasource)
end

function Manifest:with_datasource(datasource: table)
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

function Manifest:unwrap()
  return {
    environment = self.environment,
  }
end

return Manifest
