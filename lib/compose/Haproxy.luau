local Project = require('core/Project')
local Meta = require('core/Meta')
local Route = require('compose/haproxy/Route')
local Proxy = require('compose/haproxy/Proxy')
local Server = require('compose/haproxy/Server')

local Haproxy = {
  __type = 'Haproxy',

  Route = Route,
  Proxy = Proxy,
  Server = Server,

  project = nil,
  routes = nil,
}

function Haproxy:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Haproxy:from(project: Project)
  assert(project ~= nil)
  return Haproxy
    :new({
      project = project,
      routes = Meta:array {},
    })
end

function Haproxy:with_rules(children: table)
  children = children or {}

  for _, child in children do
    if child.__type == 'Route' then
      self.routes[#self.routes + 1] = child
    end
  end

  return self
end

function Haproxy:unwrap_array(array: table)
  local children = Meta:array {}
  for _, child in array do
    children[#children + 1] = child:unwrap()
  end
  return children
end

function Haproxy:unwrap()
  return {
    project = self.project:unwrap_project(),
    routes = self:unwrap_array(self.routes),
  }
end

return Haproxy
