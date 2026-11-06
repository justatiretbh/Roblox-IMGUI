-- Drawing Utils (Helpers)

local DrawingUtils = {}

function DrawingUtils.New(type, props)
	local obj = Drawing.new(type)
	if props then
		for k, v in pairs(props) do
			obj[k] = v
		end
	end
	return obj
end

function DrawingUtils.Remove(obj)
	if obj then
		pcall(function()
			obj.Visible = false
			obj:Remove()
		end)
	end
end

function DrawingUtils.RemoveTable(t)
	if not t then return end
	for _, obj in pairs(t) do
		DrawingUtils.Remove(obj)
	end
end

return DrawingUtils
