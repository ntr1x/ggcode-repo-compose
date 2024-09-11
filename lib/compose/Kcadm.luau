local Project = require('core/Project')
local Meta = require('core/Meta')
local Realm = require('compose/kcadm/Realm')
local Client = require('compose/kcadm/Client')
local User = require('compose/kcadm/User')
local Group = require('compose/kcadm/Group')
local Role = require('compose/kcadm/Role')
local Member = require('compose/kcadm/Member')
local Grant = require('compose/kcadm/Grant')

local Kcadm = {
  __type = 'Kcadm',

  Realm = Realm,
  Client = Client,
  User = User,
  Group = Group,
  Role = Role,
  Member = Member,
  Grant = Grant,

  project = nil,
  realm = nil,
  clients = nil,
  users = nil,
  groups = nil,
  roles = nil,
  members = nil,
  grants = nil,
}

function Kcadm:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Kcadm:from(project: Project)
  assert(project ~= nil)
  return Kcadm
    :new({
      project = project,
      realm = nil,
      clients = Meta:array {},
      users = Meta:array {},
      groups = Meta:array {},
      roles = Meta:array {},
      members = Meta:array {},
      grants = Meta:array {},
    })
end

function Kcadm:with_rules(children: table)
  children = children or {}

  for _, child in children do
    if child.__type == 'Realm' then
      self.realm = child
    elseif child.__type == 'Client' then
      self.clients[#self.clients + 1] = child
    elseif child.__type == 'User' then
      self.users[#self.users + 1] = child
    elseif child.__type == 'Group' then
      self.groups[#self.groups + 1] = child
    elseif child.__type == 'Role' then
      self.roles[#self.roles + 1] = child
    elseif child.__type == 'Member' then
      self.members[#self.members + 1] = child
    elseif child.__type == 'Grant' then
      self.grants[#self.grants + 1] = child
    end
  end

  return self
end

function Kcadm:unwrap_array(array: table)
  local children = Meta:array {}
  for _, child in array do
    children[#children + 1] = child:unwrap()
  end
  return children
end

function Kcadm:unwrap()
  return {
    project = self.project:unwrap_project(),
    realm = self.realm:unwrap(),
    clients = self:unwrap_array(self.clients),
    users = self:unwrap_array(self.users),
    groups = self:unwrap_array(self.groups),
    roles = self:unwrap_array(self.roles),
    members = self:unwrap_array(self.members),
    grants = self:unwrap_array(self.grants),
  }
end

return Kcadm