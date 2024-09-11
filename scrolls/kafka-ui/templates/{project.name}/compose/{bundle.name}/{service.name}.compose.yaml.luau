local config = {
  services = {
    [service.name] = service.manifest
  },
}

template:println(yaml:stringify(config))
