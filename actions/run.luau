local ggcode = require("ggcode")
local route = require('docker/haproxy/route')

ggcode.generate "@/compose" {
    target = '@examples',
    variables = {
        config = {
            include = {
                { path = "compose/env/env_haproxy.compose.yaml" },
                { path = "compose/env/env_kafka.compose.yaml" },
                { path = "compose/env/env_kafka_ui.compose.yaml" },
                { path = "compose/env/env_pgadmin.compose.yaml" },
                { path = "compose/env/env_postgres.compose.yaml" },
                { path = "compose/env/env_swagger_ui.compose.yaml" },
            }
        }
    }
}

ggcode.generate "@/haproxy" {
    target = '@examples',
    variables = {
        routes = {
            route.route('env_kafka_ui', 'http://kafka-ui.local.example.com') {
                route.proxy('/', 'http://env_kafka_ui:8080', { check = true })
            };
            route.route('env_pgadmin', 'http://pgadmin.local.example.com') {
                route.proxy('/', 'http://env_pgadmin:80', { check = true })
            };
            route.route('env_swagger_ui', 'http://swagger-ui.local.example.com') {
                route.proxy('/', 'http://env_swagger_ui:8080', { check = true });
            };
            route.route('api', 'http://api.local.example.com') {
                route.proxy('/api/service_catalog', 'http://host.docker.internal:8080', { cors = "*", optional = true });
                route.proxy('/api/service_basket', 'http://host.docker.internal:8080', { cors = "*", optional = true });
            };
        }
    }
}

ggcode.generate "@/kafka" {
    target = '@examples',
    variables = {}
}

ggcode.generate "@/kafka_ui" {
    target = '@examples',
    variables = {}
}

ggcode.generate "@/pgadmin" {
    target = '@examples',
    variables = {}
}

ggcode.generate "@/postgres" {
    target = '@examples',
    variables = {}
}

ggcode.generate "@/swagger_ui" {
    target = '@examples',
    variables = {
        config = {
            urls = {
                { name = "Service Catalogue", url = "http://api.local.example.com/api/service_catalog/v3/api-docs" }
            }
        }
    }
}
