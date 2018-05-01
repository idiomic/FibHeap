--Fibonacci Minimum Heap Priority Queue
--Tyler Richard Hoyer
--04/30/2018

local FibHeap = {}
FibHeap.__index = FibHeap

function FibHeap.new()
	return setmetatable({
		count = 0;
		min = nil;
	}, FibHeap)
end

function FibHeap:insert(key)
	local node = {
		key = key;
		degree = 0;
		parent = nil;
		child = nil;
		mark = false;
		left = nil;
		right = nil;
	}
	if self.min == nil then
		node.left = node
		node.right = node
		self.min = node
	else
		node.left = self.min.left
		node.right = self.min
		node.left.right = node
		node.right.left = node
		if key < self.min.key then
			self.min = node
		end
	end
	self.count = self.count + 1
	return node
end

function FibHeap:union(other)
	if not self.min then
		self.count = other.count
		self.min = other.min
		return
	elseif not other.min then
		return
	end
	local selfEnd = self.min.right
	local otherEnd = other.min.right
	otherEnd.left = self.min
	selfEnd.left = other.min
	self.min.right = otherEnd
	other.min.right = selfEnd
	if other.min.key < self.min.key then
		self.min = other.min
	end
	self.count = self.count + other.count
end

function FibHeap:findMin()
	return self.min and self.min.key
end

function FibHeap:deleteMin()
	local min = self.min
	if not min then
		return
	elseif min.child then
		local child = min.child
		repeat
			child.parent = nil
			child = child.right
		until child == min.child
		local parentEnd = min.right
		local childEnd = child.right
		parentEnd.left = child
		childEnd.left = min
		min.right = childEnd
		child.right = parentEnd
		self.min = min.child
	end
	self.count = self.count - 1
	if min == min.right then
		self.min = nil
		return min.key
	else
		min.left.right = min.right
		min.right.left = min.left
		self.min = min.right
		return self:_consolidate()
	end
end

function FibHeap:decreaseKey(node, key)
	assert(key < node.key, "FibHeap:decreaseKey() called with a larger key ("
			.. key .. ") than the original (" .. node.key .. ")!")
	node.key = key
	if key < self.min.key then
		self.min = node
	end
	local parent = node.parent
	if parent and node.key < parent.key then
		self:_cut(node, parent)
		return self:_cascadingCut(node, parent)
	end
end

function FibHeap:_consolidate()
	local degrees = {}
	local root = self.min
	local last = self.min.left
	local stop = false
	repeat
		local node = root
		if node == last then
			stop = true
		end
		root = root.right
		local d = node.degree
		while degrees[d] do
			local sibling = degrees[d]
			if node.key > sibling.key then
				node, sibling = sibling, node
			end
			self:_link(sibling, node)
			degrees[d] = nil
			d = d + 1
		end
		degrees[d] = node
	until stop
	self.min = nil
	for d, node in pairs(degrees) do
		if not self.min or node.key < self.min.key then
			self.min = node
		end
	end
end

function FibHeap:_link(node, newParent)
	node.left.right = node.right
	node.right.left = node.left
	if newParent.child then
		newParent.child.left.right = node
		node.left = newParent.child.left
		newParent.child.left = node
		node.right = newParent.child
	else
		newParent.child = node
		node.left = node
		node.right = node
	end
	node.parent = newParent
	newParent.degree = newParent.degree + 1
	node.mark = false
end

function FibHeap:_cut(child, parent)
	child.left.right = child.right
	child.right.left = child.left
	if parent.child == child then
		if child == child.right then
			parent.child = nil
		else
			parent.child = child.right
		end
	end
	parent.degree = parent.degree - 1
	self.min.right.left = child
	child.right = self.min.right
	child.left = self.min
	self.min.right = child
	child.parent = nil
	child.mark = false
end

function FibHeap:_cascadingCut(child)
	local parent = child.parent
	if not parent then
		return
	end
	if y.mark then
		self:_cut(child, parent)
		return self:_cascadingCut(parent)
	else
		y.mark = true
	end
end

function FibHeap:delete(x)
	self:decreaseKey(x, -math.huge)
	self:extractMin()
end

local function recTostring(x, indent, outputLines)
	outputLines[#outputLines + 1] = indent .. x.key
	local child = x.child
	if not child then
		return
	end
	indent = indent .. "\t"
	repeat
		recTostring(child, indent, outputLines)
		child = child.right
	until child == x.child
end

function FibHeap:__tostring()
	local root = self.min
	if not root then
		return
	end
	local outputLines = {}
	repeat
		recTostring(root, "\t", outputLines)
		root = root.right
	until root == self.min
	return table.concat(outputLines, "\n")
end

return FibHeap
