local Meta = require('core/Meta')

local KafkaTarget = {
  __type = 'KafkaTarget',

  name = nil,
  topic = nil,
  brokers = nil,
  events = nil,
}

function KafkaTarget:new(o)
  o = o or {}
  setmetatable(o, self)
  self.__index = self
  return o
end

function KafkaTarget:from(name: string)
  return KafkaTarget:new({
    name = name,
    brokers = Meta:array {},
    events = Meta:table {},
  })
end

function KafkaTarget:with_topic(topic: string)
  self.topic = topic
  return self
end

function KafkaTarget:with_broker(broker: string)
  self.brokers[#self.brokers + 1] = broker
  return self
end

function KafkaTarget:with_event(bucket: string, action: string)
  local event = self.events[bucket] or Meta:table {
    bucket = bucket,
    actions = Meta:array {}
  }
  event.actions[#event.actions + 1] = action
  self.events[bucket] = event
  return self
end

function KafkaTarget:unwrap()
  return {
    type = 'KafkaTarget',
    name = self.name,
    topic = self.topic or self.name,
    brokers = self.brokers,
    events = self.events,
  }
end

return KafkaTarget
