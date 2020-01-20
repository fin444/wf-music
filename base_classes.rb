# Misc. Functions
def add_zeros number, length
	number = number.to_s
	if number.length != length
		(length-number.length).times do
			number = "0#{number}"
		end
	end
	number
end
def reposition_all # make all containers have proper y value after one is deleted
	$containers.each do |c|
		c.reposition
	end
	if !$playing_bar.nil?
		$playing_bar.remove
		$playing_bar = Line.new x1: $playing_counter, y1: $containers[0].container.height, x2: $playing_counter, y2: $height, color: $colors["note"], width: 3, z: 8
	end
end
def get_text_width text, size
	width_getter = Text.new text, x: 0, y: 0, size: size, color: [0, 0, 0, 0]
	w = width_getter.width
	width_getter.remove
	w
end
def get_text_height text, size
	height_getter = Text.new text, x: 0, y: 0, size: size, color: [0, 0, 0, 0]
	h = height_getter.height
	height_getter.remove
	h
end

# Base Classes
class UI_Element # inherited by all main ui elements
	attr_accessor :y, :container
	def initialize
		# determine what type it is, and have some values from that
		case self.class.name
		when "Top_UI"
			@height = 120
			@text = ""
		when "Shawzin_UI"
			@height = 280
			@text = "Shawzin"
		when "Mandachord_UI"
			@height = 310
			@text = "Mandachord"
		when "Lure_UI"
			@height = 220
			@text = "Echo Lure"
		when "Add_UI"
			@height = 40
			@text = ""
		end
		# generate base stuff
		@y = determine_y -1
		@container = Rectangle.new x: 50, y: @y, width: $width-100, height: @height, color: [0, 0, 0, 0]
		@name = Text.new @text, x: 55, y: @y, size: 17, color: $colors["string"]
		@delete_button = Delete_Button.new $width-70, @y, self
		draw # individual for each sub-class
		$containers.push self
	end
	def determine_y index # automatically stack all of the ui elements
		if $containers.length > 0
			return $containers[index].y+$containers[index].container.height
		end
		0
	end
	def reposition # fix the y-values after a deletion
		@y = determine_y $containers.find_index(self)-1
		@container.remove
		@name.remove
		@delete_button.remove
		@container = Rectangle.new x: 50, y: @y, width: $width-100, height: @height, color: $colors["background"]
		@name = Text.new @text, x: 55, y: @y, size: 17, color: $colors["string"]
		@delete_button = Delete_Button.new $width-70, @y, self
		reposition_unique
	end
	# defining for redundancy, not every ui element has all of these
	def draw # draw everything
	end
	def click event # handle clicks
	end
	def mouse_down event # handle mouse downs
	end
	def play x # play all sounds at the location x
	end
	def get_last_sound # find out how long to play
		0 # signifies that it does not contain notes
	end
	def remove # remove the element and all children
	end
	def reposition_unique # the specific reposition for each ui_element
	end
	def export # export to the game
	end
end

class Dropdown
	attr_accessor :x, :z, :width, :selected
	def initialize x, y, options, selected, update
		@x = x
		@y = y
		@options = options
		@update = update
		@drawn_options = []
		@options_containers = []
		@selected = selected
		@z = 0 # can be manipulated by outside scripts if need be
		@height = 19 # to be changed when open/closed
		@open = false
		@first_draw = true
		h = ""
		options.each do |o|
			if o.length > h.length
				h = o
			end
		end
		@text_width = get_text_width h, 17
		@selected_container = Rectangle.new x: @x, y: @y, width: @text_width+20, height: 19, color: [0, 0, 0, 0] # static container to detect if the top area is clicked
		@width = @text_width+22 # to be read by external scripts, not actually used for anything internally
		draw
	end
	def draw
		if !@first_draw
			@outline.remove
			@container.remove
			@arrow.remove
			@drawn_selected.remove
			@drawn_options.each do |d|
				d.remove
			end
			@drawn_options = []
			@options_containers.each do |d|
				d.remove
			end
			@options_containers = []
		else
			@first_draw = false
		end
		@outline = Rectangle.new x: @x-1, y: @y-1, width: @text_width+22, height: @height+2, color: $colors["string"], z: @z
		@container = Rectangle.new x: @x, y: @y, width: @text_width+20, height: @height, color: $colors["background"], z: @z
		@drawn_selected = Text.new @selected, x: @x+1, y: @y, size: 17, color: $colors["string"], z: @z
		if @open
			@arrow = Triangle.new x1: @x+@container.width-15, y1: @y+15, x2: @x+@container.width-2, y2: @y+15, x3: @x+@container.width-8, y3: @y+7, color: $colors["string"], z: @z
			@options.each do |o|
				@options_containers.push Rectangle.new x: @x, y: @y+20*((@options.find_index o)+1), width: @text_width+20, height: 20, color: $colors["background"], z: @z
				@drawn_options.push Text.new o, x: @x+1, y: @y+20*((@options.find_index o)+1), size: 17, color: $colors["string"], z: @z
			end
		else
			@arrow = Triangle.new x1: @x+@container.width-15, y1: @y+7, x2: @x+@container.width-2, y2: @y+7, x3: @x+@container.width-8, y3: @y+15, color: $colors["string"], z: @z
		end
	end
	def click event
		if @container.contains? event.x, event.y
			if @open
				@options_containers.each do |c|
					if c.contains? event.x, event.y
						@selected = @options[@options_containers.find_index c]
						close # no need to draw because that is done in the close method
					end
				end
				if @selected_container.contains? event.x, event.y
					close
				end
				@update.call @selected
			else
				@open = true
				@height = (@options.length+1)*20+2
				draw
				$open_dropdown = self
			end
			return true # tell click handler that click was on this element
		elsif @open
			close
			return false # tell click handler that click wasn't on this element
		end
		false # tell click handler that click wasn't on this element
	end
	def close
		@open = false
		@height = 22
		draw
		$open_dropdown = nil
	end
	def remove
		@outline.remove
		@container.remove
		@arrow.remove
		@drawn_selected.remove
		@selected_container.remove
		@drawn_options.each do |d|
			d.remove
		end
		@options_containers.each do |d|
			d.remove
		end
	end
end

class Text_Input
	def initialize x, y
		@x = x
		@y = y
		@text = ""
		@z = 0 # can be manipulated by outside scripts if need be
		@selected = false
		draw
		$all_buttons.push self
	end
	def draw
	end
	def click event
		if @selected
			# TODO
		else
			@selected = true
			$open_input = self
			draw
		end
	end
	def key_press event
	end
	def mouse_down event
	end
	def mouse_up
	end
	def remove
	end
	def hide
	end
end

# buttons
class Delete_Button
	attr_accessor :z, :x, :y, :hidden
	def initialize x, y, ui_element
		@x = x
		@y = y
		@ui_element = ui_element
		@z = 0 # can be manipulated by outside scripts if need be
		@hidden = false
		@color = $colors["button_deselected"]
		@container = Rectangle.new x: @x, y: @y, width: 20, height: 20, color: [0, 0, 0, 0]
		@first_draw = true
		draw
		$all_buttons.push self
	end
	def draw
		if !@first_draw
			@text.remove
		else
			@first_draw = false
		end
		@text = Text.new "x", x: @x, y: @y-15, size: 35, color: @color, z: @z
	end
	def click event
		if @container.contains? event.x, event.y
			@ui_element.remove
		end
	end
	def mouse_down event
		if @container.contains? event.x, event.y
			@color = $colors["button_selected"]
			draw
		end
	end
	def mouse_up
		@color = $colors["button_deselected"]
		draw
	end
	def remove
		@container.remove
		@text.remove
		$all_buttons.delete_at $all_buttons.find_index self
	end
end
class Quad_Button
	attr_accessor :image_url, :z, :x, :y, :action, :hidden, :color
	def initialize text, x, y, image_url, action
		@text = text
		@x = x
		@y = y
		@image_url = image_url
		@action = action
		@hidden = false
		@z = 0 # can be manipulated by outside scripts if need be
		@color = $colors["button_deselected"]
		@first_draw = true
		draw
		$all_buttons.push self
	end
	def draw
		@hidden = false # using draw function unhides it, not drawing if hidden occurs in other scripts
		# remove first
		if !@first_draw
			@button_1.remove
			@button_2.remove
			@button_text.remove
			@image.remove
		else
			@first_draw = false
		end
		# need two to make a button because of bug in ruby2d where Quad doesn't display fully
		@button_1 = Quad.new x1: @x, y1: @y+30, x2: @x+30, y2: @y, x3: @x+30, y3: @y+60, x4: @x+60, y4: @y+30, color: @color, z: @z
		@button_2 = Triangle.new x1: @x+30, y1: @y, x2: @x+60, y2: @y+30, x3: @x+30, y3: @y+30, color: @color, z: @z
		@button_text = Text.new @text, x: @x+30-get_text_width(@text, 15)/2, y: @y+65, size: 15, color: $colors["note"], z: @z
		@image = Image.new @image_url, x: @x+15, y: @y+15, width: 30, height: 30, color: $colors["background"], z: @z
	end
	def click event
		if @button_1.contains? event.x, event.y or @button_2.contains? event.x, event.y
			@action.call
		end
	end
	def mouse_down event
		if @button_1.contains? event.x, event.y or @button_2.contains? event.x, event.y
			@color = $colors["button_selected"]
			draw
		end
	end
	def mouse_up
		@color = $colors["button_deselected"]
		draw
	end
	def remove
		@button_1.remove
		@button_2.remove
		@button_text.remove
		@image.remove
		$all_buttons.delete_at $all_buttons.find_index self
	end
	def hide # hides the button without removing it
		@button_1.remove
		@button_2.remove
		@button_text.remove
		@image.remove
		@hidden = true
	end
end
class Toggle_Quad_Button < Quad_Button # @action will be Boolean instead of Proc
	def click event
		if @button_1.contains? event.x, event.y or @button_2.contains? event.x, event.y
			@action = !@action
			if @action
				@color = $colors["button_selected"]
			else
				@color = $colors["button_deselected"]
			end
			draw
			@action # returns value of @action to be used
		end
	end
	# not needed because color changes differently
	def mouse_down event
	end
	def mouse_up
	end
end
class Text_Button
	attr_accessor :z, :x, :y, :hidden, :width, :height
	def initialize text, x, y, font_size, action
		@text = text
		@x = x
		@y = y
		@font_size = font_size
		@action = action
		@z = 0 # can be manipulated by outside scripts if need be
		@hidden = false
		@first_draw = true
		@color = $colors["button_deselected"]
		@width = get_text_width(@text, @font_size)+10
		@height = @font_size+3
		draw
		$all_buttons.push self
	end
	def draw
		@hidden = false # using draw function unhides it, not drawing if hidden occurs in other scripts
		# remove first
		if !@first_draw
			@button.remove
			@button_text.remove
		else
			@first_draw = false
		end
		@button = Rectangle.new x: @x, y: @y, width: @width, height: @height, color: @color, z: @z
		@button_text = Text.new @text, x: @x+5, y: @y, size: @font_size, color: $colors["background"], z: @z
	end
	def click event
		if @button.contains? event.x, event.y
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
	def remove
		@button.remove
		@button_text.remove
		$all_buttons.delete_at $all_buttons.find_index self
	end
	def hide # hides the button without removing it
		@button.remove
		@button_text.remove
		@hidden = true
	end
end