local Server = require('compose/pgadmin/Server')

function build (entries: table)
  local servers = {}

  for i, entry in entries do
    if typeof(entry) == 'table' and entry.__type == 'Server' then
      local server = entry
      servers[#servers + 1] = server:unwrap()
    end
  end

  return {
    servers = servers
  }
end

return {
  Server = Server,
  build = build
}
