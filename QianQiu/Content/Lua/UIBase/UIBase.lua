local UIBase = class("UIBase")

local DelHandler = require("Delegate/DelHandler")


function UIBase:BindDelegate(dynamicDel, func)
	if not self.delHandler then
		self.delHandler = DelHandler.new()
	end

	return self.delHandler:Bind(dynamicDel, func)
end