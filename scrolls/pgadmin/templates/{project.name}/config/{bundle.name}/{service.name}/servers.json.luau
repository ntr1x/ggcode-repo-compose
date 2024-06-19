local result = {
  Servers = {}
}

for i, server in servers do
  result.Servers[`{i}`] = server
end

template:println(json:stringify(result))
