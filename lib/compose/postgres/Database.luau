local Path = require('util/path')
local URI = require('util/uri')

local Database = {
  __type = 'Database',
  name = 'postgres',
  username = 'postgres',
  password = nil,
}

function Database:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Database:from_datasource(datasource: table)
  assert(datasource.uri ~= nil)
  local uri = URI:parse_jdbc(datasource.uri)
  local database = Path:parse(uri.path):normalize():path()
  return Database:new({
    name = database,
    username = datasource.username,
    password = datasource.password,
  })
end

function Database:unwrap()
  return {
    name = self.name,
    username = self.username,
    password = self.password
  }
end

return Database
