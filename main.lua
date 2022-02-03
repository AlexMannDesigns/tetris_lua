-- TO DO
-- game over/game start screen, 'push any key to restart'

local love = require "love" -- silences linter warnings for love functions
local lg = love.graphics
local button = require "Button" -- importing our button function as a 'class'

-- playing with states...
local game = {
	level = 0,
	state = {
		menu = true,
		running = false,
		ended = false
	},
}

local buttons = {
	menu_state = {}, -- this obj will contain all the buttons to be rendered when gamestate=menu
}

-- below variales either do not change or are always same value when game starts --

-- key for table: { {piece type {rotations}}, {piece type {rotations}}, {piece type {rotations}} }
local pieceStructures = {
	{
		{
			{' ', ' ', ' ', ' '},
			{'i', 'i', 'i', 'i'},
			{' ', ' ', ' ', ' '},
			{' ', ' ', ' ', ' '},
		},
		{
			{' ', 'i', ' ', ' '},
			{' ', 'i', ' ', ' '},
			{' ', 'i', ' ', ' '},
			{' ', 'i', ' ', ' '},
		},
	},
	{
		{
			{' ', ' ', ' ', ' '},
			{' ', 'o', 'o', ' '},
			{' ', 'o', 'o', ' '},
			{' ', ' ', ' ', ' '},
		},
	},
	{
		{
			{' ', ' ', ' ', ' '},
			{'j', 'j', 'j', ' '},
			{' ', ' ', 'j', ' '},
			{' ', ' ', ' ', ' '},
		},
		{
			{' ', 'j', ' ', ' '},
			{' ', 'j', ' ', ' '},
			{'j', 'j', ' ', ' '},
			{' ', ' ', ' ', ' '},
		},
		{
			{'j', ' ', ' ', ' '},
			{'j', 'j', 'j', ' '},
			{' ', ' ', ' ', ' '},
			{' ', ' ', ' ', ' '},
		},
		{
			{' ', 'j', 'j', ' '},
			{' ', 'j', ' ', ' '},
			{' ', 'j', ' ', ' '},
			{' ', ' ', ' ', ' '},
		},
	},
	{
		{
			{' ', ' ', ' ', ' '},
			{'l', 'l', 'l', ' '},
			{'l', ' ', ' ', ' '},
			{' ', ' ', ' ', ' '},
		},
		{
			{' ', 'l', ' ', ' '},
			{' ', 'l', ' ', ' '},
			{' ', 'l', 'l', ' '},
			{' ', ' ', ' ', ' '},
		},
		{
			{' ', ' ', 'l', ' '},
			{'l', 'l', 'l', ' '},
			{' ', ' ', ' ', ' '},
			{' ', ' ', ' ', ' '},
		},
		{
			{'l', 'l', ' ', ' '},
			{' ', 'l', ' ', ' '},
			{' ', 'l', ' ', ' '},
			{' ', ' ', ' ', ' '},
		},
	},
	{
		{
			{' ', ' ', ' ', ' '},
			{'t', 't', 't', ' '},
			{' ', 't', ' ', ' '},
			{' ', ' ', ' ', ' '},
		},
		{
			{' ', 't', ' ', ' '},
			{' ', 't', 't', ' '},
			{' ', 't', ' ', ' '},
			{' ', ' ', ' ', ' '},
		},
		{
			{' ', 't', ' ', ' '},
			{'t', 't', 't', ' '},
			{' ', ' ', ' ', ' '},
			{' ', ' ', ' ', ' '},
		},
		{
			{' ', 't', ' ', ' '},
			{'t', 't', ' ', ' '},
			{' ', 't', ' ', ' '},
			{' ', ' ', ' ', ' '},
		},
	},
	{
		{
			{' ', ' ', ' ', ' '},
			{' ', 's', 's', ' '},
			{'s', 's', ' ', ' '},
			{' ', ' ', ' ', ' '},
		},
		{
			{'s', ' ', ' ', ' '},
			{'s', 's', ' ', ' '},
			{' ', 's', ' ', ' '},
			{' ', ' ', ' ', ' '},
		},
	},
	{
		{
			{' ', ' ', ' ', ' '},
			{'z', 'z', ' ', ' '},
			{' ', 'z', 'z', ' '},
			{' ', ' ', ' ', ' '},
		},
		{
			{' ', 'z', ' ', ' '},
			{'z', 'z', ' ', ' '},
			{'z', ' ', ' ', ' '},
			{' ', ' ', ' ', ' '},
		},
	},
}

--tetr loops variable
local pieceXcount = 4
local pieceYcount = 4

--varibable to set the fall speed of the tetrimino
local timerLimit = 0.5
local gridXcount = 10 --arena width
local gridYcount = 18 --arena height
local lineCount = 0 --tracks number of complete lines

-- varibales below used across multiple functions --
-- declared as local here to silence linter warnings and prevent problems as program grows
local inert
local timer
local pieceX
local pieceY
local pieceRotation
local pieceType
local sequence

function love.load() --called once at beginning of game
	love.window.setTitle("TETRIS")
	lg.setBackgroundColor(255,255,255)
	font = lg.newImageFont("awesomefont.png",
		" abcdefghijklmnopqrstuvwxyz" ..
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
		"123456789.,!?-+/():;%&`'*#=[]\"")

	if game.state["menu"] then
		buttons.menu_state.exit_game = button("Exit", love.event.quit, nil, 120, 40) -- event.quit function closes love
		buttons.menu_state.play_game = button("Play Game", startNewGame, nil, 120, 40)
	end
end

function love.update(dt)
	if game.state["running"] then
		timer = timer + dt
		if timer >= timerLimit then
			timer = 0

			local testY = pieceY + 1
			if canPieceMove(pieceX, testY, pieceRotation) then	--if the piece can move down, move it
				pieceY = testY
			else	-- if it can't move (i.e. bottom of arena or another tetrimino below)
				-- add tetrimino to inert by looping indicies of 2d array
				for y = 1, pieceYcount do
					for x = 1, pieceXcount do
						local block =
							pieceStructures[pieceType][pieceRotation][y][x] -- block matches char in tetrimino
						if block ~= ' ' then
							inert[pieceY + y][pieceX + x] = block
						end
					end
				end
				for y = 1, gridYcount do
					local complete = true
					for x = 1, gridXcount do
						if inert[y][x] == ' ' then
							complete = false
							break
						end
					end
					if complete then --we have found a completed row
						for removeY = y, 2, -1 do --subtract 1 until we get to 2. The top row does not need to be checked
							for removeX = 1, gridXcount do
								inert[removeY][removeX] = inert[removeY - 1][removeX] --move blocks above line down by one
							end
						end

						for removeX = 1, gridXcount do --sets top row of arena to blank
							inert[1][removeX] = ' '
						end

						lineCount = lineCount + 1 --increment line counter for each complete line
						if lineCount % 5 == 0 then
							game.level = game.level + 1
							timerLimit = timerLimit * 0.9
						end
					end
				end
				newPiece()

				if not canPieceMove(pieceX, pieceY, pieceRotation) then --restart game if new piece cant be moved
					reset()
				end
			end
		end
	end
end

function love.mousepressed(x, y, click) -- detect mouse clicks
	if not game.state["running"] then -- we only want mouse to work when game is not running
		if click == 1 then
			if game.state["menu"] then
				for index in pairs(buttons.menu_state) do
					buttons.menu_state[index]:checkPressed(x, y)
				end
			end
		end
	end
end

function love.keypressed(key) --rotate and move tetriminos
	if game.state["running"] then
		if key == 'x' or key == 'up' then --increment rotation by 1, unless end no rotations, then set to 1
			local testRotation = pieceRotation + 1
			if testRotation > #pieceStructures[pieceType] then
				testRotation = 1
			end

			if canPieceMove(pieceX, pieceY, testRotation) then
				pieceRotation = testRotation
			end

		elseif key == 'z' then --decrement rotation by 1, unless it gets to zero
			local testRotation = pieceRotation - 1
			if testRotation < 1 then
				testRotation = #pieceStructures[pieceType]
			end

			if canPieceMove(pieceX, pieceY, testRotation) then
				pieceRotation = testRotation
			end

		elseif key == 'left' then
			local testX = pieceX - 1

			if canPieceMove(testX, pieceY, pieceRotation) then
				pieceX = testX
			end

		elseif key == 'right' then
			local testX = pieceX + 1

			if canPieceMove(testX, pieceY, pieceRotation) then
				pieceX = testX
			end

		elseif key == 'c' or key == 'down' then
			while canPieceMove(pieceX, pieceY + 1, pieceRotation) do
				pieceY = pieceY + 1
				timer = timerLimit
			end
		end
	end
end
--function to draw arena
function love.draw()
	if game.state["running"] then
		local function drawBlock(block, x, y) --function handles the drawing of each square in arena
			local colors = {
				[' '] = {.87, .87, .87},
				i = {.47, .76, .94},
				j = {.93, .91, .42},
				l = {.49, .85, .76},
				o = {.92, .69, .47},
				s = {.83, .54, .93},
				t = {.97, .58, .77},
				z = {.66, .83, .46},
				preview = {.75, .75, .75},
			}
			local color = colors[block] --checks value of spaces in arena
			lg.setColor(color) --uses table above to set space to color

			local blockSize = 20 --size of squares
			local blockDrawSize = blockSize - 1 --size of lines between squares
			lg.rectangle(
				'fill',				 --type of rectangle
				(x - 1) * blockSize, --position on x
				(y - 1) * blockSize, --position on y
				blockDrawSize, --width
				blockDrawSize --height
				--can add border radius here (x px, y px, and num of segments)
			)
		end

		local offsetX = 2
		local offsetY = 5

		for y = 1, gridYcount do --these nested loops draw the arena
			for x = 1, gridXcount do
				drawBlock(inert[y][x], x + offsetX, y + offsetY)
			end
		end

		for y = 1, pieceYcount do --these nested loops draw the tetrimino
			for x = 1, pieceXcount do
				local block = pieceStructures[pieceType][pieceRotation][y][x] --sets block based on above variables
				if block ~= ' ' then --if the tetrimino location is not empty, set a color, otherwise move on
					drawBlock(block, x + pieceX + offsetX, y + pieceY + offsetY)
				end --ends if block
			end --ends inner tetrimino draw loop
		end --ends outer tetrimino draw loop

		for y = 1, pieceYcount do
			for x = 1, pieceXcount do
				local block = pieceStructures[sequence[#sequence]][1][y][x] -- draw preview of next piece
				if block ~= ' ' then
					drawBlock('preview', x + 5, y + 1) -- position over the arena, color grey
				end
			end
		end
		local str1 = "Lines: " .. lineCount
		local str2 = "level: " .. game.level
		local color1 = {.83, .54, .93}
		local lineText = {color1, str1}
		local levelText = {color1, str2}
		lg.setFont(font)
		lg.print(lineText, font, 300, 200)
		lg.print(levelText, font, 300, 230)

	elseif game.state["menu"] then
		buttons.menu_state.play_game:draw(10, 20, 17, 10)
		buttons.menu_state.exit_game:draw(10, 70, 17, 10)
	end
end

function startNewGame()
	game.state["menu"] = false
	game.state["running"] = true
	reset()
end

function canPieceMove(testX, testY, testRotation) --function returns true or false after checking position in arena
	for y = 1, pieceYcount do --check tetrimino 4x4 grid
		for x = 1, pieceXcount do
			local testBlockX = testX + x
			local testBlockY = testY + y
			if pieceStructures[pieceType][testRotation][y][x] ~= ' ' and (
				testBlockX < 1
				or testBlockX > gridXcount
				or testBlockY > gridYcount
				or inert[testBlockY][testBlockX] ~= ' '
			) then
				return false
			end
		end
	end
	return true
end

function newSequence() --generates a table of randomly ordered tetriminos
	sequence = {}
	for pieceTypeIndex = 1, #pieceStructures do -- loop through all tetriminos
		local position = love.math.random(#sequence + 1) -- set position in table to random, arg is top of range, bottom defaults to 1
		table.insert(
			sequence, -- name of table
			position, -- index in table (random number)
			pieceTypeIndex -- value to be inserted (1 - number of tetriminos, sequentially)
		)
	end
end

function newPiece()
	--below coords are fed into the draw block function to set location of tetrimino
	pieceX = 3
	pieceY = 0
	--below coords refer to tetrimino shape and rotation in above table
	pieceRotation = 1
	pieceType = table.remove(sequence) --tetrimino taken from end of table
	if #sequence == 0 then --new table generated when sequence length is 0
		newSequence()
	end
end

function reset()
	inert = {} --creates a 2d array, reperesenting the arena
	for y = 1, gridYcount do
		inert[y] = {}
		for x = 1, gridXcount do
			inert[y][x] = ' '
		end
	end
	newSequence() --creates new table of tetriminos
	newPiece() -- sets new tetrimino
	timer = 0
	timerLimit = 0.5
	lineCount = 0
	game.level = 0
end