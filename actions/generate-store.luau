local ggcode = require("core/ggcode")
local Project = require('core/Project')
local Haproxy = require('compose/Haproxy')
local Postgres = require('compose/Postgres')
local Pgadmin = require('compose/Pgadmin')
local Keycloak = require('compose/Keycloak')
local Minio = require('compose/Minio')
local Kcadm = require('compose/Kcadm')
local Mcli = require('compose/Mcli')
local App = require('compose/App')
local Spa = require('compose/Spa')
local Worker = require('compose/Worker')

local project = Project:from('store_starter')

local datasource_keycloak = {
  uri = 'jdbc:postgresql://env-postgres:5432/keycloak',
  username = 'keycloak',
  password = 'keycloak'
}

local datasource_app = {
  uri = 'jdbc:postgresql://env-postgres:5432/app',
  username = 'app',
  password = 'app'
}

local openid_client = {
  client_id = 'api',
  client_secret = '4Ggxc50xzu5j1qFk5rZ4OPHwvNFXLpNX'
}

local minio_client = {
  uri = 'http://env-minio:9000',
  access_key = 'y5LeRZ84J4SsenpaIxMl',
  secret_key = 'AZitoDkffcEYFYUmV4CGv1jr2fiXWIw4uSvdFlDu'
}

ggcode.generate "@/compose" {
  target = '@store',
  variables = {
    project = project:unwrap_project(),
    config = {
      include = {
        { path = "compose/env/env-haproxy.compose.yaml" },
        { path = "compose/env/env-kafka.compose.yaml" },
        { path = "compose/env/env-kafka-ui.compose.yaml" },
        { path = "compose/env/env-pgadmin.compose.yaml" },
        { path = "compose/env/env-postgres.compose.yaml" },
        { path = "compose/env/env-swagger-ui.compose.yaml" },
        { path = "compose/env/env-keycloak.compose.yaml" },
        { path = "compose/env/env-kcadm.compose.yaml" },
        { path = "compose/env/env-minio.compose.yaml" },
        { path = "compose/env/env-mcli.compose.yaml" },
        { path = "compose/app/app-assembly-web.compose.yaml" },
        { path = "compose/app/app-admin-ui.compose.yaml" },
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
        :from_arrow('http://kafka-ui.local.example.com', 'http://env-kafka-ui:8080');
      Haproxy.Route
        :from_arrow('http://pgadmin.local.example.com', 'http://env-pgadmin:80');
      Haproxy.Route
        :from_arrow('http://swagger-ui.local.example.com', 'http://env-swagger-ui:8080');
      Haproxy.Route
        :from_arrow('http://auth.local.example.com', 'http://env-keycloak:8080')
        :with_redirect_prefix('/auth');
      Haproxy.Route
        :from_arrow('http://minio.local.example.com', 'http://env-minio:9000');
      Haproxy.Route
        :from_arrow('http://minio-ui.local.example.com', 'http://env-minio:9001');
      Haproxy.Route
        :from_uri_string('http://admin-ui.local.example.com')
        :with_proxies({
          Haproxy.Proxy
            :from_path_string('/')
            :with_server(Haproxy.Server:from_uri_string('http://app-admin-ui:80'):with_optional(true))
            :with_server(Haproxy.Server:from_uri_string('http://host.docker.internal:5173'):with_optional(true):with_backup(true));
        });
      Haproxy.Route
        :from_uri_string('http://api.local.example.com')
        :with_name('api')
        :with_proxies({
          Haproxy.Proxy
            :from_path_string('/api/assembly_web')
            :with_cors('*')
            :with_server(Haproxy.Server:from_uri_string('http://app-assembly-web:8080'):with_optional(true))
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
          Haproxy.Proxy
            :from_path_string('/api/service_uploads')
            :with_cors('*')
            :with_server(Haproxy.Server:from_uri_string('http://host.docker.internal:8087'):with_optional(true));
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

ggcode.generate "@/kafka-ui" {
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
    :from(project, datasource_keycloak)
    :unwrap()
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

ggcode.generate "@/minio" {
  target = '@store',
  variables = Minio
    :from(project)
    :with_link('env-haproxy:minio.local.example.com')
    :unwrap()
}

ggcode.generate "@/mcli" {
  target = '@store',
  variables = Mcli
    :from(project)
    :with_rules({
      Mcli.User:from('api', 'Qwerty123'),

      Mcli.Grant:from('api', 'readwrite'),

      Mcli.Key:from('api', 'y5LeRZ84J4SsenpaIxMl', 'AZitoDkffcEYFYUmV4CGv1jr2fiXWIw4uSvdFlDu'),

      Mcli.Bucket:from('app-product-image')
        :with_anonymous_access('download'),
      Mcli.Bucket:from('app-product-image-variant')
        :with_anonymous_access('download'),

      Mcli.Bucket:from('app-public-image')
        :with_anonymous_access('download'),
      Mcli.Bucket:from('app-public-document')
        :with_anonymous_access('download'),

      Mcli.Bucket:from('onec-employee-table'),

      Mcli.KafkaTarget
        :from('app_product_image')
        :with_broker('env-kafka:29092')
        :with_topic('app_product_image')
        :with_event('app-product-image', 'put')
        :with_event('app-product-image', 'delete'),

      Mcli.KafkaTarget
        :from('onec_employee_table')
        :with_broker('env-kafka:29092')
        :with_topic('onec_employee_table')
        :with_event('onec-employee-table', 'put'),
    })
    :unwrap()
}

ggcode.generate "@/swagger-ui" {
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
        { name = "Service Uploads", url = "http://api.local.example.com/api/service_uploads/v3/api-docs" },
      }
    }
  }
}

ggcode.generate "@/app" {
  target = '@store',
  variables = App
    :from(project, 'app-assembly-web', 'store/assembly_web:1.0-SNAPSHOT')
    :with_depends_on('env-kafka')
    :with_depends_on('env-postgres')
    :with_depends_on('env-keycloak')
    :with_depends_on('env-minio')
    :with_spring_datasource(datasource_app)
    :with_app_openid_client(openid_client)
    :with_app_minio_client(minio_client)
    :with_env_variable('JAVA_OPTS', '-Xmx512m -Xms256m')
    :with_env_variable('SPRING_KAFKA_BOOTSTRAP_SERVERS', 'env-kafka:29092')
    :with_env_variable('APP_MINIO_BUCKETS_0_NAME', 'app-public-document')
    :with_env_variable('APP_MINIO_BUCKETS_1_NAME', 'app-public-image')
    :with_env_variable('APP_MINIO_BUCKETS_1_UPLOAD_POLICY_CONTENT_TYPE', 'image/')
    :with_env_variable('APP_MINIO_BUCKETS_1_UPLOAD_POLICY_CONTENT_LENGTH', '10M')
    :with_env_variable('APP_MINIO_BUCKETS_2_NAME', 'app-product-image')
    :with_env_variable('APP_MINIO_BUCKETS_2_UPLOAD_POLICY_CONTENT_TYPE', 'image/')
    :with_env_variable('APP_MINIO_BUCKETS_2_UPLOAD_POLICY_CONTENT_LENGTH', '10M')
    :with_link('env-haproxy:auth.local.example.com')
    :unwrap()
}

ggcode.generate "@/spa" {
  target = '@store',
  variables = Spa
    :from(project, 'app-admin-ui', 'store/admin_ui:1.0-SNAPSHOT')
    :unwrap()
}
