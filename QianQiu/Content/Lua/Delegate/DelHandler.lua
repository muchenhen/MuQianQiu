local DelHandler = class("DelHandler")

function DelHandler:ctor()
	self.luaDelToBinded = {}
end

-- Bind function to UE Dynamic Delegate
--@dynamicDel FScriptDelegate|FMulticastScriptDelegate
--@func function
function DelHandler:Bind(dynamicDel, func)
	local luaDel
	if dynamicDel then
		local bindFunc = dynamicDel.Bind or dynamicDel.Add
		if bindFunc then
			luaDel = bindFunc(dynamicDel, func)

			if luaDel then
				self.luaDelToBinded[luaDel] = dynamicDel
			end
		end
	else
		error("no dynamicDel")
	end
	return luaDel
end

-- Unbind UE Dynamic Delegate
--@luaDel ULuaDelegate  returned by Bind
function DelHandler:Remove(luaDel)
	local bindedDel = self.luaDelToBinded[luaDel]
	if bindedDel then
		local removeFunc = bindedDel.Remove
		if removeFunc then
			removeFunc(bindedDel, luaDel)
		else
			bindedDel:Clear()
		end
		self.luaDelToBinded[luaDel] = nil
	end
end

-- Unbind all UE Dynamic Delegate this handler managed
function DelHandler:Clear()
	for k,v in pairs(self.luaDelToBinded) do
		self:Remove(k)
	end
end

return DelHandler