local Project = require('core/Project')
local Meta = require('core/Meta')

local Minio = {
  __type = 'Minio',

  project = nil,
  environment = nil,
  depends_on = nil,
  links = nil,
}

function Minio:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Minio:from(project: Project)
  assert(project ~= nil)
  return Minio
    :new({
      project = project,
      depends_on = Meta:array {},
      links = Meta:array {},
      environment = environment or Meta:table {},
    })
end

function Minio:with_env_variables(environment: table)
  environment = environment or Meta:table {}

  for name, value in environment do
    self.environment[name] = value
  end

  return self
end

function Minio:with_depends_on(name: string)
  self.depends_on[#self.depends_on + 1] = name
  return self
end

function Minio:with_link(link: string)
  self.links[#self.links + 1] = link
  return self
end

function Minio:unwrap_depends_on()
  if #self.depends_on > 0 then
    return self.depends_on
  end

  return nil
end

function Minio:unwrap_links()
  if #self.links > 0 then
    return self.links
  end

  return nil
end

function Minio:unwrap()
  return {
    project = self.project:unwrap_project(),
    service = {
      manifest = {
        environment = self.environment,
        depends_on = self:unwrap_depends_on(),
        links = self:unwrap_links()
      }
    }
  }
end

return Minio