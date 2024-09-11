local Project = require('core/Project')
local Meta = require('core/Meta')
local User = require('compose/mcli/User')
local Key = require('compose/mcli/Key')
local Grant = require('compose/mcli/Grant')
local Bucket = require('compose/mcli/Bucket')
local KafkaTarget = require('compose/mcli/KafkaTarget')

local Mcli = {
  __type = 'Mcli',

  User = User,
  Key = Key,
  Grant = Grant,
  Bucket = Bucket,
  KafkaTarget = KafkaTarget,

  project = nil,
  users = nil,
  keys = nil,
  grants = nil,
  buckets = nil,
  targets = nil,
  anonymous_access = mil,
}

function Mcli:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Mcli:from(project: Project)
  assert(project ~= nil)
  return Mcli
    :new({
      project = project,
      users = Meta:array {},
      keys = Meta:array {},
      grants = Meta:array {},
      buckets = Meta:array {},
      targets = Meta:array {},
      anonymous_access = Meta:array {},
    })
end

function Mcli:with_rules(children: table)
  children = children or {}

  for _, child in children do
    if child.__type == 'User' then
      self.users[#self.users + 1] = child
    elseif child.__type == 'Key' then
      self.keys[#self.keys + 1] = child
    elseif child.__type == 'Grant' then
      self.grants[#self.grants + 1] = child
    elseif child.__type == 'Bucket' then
      self.buckets[#self.buckets + 1] = child
    elseif child.__type == 'KafkaTarget' then
      self.targets[#self.targets + 1] = child
    elseif child.__type == 'AnonymousAccess' then
      self.anonymous_access[#self.anonymous_access + 1] = child
    end
  end

  return self
end

function Mcli:unwrap_array(array: table)
  local children = Meta:array {}
  for _, child in array do
    children[#children + 1] = child:unwrap()
  end
  return children
end

function Mcli:unwrap()
  return {
    project = self.project:unwrap_project(),
    users = self:unwrap_array(self.users),
    keys = self:unwrap_array(self.keys),
    grants = self:unwrap_array(self.grants),
    buckets = self:unwrap_array(self.buckets),
    targets = self:unwrap_array(self.targets),
    anonymous_access = self:unwrap_array(self.anonymous_access),
  }
end

return Mcli