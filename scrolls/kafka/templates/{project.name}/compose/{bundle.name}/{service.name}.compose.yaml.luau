local config = {
  services = {
    [service.name] = service.manifest
  },
  volumes = volumes,
}

template:println(yaml:stringify(config))
