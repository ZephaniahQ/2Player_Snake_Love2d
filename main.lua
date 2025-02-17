
Direction = {
    left = 1,
    right = 2,
    up = 3,
    down = 4
}

function updateSegments(snakeIdx, newSegment)
    local segments = snakes[snakeIdx].segments
    table.insert(segments, 1, newSegment)
    table.remove(segments)
end

directionHandler = {
    [Direction.left] = 
    function(snakeIdx)
        local head = snakes[snakeIdx].segments[1]
        local newHeadX = head.x - 1
        if newHeadX < 0 then
            newHeadX = nCols
        end
        updateSegments(snakeIdx, {x = newHeadX, y = head.y})
    end,
    [Direction.right] = 
    function(snakeIdx)
        local head = snakes[snakeIdx].segments[1]
        local newHeadX = head.x + 1
        if newHeadX > nCols then
            newHeadX = 0
        end
        updateSegments(snakeIdx, {x = newHeadX, y = head.y})
    end,
    [Direction.up] = 
    function(snakeIdx)
        local head = snakes[snakeIdx].segments[1]
        local newHeadY = head.y - 1
        if newHeadY < 0 then
            newHeadY = nRows
        end
        updateSegments(snakeIdx, {x = head.x, y =  newHeadY})
    end,
    [Direction.down] = 
    function(snakeIdx)
        local head = snakes[snakeIdx].segments[1]
        local newHeadY = head.y + 1
        if newHeadY > nRows then
            newHeadY = 0
        end
        updateSegments(snakeIdx, {x = head.x, y =  newHeadY})
    end,
}

function genFood()

    local head1X = snakes[1].segments[1].x
    local head1Y = snakes[1].segments[1].y

    local head2X = snakes[2].segments[1].x
    local head2Y = snakes[2].segments[1].y

    local x = love.math.random(1,nCols-1)
    local y = love.math.random(1, nRows-1)

    while x == head1X or x == head2X
        or y == head1Y or y == head2Y do
        x = love.math.random(1,nCols-1)
        y = love.math.random(1, nRows-1)
    end

    foodPos = {
        x = x,
        y = y
    }
end

function consumeFood(snakeIdx)

    local snake = snakes[snakeIdx]
    local headX = snake.segments[1].x
    local headY = snake.segments[1].y

    table.insert(snake.segments, { x = headX, y = headY })

    consumeFoodSound:play()
    genFood()
end

function gameOver()

    isGameOver = true
    paused = true

    gameOverSound:play()

end

function love.load()

    sWidth = 1280
    sHeight  = 720
    blockSize = 40
    nCols = sWidth/blockSize
    nRows = sHeight/blockSize
    blockMargin = 1
    pauseBoxMarginX = 200
    pauseBoxMarginY = 500

    paused = false;
    isGameOver = false;

    consumeFoodSound = love.audio.newSource("consumeFoodSound.mp3", "static")
    gameOverSound = love.audio.newSource("gameOverSound.mp3", "static")

    consumeFoodSound:setVolume(.3)
    gameOverSound:setVolume(.3)
 
    local fontSize = 24
    font = love.graphics.newFont(fontSize)
    love.graphics.setFont(font)

    timer = 0

    snakes = {
        {
            segments = {
                { x = 5, y = 1 },
                { x = 4, y = 1 },
                { x = 3, y = 1 },
                { x = 2, y = 1 },
            },
            directionQueue = { Direction.right },
            inputKey = {
                left = 'a',
                right = 'd',
                up = 'w',
                down = 's'
            },
        },
        {
            segments = {
                { x = 27, y = 13 },
                { x = 28, y = 13 },
                { x = 29, y = 13 },
                { x = 30, y = 13 }
            },
            directionQueue = { Direction.left},
            inputKey = {
                left = 'left',
                right = 'right',
                up = 'up',
                down = 'down'
            }
        }
    }

    foodPos = {}
    genFood()

    if not love.window.setMode(sWidth, sHeight) then
        love.event.quit()
    end
end

function love.update(dt)

    if paused then return end

    timer = timer + dt

    for i = 1, 2, 1 do
        local segments = snakes[i].segments
        local head = segments[1]
        local directionQueue  = snakes[i].directionQueue
        local direction = directionQueue[1]

        -- food collision

        if head.x == foodPos.x and head.y == foodPos.y then
            consumeFood(i)
        end

        -- instra-snake collisions

        for j = 2, #segments-1, 1 do
            local segment = segments[j]
            if segment.x ~= foodPos.x and segment.y ~= foodPos.y
                and segment.x == head.x and segment.y == head.y then
                gameOver()
            end
        end

        -- move snake

        if timer >= 0.10 then

            if i == 2 then timer = 0 end
            if #directionQueue > 1 then
                table.remove(directionQueue, 1)
            end
            local handler = directionHandler[direction]
            if handler then
                handler(i)
            end
        end
    end

    -- inter-snake collisions
    for _,snake1Segment in pairs(snakes[1].segments) do
        for _, snake2Segment in pairs(snakes[2].segments) do
            if snake1Segment.x == snake2Segment.x and
                snake1Segment.y == snake2Segment.y then
                gameOver()
            end
        end
    end
end

function love.draw()

    love.graphics.setColor(1,1,1)

    local snake1Score = "Green Score: " .. (#snakes[1].segments - 4) * 10
    local snake2Score = "Purple Score: " .. (#snakes[2].segments - 4) * 10

    local textWidth = font:getWidth(snake2Score)

    love.graphics.print(snake1Score, 0,0) 
    love.graphics.print(snake2Score, sWidth-textWidth,0)

    -- draw snake 1 (green)
    love.graphics.setColor(0,1,.5)
    for _, segment in pairs(snakes[1].segments) do
        love.graphics.rectangle(
        "fill",
        segment.x*blockSize + blockMargin,
        segment.y*blockSize + blockMargin,
        blockSize - blockMargin,
        blockSize - blockMargin
        )
    end

    -- draw snake 2 (purple)
    love.graphics.setColor(1,.5,.9)
    for _, segment in pairs(snakes[2].segments) do
        love.graphics.rectangle(
        "fill",
        segment.x*blockSize + blockMargin,
        segment.y*blockSize + blockMargin,
        blockSize - blockMargin,
        blockSize - blockMargin
        )
    end

    -- draw food

    love.graphics.setColor(1,.3,.3)
    love.graphics.rectangle(
    "fill",
    foodPos.x*blockSize + blockMargin,
    foodPos.y*blockSize + blockMargin,
    blockSize - blockMargin,
    blockSize - blockMargin
    )

    -- draw pause box

    local text
    if paused then
        if isGameOver then
            local snake1Score = (#snakes[1].segments - 4) * 10
            local snake2Score = (#snakes[2].segments - 4) * 10

            local winnerText

            if snake1Score > snake2Score then
                winnerText = "The winner is Green snake with score: " .. snake1Score
            elseif
                snake1Score < snake2Score then
                winnerText = "The winner is Purple snake with score: " .. snake2Score
            else
                winnerText = "Game ended with a draw!"
            end

            text = "Game Over! " .. winnerText
        else

            text = "Game is Paused!"
        end

        textWidth = font:getWidth(text)
        local textHeight = font:getHeight()

        love.graphics.setColor(.5,.5,1)
        love.graphics.rectangle(
        "fill",
        pauseBoxMarginX, pauseBoxMarginY,
        sWidth - pauseBoxMarginX*2, sHeight - pauseBoxMarginY*2)

        love.graphics.setColor(1,1,1)
        love.graphics.print(text, sWidth/2 - textWidth/2, sHeight/2 - textHeight/2)
    end
end

function love.keypressed(key)

    -- event handling

    if key == 'escape' then
        love.event.quit()
    end

    if key == 'p' then
        paused = not paused 
    end

    for i = 1, 2, 1 do
        local snake = snakes[i]
        local directionQueue = snake.directionQueue
        local direction = directionQueue[#directionQueue]
        local head = snake.segments[1]

        if head.x <= nCols and head.x >= 0
            and head.y <= nRows and head.y >= 0 then

            if key == snake.inputKey.right and direction ~= Direction.left
                and direction ~= Direction.right then
                table.insert(directionQueue, Direction.right)
            end

            if key == snake.inputKey.left and direction ~= Direction.right
                and direction ~= Direction.left then
                table.insert(directionQueue, Direction.left)
            end

            if key == snake.inputKey.up and direction ~= Direction.down
                and direction ~= Direction.up then
                table.insert(directionQueue, Direction.up)
            end

            if key == snake.inputKey.down and direction ~= Direction.up
                and direction ~= Direction.down then
                table.insert(directionQueue, Direction.down)
            end
        end
    end
end
