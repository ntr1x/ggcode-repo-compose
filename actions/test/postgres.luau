local postgres = require('compose/postgres')

local database = postgres.Database:from_datasource({
    uri = 'jdbc:postgresql://localhost:5432/example',
    username = 'ExampleUser',
    password = 'ExamplePa$$w0rd'
})

assert(database.name == 'example')
assert(database.username == 'ExampleUser')
assert(database.password == 'ExamplePa$$w0rd')
