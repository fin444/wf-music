$scrolled_x = 0 # amount of x to adjust everything by
$scrolled_y = 0
$full_size_x = $width*2 # total width of all objects
$full_size_y = $height*2
$scroll_list_x = [] # list of all elements scrollable by x
$scroll_list_y = []

class Scroll_Button
	attr_accessor :hidden
	def initialize x, y, image, action
		@x = x
		@y = y
		@image = image
		@action = action
		@color = $colors["button_deselected"]
		@hidden = false # this is just to ignore errors with the mouse_up script
		@first_draw = true
		draw
		$all_buttons.push self
	end
	def draw
		if !@first_draw
			@button.remove
			@button_image.remove
		else
			@first_draw = false
		end
		@button = Rectangle.new x: @x, y: @y, width: 20, height: 20, color: @color, z: 6
		@button_image = Image.new @image, x: @x, y: @y, width: 20, height: 20, color: $colors["background"], z: 6
	end
	def click event
		if @button.contains? event.x, event.y
			@color = $colors["button_deselected"]
			draw
			@action.call
		end
	end
	def mouse_down event
		if @button.contains? event.x, event.y
			@color = $colors["button_selected"]
			draw
		end
	end
	def mouse_up
		@color = $colors["button_deselected"]
		draw
	end
end

class Scroll_Bar_X
	def initialize
		@container = Rectangle.new x: 0, y: $height-20, width: $width-20, height: 20, color: [0, 0, 0, 0]
		@button_left = Scroll_Button.new 0, $height-20, "resources/images/left_scroll.png", Proc.new { $scroll_bar_x.scroll_left 21 }
		@button_right = Scroll_Button.new $width-40, $height-20, "resources/images/right_scroll.png", Proc.new { $scroll_bar_x.scroll_right 21 }
		@first_draw = true
		draw
		$scroll_bar_x = self
	end
	def draw
		if !@first_draw
		else
			@first_draw = false
		end
	end
	def click event
		if @container.contains? event.x, event.y
			@button_left.click event
			@button_right.click event
		end
	end
	def mouse_down event
		if @container.contains? event.x, event.y
			@button_left.mouse_down event
			@button_right.mouse_down event
		end
	end
	def scroll_left increment
		if $scrolled_x != 0
			if $scrolled_x-increment < 0
				$scrolled_x = 0
			else
				$scrolled_x -= increment
			end
			if !$playing
				$playing_bar.remove
				$playing_bar = Line.new x1: $playing_counter-$scrolled_x, y1: $containers[0].container.height, x2: $playing_counter-$scrolled_x, y2: $height, color: $colors["note"], width: 3, z: 3
			end
			$scroll_list_x.each do |c|
				c.scroll_x
			end
		end
	end
	def scroll_right increment
		if $scrolled_x+$width != $full_size_x
			if $scrolled_x+$width+increment > $full_size_x
				$scrolled_x = $full_size_x-$width
			else
				$scrolled_x += increment
			end
			if !$playing
				$playing_bar.remove
				$playing_bar = Line.new x1: $playing_counter-$scrolled_x, y1: $containers[0].container.height, x2: $playing_counter-$scrolled_x, y2: $height, color: $colors["note"], width: 3, z: 3
			end
			$scroll_list_x.each do |c|
				c.scroll_x
			end
		end
	end
end
class Scroll_Bar_Y
	def initialize
		@container = Rectangle.new x: $width-20, y: 00, width: 20, height: $height-20, color: [0, 0, 0, 0]
		@button_up = Scroll_Button.new $width-20, 0, "resources/images/up_scroll.png", Proc.new{ $scroll_bar_y.scroll_up 21 }
		@button_down = Scroll_Button.new $width-20, $height-40, "resources/images/down_scroll.png", Proc.new{ $scroll_bar_y.scroll_down 21 }
		@first_draw = true
		draw
		$scroll_bar_y = self
	end
	def draw
		if !@first_draw
		else
			@first_draw = false
		end
	end
	def click event
		if @container.contains? event.x, event.y
			@button_up.click event
			@button_down.click event
		end
	end
	def mouse_down event
		if @container.contains? event.x, event.y
			@button_up.mouse_down event
			@button_down.mouse_down event
		end
	end
	def scroll_up increment
		if $scrolled_y != 0
			if $scrolled_y+$width+increment > $full_size_x
				$scrolled_y = $full_size_x-$width
			else
				$scrolled_y += increment
			end
			$scroll_list_y.each do |c|
				c.scroll_y
			end
		end
	end
	def scroll_down increment
		if 1-$scrolled_y != $full_size_y
			if $scrolled_y-increment < 1-$full_size_y
				$scrolled_y = 1-$full_size_y
			else
				$scrolled_y -= increment
			end
			$scroll_list_y.each do |c|
				c.scroll_y
			end
		end
	end
end

Scroll_Bar_X.new
Scroll_Bar_Y.new