--@import see.io.peripheral.Modem
--@import see.io.InputStream
--@import see.util.ArgumentUtils
--@import see.concurrent.Thread
--@import see.event.impl.ModemMessageEvent

--@extends see.io.InputStream

--@abstract flush

function ModemInputStream:init(modem, channel)
	self.modem = modem
	self.channel = channel
	self.buffer = Array:new()
	self.running = true
	self.thread = Thread:new(function()
		while self.running do
			local evt 
			try(function()
				evt = Events.pull(ModemMessageEvent)
			end, function(e) end)

			if evt then
				if evt.channel == channel then
					local val = STR(evt.message):toNumber()  --too simple? probably
					self.buffer:add(val)
				else
					--crap, what now... cant just "re-queue" it.. or can we.. hmmmmmm
					Events.queue(evt) --HIGHLY EXPERIMENTAL, PROBABLY CAUSES HORRIBLE SHIT TO GO DOWN
					Thread.yield() --not necessary?  this thread code needs to be looked over..
				end
			end
		end
	end)

	self.modem:open(channel)
	self.thread:start()
end

function ModemInputStream:read()
	if self.buffer:length() == 0 then
		return -1
	end

	return self.buffer:remove(1)
end

function ModemInputStream:available()
	return self.buffer:length()
end

--[[
	Closes the input stream
	It is very important this is called! If it is not, a thread will be left running!
]]
function ModemInputStream:close()
	Thread:new(function()
		self.modem:close(self.channel)

		self.running = false
		self.thread:interrupt()
		self.thread:join()
	end):start()
end