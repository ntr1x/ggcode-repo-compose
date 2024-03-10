local route = require('compose/haproxy/route')

return {
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
        route.proxy('/api/service_catalog', 'http://service_catalog:8080', { cors = "*", optional = true });
        route.proxy('/api/service_basket', 'http://service_basket:8080', { cors = "*", optional = true });
    };
}
