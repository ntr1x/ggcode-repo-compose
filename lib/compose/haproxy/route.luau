local URI = require('util/uri')
local OBJECT = require('util/object')
local Path = require('util/path')

local function proxy(path: string, uri: string, options: table)
    local backend_uri = URI:parse(uri)
    backend_uri.port = backend_uri.port or 80

    if type(options) == 'table' then
        if type(options.cors) == 'string' then
            options.cors = { origin = options.cors }
        elseif type(options.cors) == 'boolean' and options.cors then
            options.cors = {}
        elseif type(options.cors) == 'table' then
            options.cors.origin = options.cors.origin or '*'
            options.cors.headers = options.cors.headers or '*'
            options.cors.credentials = options.cors.credentials or 'true'
            options.cors.methods = options.cors.methods or 'GET, DELETE, OPTIONS, POST, PUT, PATCH'
        end

        if type(options.check) == 'number' then
            options.check = { port = options.check }
        elseif type(options.check) == 'string' then
            options.check = { port = options.check }
        elseif type(options.check) == 'boolean' and options.check then
            options.check = { port = backend_uri.port }
        elseif type(options.check) == 'table' then
            options.check.port = options.check.port or options.backend_uri.port
        end
    else
        options = {}
    end

    return {
        path = path,
        cors = options.cors or nil,
        servers = {
            { hostname = backend_uri.hostname, port = backend_uri.port, check = options.check, optional = options.optional or false }
        }
    }
end

local function route(name: string, uri: string, options: table)
    local frontend_uri = URI:parse(uri)
    frontend_uri.port = frontend_uri.port or 80

    return function (proxies: table)

        local modified_proxies = {}
        for _, proxy in proxies do
            local template = OBJECT.spread(proxy)
            local modified_proxy = template({
                path = Path:from_string(frontend_uri.path):join_string(proxy.path):normalize():to_string()
            })
            modified_proxies[#modified_proxies + 1] = modified_proxy
        end
        return {
            name = name,
            hostname = frontend_uri.hostname,
            port = frontend_uri.port,
            path = frontend_uri.path,
            proxies = modified_proxies
        }
    end
end

return {
    route = route,
    proxy = proxy,
}
