local Path = require('util/path')

local Server = {
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

function Server:from_database(db: table)
  local uri = db.uri
  return Server:new({
    Name = db.name,
    Port = db.port,
    Username = db.username,
    Host = db.host,
  })
end

return {
  Server = Server,
}
