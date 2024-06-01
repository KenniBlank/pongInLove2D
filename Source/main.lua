-- Define window dimensions
WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600

-- Initialize variables:
speed = 250 -- player's
player1_X = 100
player2_X = WINDOW_WIDTH - 100
player1_Y = 300 -- only y changes
player2_Y = 300 -- only y changes
start = 1
paddle_width = 3
paddle_height = 20
ball_radius = 5
score1 = 0
score2 = 0
player1_wins = true
player2_wins = true
winning_score = 5
serving = true
serving_player = love.math.random(1, 2) -- 1 or two to signify the player who is serving
once = 1
enter_amount = 0

-- Initializing i.e start function
function love.load()
    love.window.setTitle("PING PONG GAME")
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = true
    })

    -- sounds for the game
    win = love.audio.newSource('wav/Win.ogg', "static")
    ballBounce = love.audio.newSource('wav/ballBounce.mp3', "static")
    ballBounce:setVolume(1)
    score = love.audio.newSource('wav/score.mp3', "static")
    score:setVolume(0.6)
    backgroundMusic = love.audio.newSource('wav/backgroundMusic.wav', "stream")
    backgroundMusic:setVolume(0.75)
    win:setVolume(0.8)
    backgroundMusic:setLooping(true)
    love.audio.play(backgroundMusic)
    
    -- Ball's position
    ball_X = WINDOW_WIDTH / 2
    ball_Y =  WINDOW_HEIGHT / 2

    -- Ball's speed
    balldx = love.math.random(2) == 1 and 150 or -150 -- similar to x = exp1? exp2: exp3; so: exp1 and exp2 or exp3
    balldy = love.math.random(-1,1) * 100
    -- adding font:
    newFont = love.graphics.newFont('font.ttf', 32)
    -- setting the new font
    love.graphics.setFont(newFont)
    math.randomseed(os.time())
end

function pause_ball()
    if (serving == true) then
        if (serving_player == 1) then
            ball_X = WINDOW_WIDTH / 2 + 150
        else 
            ball_X = WINDOW_WIDTH / 2 - 150
        end 
        ball_Y = WINDOW_HEIGHT / 2
        balldx = 0
        balldy = 0
    end
end 

function play_ball()
    if (once == 1) then 
        if (serving_player == 1) then
            ball_X = WINDOW_WIDTH / 2 + 150
            balldx = -150
        else 
            ball_X = WINDOW_WIDTH / 2 - 150
            balldx = 150
        end
        balldy = love.math.random(-1,1) * 250
        once = once + 1
    end
end

function love.draw()
    if (start == 0) then
        -- drawing the left paddle, right paddle and the ball
        love.graphics.rectangle('fill', player1_X, player1_Y, paddle_width, paddle_height)
        love.graphics.rectangle('fill', player2_X, player2_Y, paddle_width, paddle_height)

        love.graphics.circle('fill', ball_X, ball_Y, ball_radius, 100)

        love.graphics.setFont(love.graphics.newFont(32))
        love.graphics.printf('Pong!', 0, 0, WINDOW_WIDTH, 'center')

        love.graphics.setFont(love.graphics.newFont(16))
        love.graphics.printf('First to Score 5 wins', 0, 37, WINDOW_WIDTH, 'center')

        love.graphics.printf("Player1: " .. score1 .. "\nPlayer2: " .. score2, -10,WINDOW_HEIGHT/100, WINDOW_WIDTH, 'right')
        

        if (serving == true) then
            love.graphics.setColor(255, 0, 255)
            love.graphics.printf('PRESS \'SPACE\' to Serve', 0, WINDOW_HEIGHT / 2 - 90, WINDOW_WIDTH, 'center')
            love.graphics.setColor(255, 255, 255) 
            pause_ball()
            once = 1
        else 
            -- net:
            love.graphics.setColor(0, 255, 0)
            local gap = 10  -- Adjust this as needed, represents the length of each segment
            local startX = WINDOW_WIDTH / 2  -- Calculate the starting x-coordinate
            local startY = 80  -- Starting y-coordinate, adjusted to remove 80 pixels from the top
            local endY = WINDOW_HEIGHT - 80  -- Ending y-coordinate, adjusted to remove 80 pixels from the bottom

            -- Loop to draw alternating short segments and gaps
            for y = startY, endY, gap * 2 do
                love.graphics.line(startX, y, startX, math.min(y + gap, endY))
            end

            love.graphics.setColor(255, 255, 255)
            play_ball()
        end
            -- Writes Hello Pong! in screen
    elseif (start == 1) then
        love.graphics.printf(
            'Hello Pong!\nPress Enter to Start\nEsc to Exit\n\'P\' to Pause',
            0,                      -- X position
            WINDOW_HEIGHT / 2 - 90,  -- Y position
            WINDOW_WIDTH,           -- pixels to center within
            'center')               -- alignment: can be 'center', 'left', or 'right'
    elseif (start == 10 or start == 9) then  -- Only clear on winner screen
        if (start == 10) then 
            winning_message("Player 1 WINS!!!")
        elseif (start == 9) then 
            winning_message("Player 2 WINS!!!")
        end
    elseif (start == 2) then
        serving = true 
        if ball_X <= 0 then 
            player1_wins = true 
        end 
        if ball_X >= WINDOW_WIDTH then 
            player2_wins = true
            
        end
        if (player1_wins) then
            score2 = score2 + 1
            if (score2 < winning_score) then 
                love.audio.play(score)
            end
            if (score2 == winning_score) then 
                start = 9
            end 
            serving_player = 2
        else
            score1 = score1 + 1
            if (score1 < winning_score) then 
                love.audio.play(score)
            end 
            if (score1 == winning_score) then 
                start = 10
            end
            serving_player = 1
        end
        if(start == 10 or start == 9) then 
            love.graphics.clear()
        else 
            ballReset()
            start = 0
        end 
    elseif (start == 100) then 
        love.graphics.printf(
            'Game Paused\nPress \'P\' to Continue',
            0,
            WINDOW_HEIGHT / 2 - 50,
            WINDOW_WIDTH,
            'center') 
        love.audio.pause(backgroundMusic)
    end
end

-- Updates every frame
function love.update(dt)
    if (start == 0) then
        -- player 1 movement
        if love.keyboard.isDown('w') then 
            player1_Y = math.max(0, player1_Y - speed * dt)
        elseif love.keyboard.isDown('s') then 
            player1_Y = math.min(WINDOW_HEIGHT - paddle_height, player1_Y + speed * dt)
        end

        -- player 2 movement
        if love.keyboard.isDown('up') then 
            player2_Y = math.max(0, player2_Y - speed * dt)
        elseif love.keyboard.isDown('down') then 
            player2_Y = math.min(WINDOW_HEIGHT - paddle_height, player2_Y + speed * dt)
        end

        -- Ball's movement with the speed:
        ball_X = ball_X + balldx * dt
        ball_Y = ball_Y + balldy * dt

        if (collisionDetection(paddle_width, paddle_height, ball_X, ball_Y, ball_radius, player1_X, player1_Y)) then 
            balldx, balldy, ball_X, ball_Y = bounce(balldx, balldy, ball_X, ball_Y, player1_X)
        end
        if (collisionDetection(paddle_width, paddle_height, ball_X, ball_Y, ball_radius, player2_X, player2_Y)) then 
            balldx, balldy, ball_X, ball_Y = bounce(balldx, balldy, ball_X, ball_Y, player2_X)
        end

        -- Upper and lower boundary:
        if ball_Y <= 0 then 
            ball_Y = 0 + 5
            balldy = -balldy
            love.audio.play(ballBounce)
        end
        if ball_Y >= WINDOW_HEIGHT - 4 then
            ball_Y = WINDOW_HEIGHT - 10
            balldy = -balldy
            love.audio.play(ballBounce)
        end 
        outOfBorder(ball_X)
    end
end

function winning_message(message)
    love.audio.play(win)
    love.graphics.printf(message, 0, 250, WINDOW_WIDTH, 'center')
    love.graphics.printf('Hit Enter to Play Again', 0, 300, WINDOW_WIDTH, 'center')
    score1 = 0
    score2 = 0
    enter_amount = 0
end


-- function that detects keypress:
function love.keypressed(key)
    -- exit the program 
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then 
        if (enter_amount == 0) then
            serving = true
            start = 0
            if win then 
                love.audio.stop(win)
            end
            ballReset()
        end
        enter_amount = enter_amount + 1
    elseif key == 'p' then 
        if (start == 100) then 
            start = 0
        else 
            start = 100
        end 
    elseif key == 'space' then 
        serving = false
    end 
end

function collisionDetection(paddle_width, paddle_height, ball_X, ball_Y, ball_radius, paddle_X, paddle_Y)
    if ball_X + ball_radius >= paddle_X and ball_X - ball_radius <= paddle_X + paddle_width then
        if ball_Y + ball_radius >= paddle_Y and ball_Y - ball_radius <= paddle_Y + paddle_height then
            love.audio.play(ballBounce)
            return true
        end
    end
    return false
end


function ballReset()
    ball_X = WINDOW_WIDTH / 2
    ball_Y = WINDOW_HEIGHT / 2
    math.randomseed(os.time())
    player1_Y = 300 -- only y changes
    player2_Y = 300
    player1_wins = false
    player2_wins = false
end

function outOfBorder(ball_X)
    if ball_X < 0 or ball_X > WINDOW_WIDTH then
        start = 2 
    end
end

function bounce(balldx, balldy, ball_X, ball_Y, paddle_X)
    balldx = -balldx * 1.1
    speed = speed * 1.02
    if paddle_X == player1_X then
        ball_X = paddle_X + 5
    else
        ball_X = paddle_X - 5
    end

    if balldy < 0 then 
        balldy = -math.random(10, 150)
    else 
        balldy = math.random(10, 150)
    end

    return balldx, balldy, ball_X, ball_Y
end