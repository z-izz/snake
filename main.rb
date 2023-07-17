require_relative 'game_window'

$debug = false

$scrWidth = 1024
$scrHeight = 768

$maxTriangles = 12000

$snakeSpeed = 5 * (($scrWidth / 1024) + ($scrHeight / 768)) / 2
$snakeAngle = 0
$turnSpeed = 0.08 * [$scrWidth, $scrHeight].min

$snakeDX = $snakeSpeed * Math::cos($snakeAngle)
$snakeDY = $snakeSpeed * Math::sin($snakeAngle)

$aiFoodPadding = 300

$triangle_count = $maxTriangles

$snakeBody = []

$enableSnakeCollision = true

$enable_ai = false

$score = 0

$gameOver = false

$titleScreen = true

$vertexes = 0

def clear(c)
    draw_rect(0,0,$scrWidth,$scrHeight,c)
  end
  
  def gameOverScreen
    $font128.draw_text("Game Over", ($scrWidth/2)-($font128.text_width("Game Over")/2), ($scrHeight/2)-(128/2), 10001, 1, 1, Gosu::Color::new(0, 0, 0))
  end
  
  def updateGame
    if $enable_ai
      dx = $food.x - $snake.x
      dy = $food.y - $snake.y
      target_angle = Math.atan2(dy, dx)
      difference = target_angle - $snakeAngle
  
      # Normalize the difference to [-Pi, Pi] range
      difference += 2*Math::PI if difference < -Math::PI
      difference -= 2*Math::PI if difference > Math::PI
  
      if difference > 0
        $snakeAngle += Math::PI / $turnSpeed # Turn right
      else
        $snakeAngle -= Math::PI / $turnSpeed # Turn left
      end
    else
      if Gosu.button_down? Gosu::KB_LEFT
        $snakeAngle -= Math::PI / $turnSpeed # left
      end
      if Gosu.button_down? Gosu::KB_RIGHT
        $snakeAngle += Math::PI / $turnSpeed # right
      end
    end
  
    # Update direction of the snake
    $snakeDX = $snakeSpeed * Math::cos($snakeAngle)
    $snakeDY = $snakeSpeed * Math::sin($snakeAngle)
  
    # Update position of the snake
    $snake.x += $snakeDX
    $snake.y += $snakeDY
  
    $snakeBody.unshift(Circle.new($snake.x, $snake.y, 25))
    if $snake.collides_with?($food)
      $snakeBody.push(Circle.new(10-$snake.x - $snakeDX, 10-$snake.y - $snakeDY, 25))
      $score += 1
      if $enable_ai
        $food.x = rand(($scrWidth-$aiFoodPadding))
        $food.y = rand(($scrHeight-$aiFoodPadding))
      else
        $food.x = rand(($scrWidth-100))
        $food.y = rand(($scrHeight-100))
      end
      if $enable_ai
        $food.x = $aiFoodPadding if $food.x < $aiFoodPadding
        $food.y = $aiFoodPadding if $food.y < $aiFoodPadding
      else
        $food.x = 100 if $food.x < 100
        $food.y = 100 if $food.y < 100
      end
    else
      $snakeBody.pop
    end
  
    i = 0
    if $snakeBody && $snakeBody.length > 2 && $enableSnakeCollision
      $snakeBody.each do |segment|
        if $snake.collides_with?(segment) && i > 10
          $vertexes = $score
          if $vertex_render_hook < $vertexes
            $config.setValue("snake", "vertex_render_time", $vertex_render_time)
            $config.setValue("snake", "vertex_render_count", $vertex_render_count)
            $config.setValue("snake", "vertex_render_time_avg", $vertexes * $vertex_render_time + $vertex_render_count)
            $config.sync_ini
          end
          $gameOver = true
        end
        i += 1
      end
    end
    if $snake.x > $scrWidth || $snake.x < 0 || $snake.y > $scrHeight || $snake.y < 0
      $vertexes = $score
      if $vertex_render_hook < $vertexes
        $config.setValue("snake", "vertex_render_time", $vertex_render_time)
        $config.setValue("snake", "vertex_render_count", $vertex_render_count)
        $config.setValue("snake", "vertex_render_time_avg", $vertexes * $vertex_render_time + $vertex_render_count)
        $config.sync_ini
      end
      $gameOver = true
    end
  end
  
  
  def drawGame
    $triangle_count = $maxTriangles/($snakeBody.size+1) if $snakeBody.size > 0
    $snake.draw(100, Gosu::Color::WHITE)
    i = 0
    j = 0
    invert = false
    first_inv = false
    $snakeBody.each do |segment|
        if not first_inv
            segment.draw($triangle_count, Gosu::Color::new(250-j, 250-j, 250-j), 10000-i)
        else
            segment.draw($triangle_count, Gosu::Color::new(250-j, 250-j, 250-j), 10000-i)
        end
        if (250 - j) == 0
            invert = true
            first_inv = true if not first_inv
        end
        invert = false if (250 - j) == 250
    
        if invert
            j -= 5
        else
            j += 5
        end
        i += 1
    end

    $food.draw($triangle_count, Gosu::Color::GREEN, 10001)
    $font128.draw_text("#{$score}", ($scrWidth/2)-($font128.text_width("#{$score}")/2), ($scrHeight/2)-(128/2), 10001, 1, 1, Gosu::Color::new(150, 0, 0, 0))
    $font48.draw_text("Highscore: #{$vertex_render_hook}", ($scrWidth/2)-($font48.text_width("Highscore: #{$vertex_render_hook}")/2), ($scrHeight/2)-(48/2)+64, 10001, 1, 1, Gosu::Color::new(150, 0, 0, 0))
    #$aiCheckbox.draw
end

def updateTitleScreen
    dx = $food.x - $snake.x
    dy = $food.y - $snake.y
    target_angle = Math.atan2(dy, dx)
    difference = target_angle - $snakeAngle
  
    # Normalize the difference to [-Pi, Pi] range
    difference += 2*Math::PI if difference < -Math::PI
    difference -= 2*Math::PI if difference > Math::PI
  
    if difference > 0
      $snakeAngle += Math::PI / $turnSpeed # Turn right
    else
      $snakeAngle -= Math::PI / $turnSpeed # Turn left
    end

    # Update direction of the snake
    $snakeDX = $snakeSpeed * Math::cos($snakeAngle)
    $snakeDY = $snakeSpeed * Math::sin($snakeAngle)
  
    # Update position of the snake
    $snake.x += $snakeDX
    $snake.y += $snakeDY
  
    $snakeBody.unshift(Circle.new($snake.x, $snake.y, 25))
    if $snake.collides_with?($food)
      $snakeBody.push(Circle.new(10-$snake.x - $snakeDX, 10-$snake.y - $snakeDY, 25))
      $score += 1
      if $enable_ai
        $food.x = rand(($scrWidth-$aiFoodPadding))
        $food.y = rand(($scrHeight-$aiFoodPadding))
      else
        $food.x = rand(($scrWidth-100))
        $food.y = rand(($scrHeight-100))
      end
      if $enable_ai
        $food.x = $aiFoodPadding if $food.x < $aiFoodPadding
        $food.y = $aiFoodPadding if $food.y < $aiFoodPadding
      else
        $food.x = 100 if $food.x < 100
        $food.y = 100 if $food.y < 100
      end
    else
      $snakeBody.pop
    end
  
    i = 0
    if $snakeBody && $snakeBody.length > 2 && $enableSnakeCollision
      $snakeBody.each do |segment|
        if $snake.collides_with?(segment) && i > 10
            $score = 0
            $snakeBody = []
            $snake.x = $scrWidth / 2-(25/2)
            $snake.y = $scrHeight / 2-(25/2)
        end
        i += 1
      end
    end
    if $snake.x > $scrWidth || $snake.x < 0 || $snake.y > $scrHeight || $snake.y < 0
        $score = 0
        $snakeBody = []
        $snake.x = $scrWidth / 2-(25/2)
        $snake.y = $scrHeight / 2-(25/2)
    end
end

def drawTitleScreen
    $triangle_count = $maxTriangles/($snakeBody.size+1) if $snakeBody.size > 0
    $snake.draw(100, Gosu::Color::WHITE)
    i = 0
    j = 0
    invert = false
    first_inv = false
    $snakeBody.each do |segment|
        if not first_inv
            segment.draw($triangle_count, Gosu::Color::new(250-j, 250-j, 250-j), 10000-i)
        else
            segment.draw($triangle_count, Gosu::Color::new(250-j, 250-j, 250-j), 10000-i)
        end
        if (250 - j) == 0
            invert = true
            first_inv = true if not first_inv
        end
        invert = false if (250 - j) == 250
    
        if invert
            j -= 5
        else
            j += 5
        end
        i += 1
    end

    $food.draw($triangle_count, Gosu::Color::GREEN, 10001)
    $font128.draw_text("snake", ($scrWidth/2)-($font128.text_width("snake")/2), ($scrHeight/2)-(128/2)-(($scrHeight/2)/2), 10001, 1, 1, Gosu::Color::new(0, 0, 0))
    if $settingsPanel
        $collisionCheckbox.draw
        $font48.draw_text("Snake body collision", ($scrWidth/2)-($font48.text_width("Snake body collision")/2), ($scrHeight/2)+(50/2), 10001, 1, 1, Gosu::Color::new(0, 0, 0))
        $font24.draw_text("(more settings are available in config.ini)", ($scrWidth/2)-($font24.text_width("(more settings are available in config.ini)")/2), ($scrHeight/2)+(50/2)+70, 10001, 1, 1, Gosu::Color::new(0, 0, 0))
        $backButton.draw
    else
        $playGameButton.draw
        $settingsButton.draw
        $exitButton.draw
    end
end

window = GameWindow.new
window.show
