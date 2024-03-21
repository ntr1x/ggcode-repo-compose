local Route = require('compose/haproxy/Route')
local Proxy = require('compose/haproxy/Proxy')
local Server = require('compose/haproxy/Server')

function build (entries: table)
  local routes = {}

  for i, entry in entries do
    if typeof(entry) == 'table' and entry.__type == 'Route' then
      local route = entry
      routes[#routes + 1] = route:unwrap()
    end
  end

  return {
    routes = routes
  }
end

return {
  Route = Route,
  Proxy = Proxy,
  Server = Server,
  build = build
}
