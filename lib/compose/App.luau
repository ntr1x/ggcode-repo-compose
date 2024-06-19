local Project = require('core/Project')
local Meta = require('core/Meta')

local App = {
  __type = 'App',

  project = nil,
  name = nil,
  image = nil,
  environment = nil,
  depends_on = nil,
  links = nil,
}

function App:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function App:from(project: Project, name: string, image: string, environment: table)
  assert(project ~= nil)
  return App:new({
    project = project,
    name = name,
    image = image,
    depends_on = Meta:array {},
    links = Meta:array {},
    environment = environment or Meta:table {},
  })
end

function App:with_env_variable(name: string, value: string)
  self.environment[name] = value
  return self
end

function App:with_spring_datasource(datasource: table)
  self.environment.SPRING_DATASOURCE_URL = datasource.uri
  self.environment.SPRING_DATASOURCE_USERNAME = datasource.username
  self.environment.SPRING_DATASOURCE_PASSWORD = datasource.password
  return self
end

function App:with_app_openid_client(client: table)
  self.environment.APP_OPENID_CLIENT_CLIENTID = client.client_id
  self.environment.APP_OPENID_CLIENT_CLIENTSECRET = client.client_secret
  self.environment.APP_OPENID_CLIENT_REDIRECTURI = client.redirect_uri
  self.environment.APP_OPENID_CLIENT_ISSUERURI = client.issuer_uri
  return self
end

function App:with_env_variables(environment: table)
  environment = environment or Meta:table {}

  for name, value in environment do
    self.environment[name] = value
  end

  return self
end

function App:with_depends_on(name: string)
  self.depends_on[#self.depends_on + 1] = name
  return self
end

function App:with_link(link: string)
  self.links[#self.links + 1] = link
  return self
end

function App:unwrap_depends_on()
  if #self.depends_on > 0 then
    return self.depends_on
  end

  return nil
end

function App:unwrap_links()
  if #self.links > 0 then
    return self.links
  end

  return nil
end

function App:unwrap()
  return {
    project = self.project:unwrap_project(),
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

return App
