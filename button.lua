local love = require "love"
local lg = love.graphics
-- Button function is effectively a class that will aways return an object, populated with args passed to it
function Button(text, func, func_param, width, height)
	return {
		width = width or 100,
		height = height or 100,
		func = func or function () print("this function has no value")	end,
		func_param = func_param,
		text = text or "no text",
		button_x = 0,
		button_y = 0,
		text_x = 0,
		text_y = 0,

		checkPressed = function(self, mouse_x, mouse_y) -- check click has happened within the boundaries of the button
			if (mouse_x >= self.button_x) and (mouse_x <= self.button_x + self.width) then
			 	if (mouse_y >= self.button_y) and (mouse_y <= self.button_y + self.height) then
					if self.func_param then
						self.func(self.func_param) --if function has params, call with args
					else
						self.func()
					end
				end
			end
		end,

		draw = function (self, button_x, button_y, text_x, text_y)
			self.button_x = button_x or self.button_x
			self.button_y = button_y or self.button_y

			if text_x then
				self.text_x = text_x + self.button_x -- text must be written relative to position of button
			else
				self.text_x = self.button_x
			end

			if text_y then
				self.text_y = text_y + self.button_y
			else
				self.text_y = self.button_y
			end

			lg.setColor(0.6, 0.6, 0.6)
			lg.rectangle("fill", self.button_x, self.button_y, self.width, self.height)

			lg.setColor(0, 0, 0)
			lg.print(self.text, self.text_x, self.text_y)

			lg.setColor(1, 1, 1) -- always falls back to white by default
		end,
	}
end

return Button