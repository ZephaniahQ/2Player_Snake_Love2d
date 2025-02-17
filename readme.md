
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

### - Handling 2 snakes

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

### - Directional movement

Directional movement for a snake feels challenging, but once you realize the trick
it is fairly simple. The trick is to not move the head and then the following blocks
in following frames, instead to remove the tail and place a new sement connected to 
the head(according to the direction you want the snake to move) which now acts as
the new head

### - Direction Lookup table

Another intersting thing I did was making a lookup table for direction handling.
The table takes in a direction enum(obviously also a table) and returns a handler 
function. This was my first experience doing this as I have not js/python (or other
langs where functions are first class citizens) a lot.

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

Using the handler

```
local handler = directionHandler[direction]
    if handler then
handler(i)
    end
```
