local ggcode = require("ggcode")
local util = require("util")

ggcode.generate "@/compose" {
    target = '@examples',
    variables = {}
}

ggcode.generate "@/haproxy" {
    target = '@examples',
    variables = {}
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
