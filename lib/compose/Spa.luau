local Project = require('core/Project')
local Meta = require('core/Meta')

local Spa = {
  __type = 'Spa',

  project = nil,
  name = nil,
  image = nil,
  environment = nil,
  volumes = nil,
}

function Spa:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Spa:from(project: Project, name: string, image: string, environment: table)
  assert(project ~= nil)
  return Spa:new({
    project = project,
    name = name,
    image = image,
    volumes = Meta:array {},
    environment = environment or Meta:table {},
  })
end

function Spa:with_env_variable(name: string, value: string)
  self.environment[name] = value
  return self
end

function Spa:with_env_variables(environment: table)
  environment = environment or Meta:table {}

  for name, value in environment do
    self.environment[name] = value
  end

  return self
end

function Spa:unwrap_volumes()
  return Meta:array {
    '../../config/app/' .. self.name .. '/templates:/etc/nginx/templates'
  }
end

function Spa:unwrap()
  return {
    project = self.project:unwrap_project(),
    service = {
      name = self.name,
      manifest = {
        image = self.image,
        environment = self.environment,
        volumes = self:unwrap_volumes(),
      }
    }
  }
end

return Spa
