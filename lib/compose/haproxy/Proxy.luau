local Path = require('core/Path')
local Server = require('compose/haproxy/Server')

local Proxy = {
  path = nil,
  cors = nil,
  servers = {},
}

function Proxy:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Proxy:from_path_string(path_string: string)
  local path = Path:from_string(path_string):normalize()
  return Proxy:new({
    path = path:to_string(),
    servers = {},
  })
end

function Proxy:from_uri_string(uri_string: string)
  local server = Server:from_uri_string(uri_string)
  return Proxy:from_path_string('/'):with_server(server)
end

function Proxy:with_cors(cors)
  if type(cors) == 'string' then
    self.cors = { origin = cors }
  elseif type(cors) == 'boolean' and cors then
    self.cors = {}
  elseif type(cors) == 'table' then
    self.cors.origin = cors.origin or '*'
    self.cors.headers = cors.headers or '*'
    self.cors.credentials = cors.credentials or 'true'
    self.cors.methods = cors.methods or 'GET, DELETE, OPTIONS, POST, PUT, PATCH'
  end
  return self
end

function Proxy:with_server(server: table)
  self.servers[#self.servers + 1] = server
  return self
end

-- function Proxy:proxy(path: string, uri: string, options: table)
--   local backend_uri = URI:parse(uri)
--   backend_uri.port = backend_uri.port or 80

--   -- if type(options) == 'table' then
--   --   if type(options.cors) == 'string' then
--   --     options.cors = { origin = options.cors }
--   --   elseif type(options.cors) == 'boolean' and options.cors then
--   --     options.cors = {}
--   --   elseif type(options.cors) == 'table' then
--   --     options.cors.origin = options.cors.origin or '*'
--   --     options.cors.headers = options.cors.headers or '*'
--   --     options.cors.credentials = options.cors.credentials or 'true'
--   --     options.cors.methods = options.cors.methods or 'GET, DELETE, OPTIONS, POST, PUT, PATCH'
--   --   end

--   --   if type(options.check) == 'number' then
--   --     options.check = { port = options.check }
--   --   elseif type(options.check) == 'string' then
--   --     options.check = { port = options.check }
--   --   elseif type(options.check) == 'boolean' and options.check then
--   --     options.check = { port = backend_uri.port }
--   --   elseif type(options.check) == 'table' then
--   --     options.check.port = options.check.port or options.backend_uri.port
--   --   end
--   -- else
--   --   options = {}
--   -- end

--   return Proxy:new({
--     path = path,
--     cors = options.cors or nil,
--     servers = {
--       { hostname = backend_uri.hostname, port = backend_uri.port, check = options.check, optional = options.optional or false }
--     }
--   })
-- end

function Proxy:unwrap()
  local servers = {}
  for i, server in self.servers do
    servers[i] = server:unwrap()
  end
  return {
    path = self.path,
    cors = self.cors,
    servers = servers
  }
end

return Proxy
