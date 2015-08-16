local util = {}

function util.setFillRGB(object, red, green, blue)
    object:setFillColor(red/255, green/255, blue/255)
end

return util
