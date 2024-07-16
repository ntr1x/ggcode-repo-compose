local ggcode = require("core/ggcode")
local Project = require('core/Project')
local Haproxy = require('compose/Haproxy')
local Postgres = require('compose/Postgres')
local Pgadmin = require('compose/Pgadmin')
local Keycloak = require('compose/Keycloak')
local Kcadm = require('compose/Kcadm')
local App = require('compose/App')
local Spa = require('compose/Spa')

local project = Project:from('store_starter')

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
  target = '@store',
  variables = {
    project = project:unwrap_project(),
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
        { path = "compose/app/app_admin_ui.compose.yaml" },
      }
    }
  }
}

ggcode.generate "@/haproxy" {
  target = '@store',
  variables = Haproxy
    :from(project)
    :with_rules({
      Haproxy.Route
        :from_arrow('http://kafka-ui.local.example.com', 'http://env_kafka_ui:8080');
      Haproxy.Route
        :from_arrow('http://pgadmin.local.example.com', 'http://env_pgadmin:80');
      Haproxy.Route
        :from_arrow('http://swagger-ui.local.example.com', 'http://env_swagger_ui:8080');
      Haproxy.Route
        :from_arrow('http://auth.local.example.com', 'http://env_keycloak:8080')
        :with_redirect_prefix('/auth');
      Haproxy.Route
        :from_uri_string('http://admin-ui.local.example.com')
        :with_proxies({
          Haproxy.Proxy
            :from_path_string('/')
            :with_server(Haproxy.Server:from_uri_string('http://app_admin_ui:80'):with_optional(true))
            :with_server(Haproxy.Server:from_uri_string('http://host.docker.internal:5173'):with_optional(true):with_backup(true));
        });
      Haproxy.Route
        :from_uri_string('http://api.local.example.com')
        :with_name('api')
        :with_proxies({
          Haproxy.Proxy
            :from_path_string('/api/assembly_web')
            :with_cors('*')
            :with_server(Haproxy.Server:from_uri_string('http://app_assembly_web:8080'):with_optional(true))
            :with_server(Haproxy.Server:from_uri_string('http://host.docker.internal:8080'):with_optional(true):with_backup(true));
          Haproxy.Proxy
            :from_path_string('/api/assembly_web')
            :with_cors('*')
            :with_server(Haproxy.Server:from_uri_string('http://host.docker.internal:8080'):with_optional(true));
          Haproxy.Proxy
            :from_path_string('/api/service_structure')
            :with_cors('*')
            :with_server(Haproxy.Server:from_uri_string('http://host.docker.internal:8081'):with_optional(true));
          Haproxy.Proxy
            :from_path_string('/api/service_catalog')
            :with_cors('*')
            :with_server(Haproxy.Server:from_uri_string('http://host.docker.internal:8082'):with_optional(true));
          Haproxy.Proxy
            :from_path_string('/api/service_profile')
            :with_cors('*')
            :with_server(Haproxy.Server:from_uri_string('http://host.docker.internal:8083'):with_optional(true));
          Haproxy.Proxy
            :from_path_string('/api/service_events')
            :with_cors('*')
            :with_server(Haproxy.Server:from_uri_string('http://host.docker.internal:8084'):with_optional(true));
          Haproxy.Proxy
            :from_path_string('/api/service_payments')
            :with_cors('*')
            :with_server(Haproxy.Server:from_uri_string('http://host.docker.internal:8085'):with_optional(true));
          Haproxy.Proxy
            :from_path_string('/api/service_security')
            :with_cors('*')
            :with_server(Haproxy.Server:from_uri_string('http://host.docker.internal:8086'):with_optional(true));
        });
    })
    :unwrap()
}

ggcode.generate "@/kafka" {
  target = '@store',
  variables = {
    project = project:unwrap_project()
  }
}

ggcode.generate "@/kafka_ui" {
  target = '@store',
  variables = {
    project = project:unwrap_project()
  }
}

ggcode.generate "@/pgadmin" {
  target = '@store',
  variables = Pgadmin
    :from(project)
    :with_rules({
      Pgadmin.Server:from_datasource(datasource_keycloak),
      Pgadmin.Server:from_datasource(datasource_app),
    })
    :unwrap()
}

ggcode.generate "@/postgres" {
  target = '@store',
  variables = Postgres
    :from(project)
    :with_rules({
      Postgres.Database:from_datasource(datasource_keycloak),
      Postgres.Database:from_datasource(datasource_app),
    })
    :unwrap()
}

ggcode.generate "@/keycloak" {
  target = '@store',
  variables = Keycloak
    :from(project, datasource_keycloak):unwrap()
}

ggcode.generate "@/kcadm" {
  target = '@store',
  variables = Kcadm
    :from(project)
    :with_rules({
      Kcadm.Realm:from('application'),

      Kcadm.Client:from(openid_client.client_id, openid_client.client_secret),

      Kcadm.Role:realm('admin'),
      Kcadm.Role:realm('support'),

      Kcadm.Group:from('admin'),
      Kcadm.Group:from('support'),

      Kcadm.User:from_credentials('admin@example.com', 'Qwerty123'),
      Kcadm.User:from_credentials('support01@example.com', 'Qwerty123'),
      Kcadm.User:from_credentials('support02@example.com', 'Qwerty123'),
      Kcadm.User:from_credentials('user01@example.com', 'Qwerty123'),
      Kcadm.User:from_credentials('user02@example.com', 'Qwerty123'),

      Kcadm.Member:from('admin', 'admin'),
      Kcadm.Member:from('support01', 'support'),
      Kcadm.Member:from('support02', 'support'),

      Kcadm.Grant:from('group:admin', 'realm:admin'),
      Kcadm.Grant:from('group:admin', 'realm:support'),
      Kcadm.Grant:from('group:support', 'realm:support'),
    })
    :unwrap()
}

ggcode.generate "@/swagger_ui" {
  target = '@store',
  variables = {
    project = project:unwrap_project(),
    config = {
      urls = {
        { name = "Assembly Web", url = "http://api.local.example.com/api/assembly_web/v3/api-docs" },
        { name = "Service Structure", url = "http://api.local.example.com/api/service_structure/v3/api-docs" },
        { name = "Service Catalogue", url = "http://api.local.example.com/api/service_catalog/v3/api-docs" },
        { name = "Service Profiles", url = "http://api.local.example.com/api/service_profile/v3/api-docs" },
        { name = "Service Events", url = "http://api.local.example.com/api/service_events/v3/api-docs" },
        { name = "Service Payments", url = "http://api.local.example.com/api/service_payments/v3/api-docs" },
        { name = "Service Security", url = "http://api.local.example.com/api/service_security/v3/api-docs" },
      }
    }
  }
}

ggcode.generate "@/app" {
  target = '@store',
  variables = App
    :from(project, 'app_assembly_web', 'store/assembly_web:1.0-SNAPSHOT')
    :with_depends_on('env_kafka')
    :with_depends_on('env_postgres')
    :with_depends_on('env_keycloak')
    :with_spring_datasource(datasource_app)
    :with_app_openid_client(openid_client)
    :with_env_variable('JAVA_OPTS', '-Xmx512m -Xms256m')
    :with_env_variable('SPRING_KAFKA_BOOTSTRAP_SERVERS', 'env_kafka:29092')
    :with_link('env_haproxy:auth.local.example.com')
    -- :with_env_variable('SPRING_SECURITY_OAUTH2_RESOURCESERVER_JWT_ISSUERURI', 'http://env_keycloak:8080/auth/realms/application')
    :unwrap()
}

ggcode.generate "@/spa" {
  target = '@store',
  variables = Spa
    :from(project, 'app_admin_ui', 'store/admin_ui:1.0-SNAPSHOT')
    :unwrap()
}
