local Meta = require('core/Meta')

local Event = {
  __type = 'Event',
  bucket = nil,
  notify = nil,
  events = nil,
}

function Event:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function Event:from(bucket: string, notify: string)
  return Event:new({
    bucket = bucket,
    notify = notify,
    events = Meta:array {},
  })
end

function Event:with_event(event: string)
  self.events[#self.events + 1] = event
  return self
end

function Event:with_events(events: table)
  for _, event in events do
    self.events[#self.events + 1] = event
  end
  return self
end

function Event:unwrap_events()
  if #self.events == 0 then
    return nil
  end
  return self.events
end

function Event:unwrap()
  return {
    bucket = self.bucket,
    notify = self.notify,
    events = self:unwrap_events(),
  }
end

return Event
