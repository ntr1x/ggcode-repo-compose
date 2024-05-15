local ggcode = require("core/ggcode")
local haproxy = require('compose/haproxy')
local postgres = require('compose/postgres')
local pgadmin = require('compose/pgadmin')
local keycloak = require('compose/keycloak')
local kcadm = require('compose/kcadm')
local app = require('compose/app')

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

local openid_client = {
    client_id = 'api',
    client_secret = '4Ggxc50xzu5j1qFk5rZ4OPHwvNFXLpNX'
}

ggcode.generate "@/compose" {
    target = '@app',
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
                { path = "compose/env/env_kcadm.compose.yaml" },
                { path = "compose/app/app_assembly_web.compose.yaml" },
            }
        }
    }
}

ggcode.generate "@/haproxy" {
    target = '@app',
    variables = haproxy.build {
        haproxy.Route:from_arrow('http://kafka-ui.local.example.com', 'http://env_kafka_ui:8080');
        haproxy.Route:from_arrow('http://pgadmin.local.example.com', 'http://env_pgadmin:80');
        haproxy.Route:from_arrow('http://swagger-ui.local.example.com', 'http://env_swagger_ui:8080');
        haproxy.Route:from_arrow('http://auth.local.example.com', 'http://env_keycloak:8080')
            :with_redirect_prefix('/auth');
        haproxy.Route:from_uri_string('http://api.local.example.com')
            :with_name('api')
            :with_proxies({
                haproxy.Proxy:from_path_string('/api/assembly_web')
                    :with_cors('*')
                    :with_server(haproxy.Server:from_uri_string('http://app_assembly_web:8080'):with_optional(true));
                haproxy.Proxy:from_path_string('/api/service_basket')
                    :with_cors('*')
                    :with_server(haproxy.Server:from_uri_string('http://host.docker.internal:8081'):with_optional(true));
                haproxy.Proxy:from_path_string('/api/service_catalog')
                    :with_cors('*')
                    :with_server(haproxy.Server:from_uri_string('http://host.docker.internal:8082'):with_optional(true));
                haproxy.Proxy:from_path_string('/api/service_customers')
                    :with_cors('*')
                    :with_server(haproxy.Server:from_uri_string('http://host.docker.internal:8083'):with_optional(true));
                haproxy.Proxy:from_path_string('/api/service_events')
                    :with_cors('*')
                    :with_server(haproxy.Server:from_uri_string('http://host.docker.internal:8084'):with_optional(true));
                haproxy.Proxy:from_path_string('/api/service_payments')
                    :with_cors('*')
                    :with_server(haproxy.Server:from_uri_string('http://host.docker.internal:8085'):with_optional(true));
                haproxy.Proxy:from_path_string('/api/service_security')
                    :with_cors('*')
                    :with_server(haproxy.Server:from_uri_string('http://host.docker.internal:8086'):with_optional(true));
            });
    }
}

ggcode.generate "@/kafka" { target = '@app' }
ggcode.generate "@/kafka_ui" { target = '@app' }

ggcode.generate "@/pgadmin" {
    target = '@app',
    variables = pgadmin.build {
        pgadmin.Server:from_datasource(datasource_keycloak),
        pgadmin.Server:from_datasource(datasource_app),
    }
}

ggcode.generate "@/postgres" {
    target = '@app',
    variables = postgres.build {
        postgres.Database:from_datasource(datasource_keycloak),
        postgres.Database:from_datasource(datasource_app),
    }
}

ggcode.generate "@/keycloak" {
    target = '@app',
    variables = keycloak.build {
        keycloak.Manifest:new():with_datasource(datasource_keycloak),
    }
}

ggcode.generate "@/kcadm" {
    target = '@app',
    variables = kcadm.build {
        kcadm.Realm:from('application'),

        kcadm.Client:from(openid_client.client_id, openid_client.client_secret),

        kcadm.Role:realm('admin'),
        kcadm.Role:realm('support'),

        kcadm.Group:from('admin'),
        kcadm.Group:from('support'),

        kcadm.User:from_credentials('admin@example.com', 'Qwerty123'),
        kcadm.User:from_credentials('support01@example.com', 'Qwerty123'),
        kcadm.User:from_credentials('support02@example.com', 'Qwerty123'),
        kcadm.User:from_credentials('user01@example.com', 'Qwerty123'),
        kcadm.User:from_credentials('user02@example.com', 'Qwerty123'),

        kcadm.Member:from('admin', 'admin'),
        kcadm.Member:from('support01', 'support'),
        kcadm.Member:from('support02', 'support'),

        kcadm.Grant:from('group:admin', 'realm:admin'),
        kcadm.Grant:from('group:admin', 'realm:support'),
        kcadm.Grant:from('group:support', 'realm:support'),
    }
}

ggcode.generate "@/swagger_ui" {
    target = '@app',
    variables = {
        config = {
            urls = {
                { name = "Assembly Web", url = "http://api.local.example.com/api/assembly_web/v3/api-docs" },
                { name = "Service Basket", url = "http://api.local.example.com/api/service_basket/v3/api-docs" },
                { name = "Service Catalogue", url = "http://api.local.example.com/api/service_catalog/v3/api-docs" },
                { name = "Service Customers", url = "http://api.local.example.com/api/service_customers/v3/api-docs" },
                { name = "Service Events", url = "http://api.local.example.com/api/service_events/v3/api-docs" },
                { name = "Service Payments", url = "http://api.local.example.com/api/service_payments/v3/api-docs" },
                { name = "Service Security", url = "http://api.local.example.com/api/service_security/v3/api-docs" },
            }
        }
    }
}

local service_assembly_web =

ggcode.generate "@/app" {
    target = '@app',
    variables = app.Service
        :from('app_assembly_web', 'example/assembly_web:1.0-SNAPSHOT')
        :with_depends_on('env_kafka')
        :with_depends_on('env_postgres')
        :with_depends_on('env_keycloak')
        :with_spring_datasource(datasource_app)
        :with_app_openid_client(openid_client)
        :with_env_variable('SPRING_KAFKA_BOOTSTRAP_SERVERS', 'env_kafka:29092')
        :with_link('env_haproxy:auth.local.example.com')
        -- :with_env_variable('SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUERURI', 'http://env_keycloak:8080/auth/realms/application')
        :unwrap()
}
