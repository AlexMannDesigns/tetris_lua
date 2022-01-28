-- TO DO
-- line count
-- increase game-speed (levels)
-- game over screen, 'push any key to restart'

function love.load() --called once at begin of game
	love.graphics.setBackgroundColor(255,255,255)

	-- key for table: { {piece type {rotations}}, {piece type {rotations}}, {piece type {rotations}} }
	pieceStructures = {
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
	pieceXcount = 4
	pieceYcount = 4
	--varibable to set the fall speed of the tetrimino
	timerLimit = 0.5

	gridXcount = 10 --arena width
	gridYcount = 18 --arena height

	lineCount = 0 --tracks number of complete lines

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
		lineCount = 0
	end

	reset()
end

function love.update(dt)
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
				end
			end
			newPiece()

			if not canPieceMove(pieceX, pieceY, pieceRotation) then --restart game if new piece cant be moved
				reset()
			end
		end
	end
end

function love.keypressed(key) --rotate and move tetriminos
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
--function to draw arena
function love.draw()
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
		love.graphics.setColor(color) --uses table above to set space to color

		local blockSize = 20 --size of squares
		local blockDrawSize = blockSize - 1 --size of lines between squares
		love.graphics.rectangle(
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
	--local str2 = "test"
	local color1 = {0,0,0}
	--local color2 = {.97, .58, .77}
	local coloredText = {color1, str1}
	love.graphics.print(coloredText, 300, 200, 0, 1.25)
end
