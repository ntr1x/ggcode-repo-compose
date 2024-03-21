local URI = require('util/uri')
local Path = require('util/path')
local OBJECT = require('util/object')
local Proxy = require('compose/haproxy/Proxy')

local Route = {
  __type = "Route",
  name = 'default',
  hostname = 'localhost',
  port = 80,
  path = '/',
  redirect = nil,
  proxies = {}
}

function Route:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Route:from_uri_string(uri_string: string)
  local uri = URI:parse(uri_string)
  local name = uri.hostname:gsub('[\.]', '_'):gsub('[-]', '_')
  return Route:new({
    name = name,
    hostname = uri.hostname,
    port = uri.port,
    path = uri.path,
    proxies = {},
  })
end

function Route:with_name(name: string)
  self.name = name
  return self
end

function Route:with_hostname(hostname: string)
  self.hostname = hostname
  return self
end

function Route:with_port(port: number)
  self.port = port
  return self
end

function Route:with_path(path: string)
  self.path = path
  return self
end

function Route:with_proxy(proxy: Proxy)
  self.proxies[#self.proxies + 1] = proxy
  return self
end

function Route:with_proxies(proxies: table)
  for i, proxy in proxies do
    self.proxies[#self.proxies + 1] = proxy
  end
  return self
end

function Route:from_arrow(from_uri_string: string, to_uri_string: string)
  local route = Route:from_uri_string(from_uri_string)
  local proxy = Proxy:from_uri_string(to_uri_string)
  local res = route:with_proxy(proxy)
  return res
end

function Route:with_redirect_prefix(prefix: string, code: number)
  self.redirect = {
    type = 'prefix',
    prefix = prefix,
    code = code or 301
  }
  return self
end

function Route:unwrap()
  local proxies = {}
  for i, proxy in self.proxies do
    proxies[i] = proxy:unwrap()
  end
  return {
    name = self.name,
    hostname = self.hostname,
    path = self.path,
    port = self.port,
    redirect = self.redirect,
    proxies = proxies,
  }
end

return Route