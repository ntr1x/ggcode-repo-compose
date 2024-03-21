local Manifest = require('compose/keycloak/Manifest')

function build (entries: table)
  local service = nil

  for i, entry in entries do
    if typeof(entry) == 'table' and entry.__type == 'Manifest' then
      service = {
        manifest = entry:unwrap()
      }
    end
  end

  return {
    service = service
  }
end

return {
  Manifest = Manifest,
  build = build
}
