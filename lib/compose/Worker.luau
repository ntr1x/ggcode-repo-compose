local Project = require('core/Project')
local Meta = require('core/Meta')

local Worker = {
  __type = 'Worker',

  project = nil,
  environment = nil,
  depends_on = nil,
  links = nil,
  image = nil,
  packages = nil,
  volumes = nil,
}

function Worker:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Worker:from(project: Project, name: string, image: string)
  assert(project ~= nil)
  return Worker
    :new({
      project = project,
      name = name,
      image = image,
      depends_on = Meta:array {},
      links = Meta:array {},
      environment = environment or Meta:table {},
      packages = Meta:array {},
      volumes = Meta:array {},
    })
end

function Worker:with_image(image: string)
  self.image = image
  return self
end

function Worker:with_volume(name: string, path: string)
  self.volumes[#self.volumes + 1] = {
    name = name,
    path = path,
  }
  return self
end

function Worker:with_env_variables(environment: table)
  environment = environment or Meta:table {}

  for name, value in environment do
    self.environment[name] = value
  end

  return self
end

function Worker:with_minio_client(client: table)
  assert(client ~= nil)
  assert(client.uri ~= nil)
  assert(client.access_key ~= nil)
  assert(client.secret_key ~= nil)
  return self:with_env_variables({
    MINIO_TARGET_SERVER = client.uri,
    MINIO_ACCESS_KEY = client.access_key,
    MINIO_SECRET_KEY = client.secret_key,
  })
end

function Worker:with_depends_on(name: string)
  self.depends_on[#self.depends_on + 1] = name
  return self
end

function Worker:with_link(link: string)
  self.links[#self.links + 1] = link
  return self
end

function Worker:with_package(package: string)
  self.packages[#self.packages + 1] = package
  return self
end

function Worker:with_packages(collection: table)
  for _, item in collection do
    self.packages[#self.packages + 1] = item
  end
  return self
end

function Worker:unwrap_depends_on()
  if #self.depends_on > 0 then
    return self.depends_on
  end

  return nil
end

function Worker:unwrap_links()
  if #self.links > 0 then
    return self.links
  end

  return nil
end

function Worker:unwrap_volume_refs()
  if #self.volumes > 0 then
    local array = Meta:array {}
    for _, volume in self.volumes do
      array[#array + 1] = volume.name .. ':' .. volume.path
    end
    return array
  end

  return nil
end

function Worker:unwrap_volumes()
  if #self.volumes > 0 then
    local map = Meta:table {}
    for _, volume in self.volumes do
      map[volume.name] = Meta:table {}
    end
    return map
  end

  return nil
end

function Worker:unwrap()
  return {
    project = self.project:unwrap_project(),
    service = {
      name = self.name,
      manifest = {
        image = self.image,
        environment = self.environment,
        depends_on = self:unwrap_depends_on(),
        links = self:unwrap_links(),
        volumes = self:unwrap_volume_refs(),
      }
    },
    container = {
      packages = self.packages
    },
    volumes = self:unwrap_volumes()
  }
end

return Worker
