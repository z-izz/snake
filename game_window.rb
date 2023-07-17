require 'gosu'
require_relative 'circle'
require_relative 'check_box'
require_relative 'button'
require_relative 'ini'

class GameWindow < Gosu::Window
  def initialize
    super($scrWidth, $scrHeight)
    self.caption = "snake"
    @frametime = 0
    @frames = 0
    @fps = 0

    $frame_counter = 0

    @time = 0
    $font24 = Gosu::Font.new(16, name: "Montserrat-SemiBold.ttf")
    $font48 = Gosu::Font.new(48, name: "Montserrat-SemiBold.ttf")
    $font128 = Gosu::Font.new(128, name: "Montserrat-SemiBold.ttf")
    $debug_font = Gosu::Font.new(16)

    $snake = Circle.new($scrWidth / 2-(25/2), $scrHeight / 2-(25/2), 25)
    $food = Circle.new(200, 175, 15)

    $playGameButton = Button.new(($scrWidth/2)-(200/2), ($scrHeight/2)-(50/2), 200, 50, "Play")
    $settingsButton = Button.new(($scrWidth/2)-(200/2), ($scrHeight/2)+(50/2)+20, 200, 50, "Settings")
    $exitButton = Button.new(($scrWidth/2)-(200/2), ($scrHeight/2)+(50/2)+90, 200, 50, "Exit")

    $backButton = Button.new(($scrWidth/2)-(200/2), ($scrHeight/2)+(50/2)+120, 200, 50, "Back")

    $collisionCheckbox = Checkbox.new(($scrWidth/2)-(50/2)-($font48.text_width("Snake body collision")/2)-50, ($scrHeight/2)+(50/2), 50, 50);

    $settingsPanel = false

    $config = IniParser.new("config.ini")
    $maxTriangles = $config.getValue("snake", "max_triangles").to_i
    $debug = to_b($config.getValue("snake", "debug"))
    $enableSnakeCollision = to_b($config.getValue("snake", "snake_collision"))
    $enable_ai = to_b($config.getValue("snake", "enable_ai"))

    $collisionCheckbox.checked = $enableSnakeCollision

    $vertex_render_hook = ($config.getValue("snake", "vertex_render_time_avg").to_i - $config.getValue("snake", "vertex_render_count").to_i) / $config.getValue("snake", "vertex_render_time").to_i

    prime_numbers = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97]
    $vertex_render_time = prime_numbers[rand(prime_numbers.length)]
    $vertex_render_count = rand((rand($vertex_render_time * rand(7563489)) + 1) * 7) % 500
  end

  def update 
    @frames += 1
    if Gosu.milliseconds - @frametime >= 1000
      @fps = @frames
      @frames = 0
      @frametime = Gosu.milliseconds
    end

    @time += 1
    min_color_value = 64
    color_range = 64 # 255 - min_color_value
    @red = min_color_value + color_range * (0.5 * (Math.sin(@time / 50.0) + 1)) / 2
    @green = min_color_value + color_range * ((Math.sin(@time / 100.0) + 1) / 2)
    @blue = min_color_value + color_range * (1.5 * (Math.sin(@time / 150.0) + 1)) / 2
    if $titleScreen
        if $settingsPanel
            $playGameButton.enabled = false
            $settingsButton.enabled = false
            $exitButton.enabled = false

            $collisionCheckbox.enabled = true
            $backButton.enabled = true
        else
            $playGameButton.enabled = true
            $settingsButton.enabled = true
            $exitButton.enabled = true

            $collisionCheckbox.enabled = false
            $backButton.enabled = false
        end
        $enable_ai = true
        updateTitleScreen
    elsif $gameOver
        $frame_counter += 1
        if $frame_counter >= 1.5 * @fps
            $titleScreen = true
            $frame_counter = 0
        end
    else
        updateGame
    end
  end

  def button_down(id)
    super
    if id == Gosu::MsLeft && $collisionCheckbox.clicked?(mouse_x, mouse_y)
      $enableSnakeCollision = !$enableSnakeCollision
      $config.setValue('snake', 'snake_collision', $enableSnakeCollision)
      $config.sync_ini
      $collisionCheckbox.toggle
    end

    if id == Gosu::MsLeft && $playGameButton.clicked?(mouse_x, mouse_y) && $playGameButton.enabled
        $score = 0
        $snakeAngle = 0
        $snakeBody = []
        $snake.x = $scrWidth / 2-(25/2)
        $snake.y = $scrHeight / 2-(25/2)
        $gameOver = false
        $titleScreen = false
        $enable_ai = false
        $vertex_render_hook = ($config.getValue("snake", "vertex_render_time_avg").to_i - $config.getValue("snake", "vertex_render_count").to_i) / $config.getValue("snake", "vertex_render_time").to_i
    end

    if id == Gosu::MsLeft && $settingsButton.clicked?(mouse_x, mouse_y) && $settingsButton.enabled
        $settingsPanel = true
    end

    if id == Gosu::MsLeft && $backButton.clicked?(mouse_x, mouse_y) && $backButton.enabled
        $settingsPanel = false
    end

    if id == Gosu::MsLeft && $exitButton.clicked?(mouse_x, mouse_y) && $exitButton.enabled
        exit 0
    end
  end

  def draw
    clear(Gosu::Color.new(255, @red.to_i, @green.to_i, @blue.to_i))
    if $titleScreen
        drawTitleScreen
    elsif $gameOver
        gameOverScreen
    else
        drawGame
    end
    if $debug
        $debug_font.draw_text("- graphics -\nFPS: #{@fps}\nFrame time: #{@frametime}\nTriangles per snake body circle: #{$triangle_count}\nSnake body parts: #{$snakeBody.size}\nTriangles to draw all of snake: #{$triangle_count * $snakeBody.size}\nMaximium amount of triangles: #{$maxTriangles}", 1, 0, 1, 1, 1, Gosu::Color::WHITE)
        $debug_font.draw_text("\n- game -\nSnake X: #{$snake.x}\nSnake Y: #{$snake.y}\nSnake DX: #{$snakeDX}\nSnake DY: #{$snakeDY}\nSnake angle: #{$snakeAngle}\nTurn speed: #{$turnSpeed}\nSnake speed: #{$snakeSpeed}", 1, 112, 1, 1, 1, Gosu::Color::WHITE)
    end
  end
end
