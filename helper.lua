

function drawSimpleRect(obj)
    local x1, y1, x2, y2, x3, y3, x4, y4 = obj.shape:getBoundingBox()
    local w = x3 - x2
    local h = y2 - y1
    love.graphics.rectangle("fill", obj.body:getX() - (w / 2), obj.body:getY() - (h / 2), w, h)
end
