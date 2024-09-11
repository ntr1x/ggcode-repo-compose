local pgadmin = require('compose/pgadmin')

local server = pgadmin.Server:from_datasource({
    uri = 'jdbc:postgresql://localhost:5432/example',
    username = 'ExampleUser',
    password = 'ExamplePa$$w0rd'
})

assert(server.Name == 'example')
assert(server.Group == 'Default')
assert(server.Username == 'ExampleUser')
assert(server.Port == 5432)
assert(server.SSLMode == 'prefer')
assert(server.MaintenanceDB == 'example')
