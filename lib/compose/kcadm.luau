local Meta = require('core/Meta')
local Realm = require('compose/kcadm/Realm')
local Client = require('compose/kcadm/Client')
local User = require('compose/kcadm/User')
local Group = require('compose/kcadm/Group')
local Role = require('compose/kcadm/Role')
local Member = require('compose/kcadm/Member')
local Grant = require('compose/kcadm/Grant')

function build (entries: table)
  local realm = nil
  local clients = Meta:array {}
  local users = Meta:array {}
  local groups = Meta:array {}
  local roles = Meta:array {}
  local members = Meta:array {}
  local grants = Meta:array {}

  for i, entry in entries do
    if typeof(entry) == 'table' then
      if entry.__type == 'Realm' then
        realm = entry:unwrap()
      elseif entry.__type == 'Client' then
        clients[#clients + 1] = entry:unwrap()
      elseif entry.__type == 'User' then
        users[#users + 1] = entry:unwrap()
      elseif entry.__type == 'Group' then
        groups[#groups + 1] = entry:unwrap()
      elseif entry.__type == 'Role' then
        roles[#roles + 1] = entry:unwrap()
      elseif entry.__type == 'Member' then
        members[#members + 1] = entry:unwrap()
      elseif entry.__type == 'Grant' then
        grants[#grants + 1] = entry:unwrap()
      end
    end
  end

  return {
    realm = realm,
    clients = clients,
    users = users,
    groups = groups,
    roles = roles,
    members = members,
    grants = grants
  }
end

return {
  Realm = Realm,
  Client = Client,
  User = User,
  Group = Group,
  Role = Role,
  Member = Member,
  Grant = Grant,
  build = build
}
