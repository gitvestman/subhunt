-- TextInput 1.0 - for love2d 0.7.2
-- Copyright (c) 2011, Francesco Noferi
-- All rights reserved.

TextInput = class('TextInput')
function TextInput:initialize(x, y, size, w, callback)
	self.text = ""
	self.time = 0.0
	self.cursor = "|"
	self.cursor_pos = 0
	self.x = x
	self.y = y
	self.size = size
	self.w = w
	self.callback = callback
	self.shift = false
end

function TextInput:reset()
	self.shift = false
	self.cursor_pos = 0
	self.time = 0.0
	self.text = ""
end

function TextInput:step(k)
	self.time = self.time + k
	if self.time > 1.0 then
		if self.cursor == "|" then
			self.cursor = ""
		else
			self.cursor = "|"
		end
		self.time = 0.0
	end
	self.shift = love.keyboard.isDown("lshift", "rshift", "capslock")
end

function TextInput:keypressed(key)
	if key == "backspace" and self.cursor_pos > 0 then
		self.text = string.sub(self.text, 1, self.cursor_pos-1) .. string.sub(self.text, self.cursor_pos+1)
		self.cursor_pos = self.cursor_pos-1
	elseif key == "left" then
		self.cursor_pos = math.max(0, self.cursor_pos-1)
	elseif key == "right" then
		self.cursor_pos = math.min(self.text:len(), self.cursor_pos+1)
	elseif key == "delete" then
		self.text = string.sub(self.text, 1, self.cursor_pos) .. string.sub(self.text, self.cursor_pos+2)
	elseif key == "return" then
		self.callback()
	end
end

function TextInput:textinput(key)
	if self.text:len() < self.size then
		local thekey = key
		if self.shift then
			thekey = key:upper()
		end
		self.text = string.sub(self.text, 1, self.cursor_pos) .. thekey .. string.sub(self.text, self.cursor_pos+1)
		self.cursor_pos = self.cursor_pos+1
	end
end

function TextInput:draw()
    love.graphics.rectangle("line", self.x - 10 , self.y - 40 , self.w + 20, 100) 
	love.graphics.setColor(0.1, 0.3, 0.1, 0.9) 
    --love.graphics.setShader(gradient_shader)
    love.graphics.rectangle("fill", self.x - 10 , self.y - 40 , self.w + 20, 100) 
    love.graphics.setShader()

	love.graphics.setColor(0.1, 1.0, 0.1) 
	love.graphics.printf("Enter nic", self.x, self.y - 30 , self.w)
	love.graphics.printf(self.text, self.x, self.y, self.w)
	love.graphics.printf(
		self.cursor,
		self.x+love.graphics.getFont():getWidth(string.sub(self.text, 1, self.cursor_pos))-love.graphics.getFont():getWidth(self.cursor)/2,
		self.y,
		self.w
	)
end
