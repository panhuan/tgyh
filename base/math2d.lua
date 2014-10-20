local math2d = {}
local cos = math.cos
local sin = math.sin
local atan2 = math.atan2
local sqrt = math.sqrt
local random = math.random
local min = math.min
local max = math.max
local LENGTH_NUDGE = 1.0E-10
function math2d.distance(x0, y0, x1, y1)
	local dx = x1 - x0
	local dy = y1 - y0
	return sqrt(dx * dx + dy * dy)
end

local _distance = math2d.distance
function math2d.distanceSq(x0, y0, x1, y1)
	local dx = x1 - x0
	local dy = y1 - y0
	return dx * dx + dy * dy
end

local _distanceSq = math2d.distanceSq
function math2d.length(dx, dy)
	return sqrt(dx * dx + dy * dy)
end

local _length = math2d.length
function math2d.lengthSq(dx, dy)
	return dx * dx + dy * dy
end

local _lengthSq = math2d.lengthSq
function math2d.dot(x0, y0, x1, y1)
	return x0 * x1 + y0 * y1
end

function math2d.normalize(dx, dy)
	local len = sqrt(dx * dx + dy * dy) + LENGTH_NUDGE
	return dx / len, dy / len, len
end

function math2d.randomPointInCircle(centerX, centerY, radius)
	return centerX + random(-radius, radius), centerY + random(-radius, radius)
end

function math2d.randomPointInRect(centerX, centerY, halfX, halfY)
	return centerX + random(-halfX, halfX), centerY + random(-halfY, halfY)
end

function math2d.polar(x, y)
	return atan2(y, x), sqrt(x * x + y * y)
end

function math2d.cartesian(theta, r)
	return cos(theta) * r, sin(theta) * r
end

function math2d.cartesian2d(x, y, r)
	local theta = math.atan2(y, x)
	return cos(theta) * r, sin(theta) * r
end

function math2d.segmentsIntersect(ax0, ay0, ax1, ay1, bx0, by0, bx1, by1)
	local dx_a = ax1 - ax0
	local dy_a = ay1 - ay0
	local dx_b = bx1 - bx0
	local dy_b = by1 - by0
	local delta = dx_b * dy_a - dy_b * dx_a
	if delta == 0 then
		return false
	end

	local s = (dx_a * (by0 - ay0) + dy_a * (ax0 - bx0)) / delta
	local t = (dx_b * (ay0 - by0) + dy_b * (bx0 - ax0)) / -delta
	return s >= 0 and s <= 1 and t >= 0 and t <= 1
end

local _segmentsIntersect = math2d.segmentsIntersect
function math2d.pointSegmentDistanceSq(px, py, x0, y0, x1, y1)
	local dx = x1 - x0
	local dy = y1 - y0
	if dx == dy and dx == 0 then
		return _distance(px, py, x0, y0)
	end

	local t = ((px - x0) * dx + (py - y0) * dy) / (dx * dx + dy * dy)
	if t < 0 then
		dx = px - x0
		dy = py - y0
	elseif t > 1 then
		dx = px - x1
		dy = py - y1
	else
		local nearx = x0 + t * dx
		local neary = y0 + t * dy
		dx = px - nearx
		dy = py - neary
	end

	return dx * dx + dy * dy
end

local _pointSegmentDistanceSq = math2d.pointSegmentDistanceSq
function math2d.pointSegmentDistance(px, py, x0, y0, x1, y1)
	return sqrt(_pointSegmentDistanceSq(px, py, x0, y0, x1, y1))
end

local _pointSegmentDistance = math2d.pointSegmentDistance
function math2d.segmentsDistance(ax0, ay0, ax1, ay1, bx0, by0, bx1, by1)
	if _segmentsIntersect(ax0, ay0, ax1, ay1, bx0, by0, bx1, by1) then
		return 0
	end

	local d
	d = _pointSegmentDistance(ax0, ay0, bx0, by0, bx1, by1)
	d = min(d, _pointSegmentDistance(ax1, ay1, bx0, by0, bx1, by1))
	d = min(d, _pointSegmentDistance(bx0, by0, ax0, ay0, ax1, ay1))
	d = min(d, _pointSegmentDistance(bx1, by1, ax0, ay0, ax1, ay1))
	return d
end

function math2d.angle(x, y)
	return math.deg(math.atan2(y, x))
end

function math2d.theta(x, y)
	return math.atan2(y, x)
end

function math2d.rectIntersect(xMin1, yMin1, xMax1, yMax1, xMin2, yMin2, xMax2, yMax2)
	if math.abs((xMin1 + xMax1) - (xMin2 + xMax2)) > (xMax1 - xMin1 + xMax2 - xMin2) then
		return
	end
	
	if math.abs((yMin1 + yMax1) - (yMin2 + yMax2)) > (yMax1 - yMin1 + yMax2 - yMin2) then
		return 
	end
	
	local xMin = math.max(xMin1, xMin2)
	local yMin = math.max(yMin1, yMin2)
	local xMax = math.min(xMax1, xMax2)
	local yMax = math.min(yMax1, yMax2)
	
	return xMin, yMin, xMax, yMax
end


return math2d
