local URI = require('core/URI')

local Server = {
  hostname = nil,
  port = nil,
  check = true,
  optional = false,
  backup = false,
}

function Server:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Server:from_uri_string(uri_string: string)
  local uri = URI:parse(uri_string)
  local port = tonumber(uri.port)
  return Server:new({
    hostname = uri.hostname,
    port = port,
  })
end

function Server:with_check(check)
  if type(check) == 'number' then
    self.check = { port = check }
  elseif type(check) == 'string' then
    self.check = { port = tonumber(check) }
  elseif type(check) == 'boolean' then
    if check then
      self.check = {}
    else
      self.check = nil
    end
  elseif type(check) == 'table' then
    self.check = {
      port = check.port
    }
  end
  return self
end

function Server:with_optional(optional: boolean)
  self.optional = optional
  return self
end

function Server:with_backup(backup: boolean)
  self.backup = backup
  return self
end

function Server:unwrap()
  return {
    hostname = self.hostname,
    port = self.port,
    check = self.check,
    optional = self.optional,
    backup = self.backup,
  }
end

return Server
