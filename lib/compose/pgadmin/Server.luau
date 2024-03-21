local Path = require('core/Path')
local URI = require('core/URI')

local Server = {
  __type = 'Server',
  Name = 'Postgres',
  Group = 'Default',
  Port = 5432,
  Username = 'postgres',
  Host = 'env_postgres',
  SSLMode = 'prefer',
  MaintenanceDB = 'postgres'
}

function Server:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Server:from_datasource(datasource: table)
  assert(datasource.uri ~= nil)
  local uri = URI:parse_jdbc(datasource.uri)
  local database = Path:parse(uri.path):normalize():path()
  return Server:new({
    Name = database,
    Port = if uri.port == nil then nil else tonumber(uri.port),
    Username = datasource.username,
    Host = uri.hostname,
    MaintenanceDB = database,
  })
end

function Server:unwrap()
  return {
    Name = self.Name,
    Group = self.Group,
    Port = self.Port,
    Username = self.Username,
    Host = self.Host,
    SSLMode = self.SSLMode,
    MaintenanceDB = self.MaintenanceDB
  }
end

return Server
