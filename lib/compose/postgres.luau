local Database = require('compose/postgres/Database')

function build (entries: table)
  local databases = {}

  for i, entry in entries do
    if typeof(entry) == 'table' and entry.__type == 'Database' then
      local database = entry
      databases[#databases + 1] = database:unwrap()
    end
  end

  return {
    databases = databases
  }
end

return {
  Database = Database,
  build = build
}
