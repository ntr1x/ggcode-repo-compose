local ggcode = require("core/ggcode")
local haproxy = require('compose/haproxy')
local postgres = require('compose/postgres')
local pgadmin = require('compose/pgadmin')
local keycloak = require('compose/keycloak')

local datasource_keycloak = {
    uri = 'jdbc:postgresql://env_postgres:5432/keycloak',
    username = 'keycloak',
    password = 'keycloak'
}

local datasource_app = {
    uri = 'jdbc:postgresql://env_postgres:5432/app',
    username = 'app',
    password = 'app'
}

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
                { path = "compose/env/env_keycloak.compose.yaml" },
            }
        }
    }
}

ggcode.generate "@/haproxy" {
    target = '@examples',
    variables = haproxy.build {
        haproxy.Route:from_arrow('http://kafka-ui.local.example.com', 'http://env_kafka_ui:8080');
        haproxy.Route:from_arrow('http://pgadmin.local.example.com', 'http://env_pgadmin:80');
        haproxy.Route:from_arrow('http://swagger-ui.local.example.com', 'http://env_swagger_ui:8080');
        haproxy.Route:from_arrow('http://auth.local.example.com', 'http://env_keycloak:8080')
            :with_redirect_prefix('/auth');
        haproxy.Route:from_uri_string('http://api.local.example.com')
            :with_name('api')
            :with_proxies({
                haproxy.Proxy:from_path_string('/api/service_catalog')
                    :with_cors('*')
                    :with_server(haproxy.Server:from_uri_string('http://host.docker.internal:8080'):with_optional(true));
                haproxy.Proxy:from_path_string('/api/service_customers')
                    :with_cors('*')
                    :with_server(haproxy.Server:from_uri_string('http://host.docker.internal:8081'):with_optional(true));
                haproxy.Proxy:from_path_string('/api/service_basket')
                    :with_cors('*')
                    :with_server(haproxy.Server:from_uri_string('http://host.docker.internal:8082'):with_optional(true));
                haproxy.Proxy:from_path_string('/api/service_payments')
                    :with_cors('*')
                    :with_server(haproxy.Server:from_uri_string('http://host.docker.internal:8083'):with_optional(true));
            });
    }
}

ggcode.generate "@/kafka" { target = '@examples' }
ggcode.generate "@/kafka_ui" { target = '@examples' }

ggcode.generate "@/pgadmin" {
    target = '@examples',
    variables = pgadmin.build {
        pgadmin.Server:from_datasource(datasource_keycloak),
        pgadmin.Server:from_datasource(datasource_app),
    }
}

ggcode.generate "@/postgres" {
    target = '@examples',
    variables = postgres.build {
        postgres.Database:from_datasource(datasource_keycloak),
        postgres.Database:from_datasource(datasource_app),
    }
}

ggcode.generate "@/keycloak" {
    target = '@examples',
    variables = keycloak.build {
        keycloak.Manifest:new():with_datasource(datasource_keycloak)
    }
}

ggcode.generate "@/swagger_ui" {
    target = '@examples',
    variables = {
        config = {
            urls = {
                { name = "Service Catalogue", url = "http://api.local.example.com/api/service_catalog/v3/api-docs" },
                { name = "Service Customers", url = "http://api.local.example.com/api/service_customers/v3/api-docs" },
                { name = "Service Basket", url = "http://api.local.example.com/api/service_basket/v3/api-docs" },
                { name = "Service Payments", url = "http://api.local.example.com/api/service_payments/v3/api-docs" },
            }
        }
    }
}
