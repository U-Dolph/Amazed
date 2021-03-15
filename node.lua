local node = {}

function node:new(_x, _y, _w, _h)
	local self = {}

	self.x = _x
	self.y = _y
	self.w = _w or 1
	self.h = _h or 1

	self.renderX = self.x * self.w + self.w / 2
	self.renderY = self.y * self.h + self.h / 2
	self.renderRadius = self.w * 0.2

	self.visited = false
	self.neighbours = {}
	self.parent = nil
	self.globalScore = math.huge
	self.localScore = math.huge

	function self:resetNode()
		self.visited = false
		self.parent = nil
		self.globalScore = math.huge
		self.localScore = math.huge
	end

	return self
end

return node