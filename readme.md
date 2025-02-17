
# 2 Player Snake in Love2d
 
## Gameplay

- Player 1(Green Snake) uses WASD
- Player 2(Purple Snake) uses Arrow Keys for movement
- Just like traditional snake consuming food makes the snakes larger
- Each food consumed adds 10 score points to the snake
- Colision with border teleports snake to the opposite end of screen
- Colision with the other snake causes game to end
- Snake with larger score wins

## How to run?

Install love from the official website and then run main.lua with love

## Coding Challenges

This was my first experience with lua, not having real oop and only tables 
as a datastructure was ... new.

## Handling 2 snakes

There is a main snakes table which contains the segments, directionQueue and 
input key for each snake:

```
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
```

another interesting thing is how I used a table as an alternative to 
switch statement. The direcion handler table takes as index a direciton enum
(obviously also a table) and returns a handler function

Direction enum: 
```
Direction = {
    left = 1,
    right = 2,
    up = 3,
    down = 4
}
```

directionHandler:

```
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
```
