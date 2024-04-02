local Meta = require('core/Meta')

local users_array = {
  {
    id = uuid:v4(),
    createdTimestamp = 1711174714715,
    username = "service-account-" .. client.id,
    enabled = true,
    totp = false,
    emailVerified = false,
    serviceAccountClientId = client.id,
    credentials = Meta:array {},
    disableableCredentialTypes = Meta:array {},
    requiredActions = Meta:array {},
    realmRoles = {
      "default-roles-" .. realm.name
    },
    clientRoles = {
      [client.id] = { "uma_protection" }
    },
    notBefore = 0,
    groups = Meta:array {}
  }
}

for i, user in users do

  local attributes = nil
  if user.attributes ~= nil then
    attributes = Meta:array {}
    for k, v in user.attributes do
      if typeof(v) == 'array' then
        local arr = Meta:array {}
        for i, item in v do
          arr[#arr + 1] = tostring(item)
        end
        attributes[k] = v
      else
        arr = { tostring(v) }
        attributes[k] = arr
      end
    end
  end

  local groups = nil
  if user.groups ~= nil then
    groups = Meta:array {}
    for k, v in user.groups do
      groups[#groups + 1] = '/' .. v
    end
  end

  users_array[#users_array + 1] = {
    id = uuid:v4(),
    createdTimestamp = 1711174198416,
    username = user.username,
    enabled = true,
    totp = false,
    emailVerified = true,
    firstName = user.first_name,
    lastName = user.last_name,
    email = user.email,
    attributes = attributes,
    credentials = [
      {
        id = uuid:v4(),
        type = "password",
        userLabel = "My password",
        createdDate = 1711174312813,
        secretData = "{\"value\":\"WADXnOKD3XWBVxKm6Epd0zDrX6VLtfUqCqr6kEYOZJk=\",\"salt\":\"fEoKq4PPNx8nWGN7weCp0A==\",\"additionalParameters\":{}}",
        credentialData = "{\"hashIterations\":27500,\"algorithm\":\"pbkdf2-sha256\",\"additionalParameters\":{}}"
      }
    ],
    disableableCredentialTypes = Meta:array {},
    requiredActions = Meta:array {},
    realmRoles = [
      "default-roles-" .. realm.name
    ],
    notBefore = 0,
    groups = groups
  }
end

json:stringify({
  realm = realm.name,
  users = users_array
})
