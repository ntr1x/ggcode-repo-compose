local Meta = require('core/Meta')

local Service = {
  __type = 'Service',
  name = nil,
  image = nil,
  environment = nil,
  depends_on = nil,
  links = nil,
}

function Service:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Service:from(name: string, image: string, environment: table)
  return Service:new({
    name = name,
    image = image,
    depends_on = Meta:array {},
    links = Meta:array {},
    environment = environment or Meta:table {},
  })
end

function Service:with_env_variable(name: string, value: string)
  self.environment[name] = value
  return self
end

function Service:with_spring_datasource(datasource: table)
  self.environment.SPRING_DATASOURCE_URL = datasource.uri
  self.environment.SPRING_DATASOURCE_USERNAME = datasource.username
  self.environment.SPRING_DATASOURCE_PASSWORD = datasource.password
  return self
end

function Service:with_env_variables(environment: table)
  environment = environment or Meta:table {}

  for name, value in environment do
    self.environment[name] = value
  end

  return self
end

function Service:with_depends_on(name: string)
  self.depends_on[#self.depends_on + 1] = name
  return self
end

function Service:with_link(link: string)
  self.links[#self.links + 1] = link
  return self
end

function Service:unwrap_depends_on()
  if #self.depends_on > 0 then
    return self.depends_on
  end

  return nil
end

function Service:unwrap_links()
  if #self.links > 0 then
    return self.links
  end

  return nil
end

function Service:unwrap()
  return {
    service = {
      name = self.name,
      manifest = {
        image = self.image,
        environment = self.environment,
        depends_on = self:unwrap_depends_on(),
        links = self:unwrap_links()
      }
    }
  }
end

return Service
