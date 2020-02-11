$scrolled_x = 0 # scroll progress for each direction
$scrolled_y = 0
$future_scrolled_x = 0 # scrolls to be implemented on next refresh
$future_scrolled_y = 0
$full_size_x = 0 # total width/height of all objects
$full_size_y = 0
$scroll_list_x = [] # list of all elements scrollable by direction
$scroll_list_y = []

class Scroll_Button
	def initialize x, y, image, action
		@x = x
		@y = y
		@image = image
		@action = action
		@color = $colors["button_deselected"]
		@mouse_downed = false # saves if the mouse went down over this object
		@button_image = Image.new @image, x: @x, y: @y, width: 10, height: 10, color: $colors["background"], z: 8
		draw
		$all_buttons.push self
	end
	def draw
		# remove
		@button.remove
		# draw
		@button = Rectangle.new x: @x, y: @y, width: 10, height: 10, color: @color, z: 7
	end
	def click event
		if @button.contains? event.x, event.y and @mouse_downed
			@color = $colors["button_deselected"]
			draw
			@action.call
		end
	end
	def mouse_down event
		if @button.contains? event.x, event.y
			@mouse_downed = true
			@color = $colors["button_selected"]
			draw
			return true # if the button was clicked
		end
		false
	end
	def mouse_up
		@mouse_downed = false
		@color = $colors["button_deselected"]
		draw
	end
end

class Scroll_Bar_X
	def initialize
		@container = Rectangle.new x: 0, y: $height-10, width: $width-10, height: 10, color: [0, 0, 0, 0]
		@button_left = Scroll_Button.new 0, $height-10, "resources/images/scroll/left_scroll.png", Proc.new { $scroll_bar_x.scroll_left 21 }
		@button_right = Scroll_Button.new $width-20, $height-10, "resources/images/scroll/right_scroll.png", Proc.new { $scroll_bar_x.scroll_right 21 }
		@bar_selected = false
		$scroll_bar_x = self
	end
	def draw
		# remove
		@bar.remove
		# draw
		w = ($width-20)*(($width*1.0)/($full_size_x+$width))
		@bar = Rectangle.new x: ($width-20-($width/w))/(($width+$full_size_x+1.0)/($scrolled_x)), y: $height-10, width: w, height: 10, color: $colors["button_deselected"], z: 6
	end
	def click event
		@bar_selected = false
		if @container.contains? event.x, event.y
			@button_left.click event
			@button_right.click event
		end
	end
	def mouse_down event
		if @container.contains? event.x, event.y
			if !@button_left.mouse_down event and !@button_right.mouse_down event
				@bar_selected = true
				$future_scrolled_x = ((event.x/(($width*1.0)/($full_size_x+$width)))-($width/2)).round_to 21
				if $future_scrolled_x > $full_size_x
					$future_scrolled_x = $full_size_x
				elsif $future_scrolled_x < 0
					$future_scrolled_x = 0
				end
			end
		end
	end
	def mouse_move event
		if @bar_selected
			$future_scrolled_x = ((event.x/(($width*1.0)/($full_size_x+$width)))-($width/2)).round_to 21
			if $future_scrolled_x > $full_size_x
				$future_scrolled_x = $full_size_x
			elsif $future_scrolled_x < 0
				$future_scrolled_x = 0
			end
		end
	end
	def scroll_left increment
		if $future_scrolled_x != 0
			if $future_scrolled_x-increment < 0
				$future_scrolled_x = 0
			else
				$future_scrolled_x -= increment
			end
		end
	end
	def scroll_right increment
		if $future_scrolled_x != $full_size_x
			if $future_scrolled_x+increment > $full_size_x
				$future_scrolled_x = $full_size_x
			else
				$future_scrolled_x += increment
			end
		end
	end
	def determine
		h = 0
		$containers.select{ |c| c.respond_to? "get_last_sound" }.each do |c|
			a = c.get_last_sound
			if a > h
				h = a
			end
		end
		$full_size_x = h
		if $full_size_x > 41664
			$full_size_x = 41664
			Popup_Info.new "Warframe limits songs to 4:16."
		end
		draw
	end
end
class Scroll_Bar_Y
	def initialize
		@container = Rectangle.new x: $width-10, y: 0, width: 10, height: $height-10, color: [0, 0, 0, 0]
		@button_up = Scroll_Button.new $width-10, 0, "resources/images/scroll/up_scroll.png", Proc.new{ $scroll_bar_y.scroll_up 21 }
		@button_down = Scroll_Button.new $width-10, $height-20, "resources/images/scroll/down_scroll.png", Proc.new{ $scroll_bar_y.scroll_down 21 }
		@bar_selected = false
		$scroll_bar_y = self
	end
	def draw
		# remove
		@bar.remove
		# draw
		h = ($height-20)*(($height*1.0)/($full_size_y+$height))
		@bar = Rectangle.new x: $width-10, y: ($height-20-($height/h))/(($height+$full_size_y+1.0)/(0-$scrolled_y)), width: 10, height: h, color: $colors["button_deselected"], z: 6
	end
	def click event
		@bar_selected = false
		if @container.contains? event.x, event.y
			@button_up.click event
			@button_down.click event
		end
	end
	def mouse_down event
		if @container.contains? event.x, event.y
			if !@button_down.mouse_down event and !@button_up.mouse_down event
				@bar_selected = true
				$future_scrolled_y = (0-((event.y/(($height*1.0)/($full_size_y+$height)))-($height/2))).round_to 21
				if $future_scrolled_y > 0
					$future_scrolled_y = 0
				elsif $future_scrolled_y < 0-$full_size_y
					$future_scrolled_y = 0-$full_size_y
				end
			end
		end
	end
	def mouse_move event
		if @bar_selected
			$future_scrolled_y = (0-((event.y/(($height*1.0)/($full_size_y+$height)))-($height/2))).round_to 21
			if $future_scrolled_y > 0
				$future_scrolled_y = 0
			elsif $future_scrolled_y < 0-$full_size_y
				$future_scrolled_y = 0-$full_size_y
			end
		end
	end
	def scroll_up increment
		if $future_scrolled_y != 0
			if $future_scrolled_y+increment > 0
				$future_scrolled_y = 0
			else
				$future_scrolled_y += increment
			end
		end
	end
	def scroll_down increment
		if 0-$future_scrolled_y != $full_size_y
			if $future_scrolled_y-increment < 0-$full_size_y
				$future_scrolled_y = 0-$full_size_y
			else
				$future_scrolled_y -= increment
			end
		end
	end
	def determine
		if $containers[-1].y+$containers[-1].container.height < $height
			$full_size_y = 0
		else
			$full_size_y = $containers[-1].y+$containers[-1].container.height-$height+20
		end
		draw
	end
end

Scroll_Bar_X.new
Scroll_Bar_Y.new