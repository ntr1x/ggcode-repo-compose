local Database = {
  name = nil,
  username = nil,
  password = nil,
}

function Database:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

return {
  Database = Database,
}
