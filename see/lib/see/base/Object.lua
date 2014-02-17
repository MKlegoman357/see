--@native tostring
--@native pairs
--@native setmetatable
--@native getmetatable
--@import see.base.String

--[[
    The super class for all classes loaded in the SEE Runtime.
]]

--[[
    Fully copies an object.
    @return see.base.Object The copied object.
]]
function Object:copy()
    local ret = { }
    for k, v in pairs(self) do
        ret[k] = v
    end
    setmetatable(ret, getmetatable(self))
    return ret
end

--[[
    Return the type of this Object.
    @return table The runtime class.
]]
function Object:getClass()
    return self.__type
end

function Object:instanceof(type)
    local objectType = self.__type
    while objectType do
        if type == objectType then
            return true
        end
        objectType = objectType.__super
    end
    return false
end

function Object:toString()
    return String.new(self:getClass().__name, " (", tostring(self):sub(8, -1), ")")
end

function Object.__concat(l, r)
    return cast(l, String):concat(cast(r, String))
end

function Object.__meta:__eq(other)
    return self:equals(other)
end

function Object:equals(other)
    return self == other
end