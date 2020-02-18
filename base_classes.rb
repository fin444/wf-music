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
	change
end
def change # will be used for undo/redo functions in future
	$saved = false
	$scroll_bar_x.determine
	$scroll_bar_y.determine
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

# Monkeypatch to remove need for @first_draw
class NilClass
	def remove
	end
end

# Base Classes
class Dropdown
	attr_accessor :x, :y, :width, :selected, :container
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
		@mouse_downed = false # saves if the mouse went down over this object
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
		# remove
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
		# draw
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
		if @container.contains? event.x, event.y and @mouse_downed
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
	def mouse_down event
		if @container.contains? event.x, event.y
			@mouse_downed = true
		end
	end
	def mouse_up
		@mouse_downed = false
	end
	def close
		@open = false
		@height = 19
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
	def z= z
		@z = z
		draw
	end
end
class Delete_Button
	attr_accessor :x, :y
	def initialize x, y, ui_element
		@x = x
		@y = y
		@ui_element = ui_element
		@z = 0 # can be manipulated by outside scripts if need be
		@color = $colors["button_deselected"]
		@mouse_downed = false # saves if the mouse went down over this object
		draw
		$all_buttons.push self
	end
	def draw
		# remove
		@text.remove
		@container.remove
		# draw
		@container = Rectangle.new x: @x, y: @y, width: 20, height: 20, color: [0, 0, 0, 0]
		@text = Text.new "x", x: @x, y: @y-15, size: 35, color: @color, z: @z
	end
	def click event
		if @container.contains? event.x, event.y and @mouse_downed
			@ui_element.remove
		end
	end
	def mouse_down event
		if @container.contains? event.x, event.y
			@mouse_downed = true
			@color = $colors["button_selected"]
			draw
		end
	end
	def mouse_up
		@mouse_downed = false
		if @color != $colors["button_deselected"]
			@color = $colors["button_deselected"]
			draw
		end
	end
	def remove
		@container.remove
		@text.remove
		$all_buttons.delete_at $all_buttons.find_index self
	end
	def hide
		@container.remove
		@text.remove
	end
	def z= z
		@z = z
		draw
	end
end
class Quad_Button
	attr_accessor :image_url, :x, :y, :action, :color, :text
	def initialize text, x, y, image_url, action
		@text = text
		@x = x
		@y = y
		@image_url = image_url
		@action = action
		@z = 0 # can be manipulated by outside scripts if need be
		@color = $colors["button_deselected"]
		@hidden = false # to define whether it's currently hidden so it doesn't draw on mouse_up
		@mouse_downed = false # saves if the mouse went down over this object
		draw
		$all_buttons.push self
	end
	def draw
		@hidden = false
		# remove
		@outline.remove
		@inner.remove
		@button_text.remove
		@image.remove
		# draw
		@outline = Quad.new x1: @x, y1: @y+30, x2: @x+30, y2: @y, x3: @x+60, y3: @y+30, x4: @x+30, y4: @y+60, color: @color, z: @z
		@inner = Quad.new x1: @x+2, y1: @y+30, x2: @x+30, y2: @y+2, x3: @x+58, y3: @y+30, x4: @x+30, y4: @y+58, color: $colors["background"], z: @z
		@button_text = Text.new @text, x: @x+30-get_text_width(@text, 15)/2, y: @y+65, size: 15, color: $colors["note"], z: @z
		@image = Image.new @image_url, x: @x+15, y: @y+15, width: 30, height: 30, color: @color, z: @z
	end
	def click event
		if @outline.contains? event.x, event.y and @mouse_downed
			@action.call
		end
	end
	def mouse_down event
		if @outline.contains? event.x, event.y and !@hidden
			@mouse_downed = true
			@color = $colors["button_selected"]
			draw
		end
	end
	def mouse_up
		@mouse_downed = false
		@color = $colors["button_deselected"]
		if !@hidden
			draw
		end
	end
	def remove
		@outline.remove
		@inner.remove
		@button_text.remove
		@image.remove
		$all_buttons.delete_at $all_buttons.find_index self
	end
	def hide # hides the button without removing it
		@hidden = true
		@outline.remove
		@inner.remove
		@button_text.remove
		@image.remove
	end
	def z= z
		@z = z
		draw
	end
end
class Toggle_Quad_Button < Quad_Button # @action will be Boolean instead of Proc
	def click event
		if (@outline.contains? event.x, event.y or @outline.contains? event.x, event.y) and @mouse_downed
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
	def mouse_down event
		if @outline.contains? event.x, event.y
			@mouse_downed = true
		end
	end
	def mouse_up
		@mouse_downed = false
	end
end
class Text_Button
	attr_accessor :x, :y, :width, :height
	def initialize text, x, y, font_size, action
		@text = text
		@x = x
		@y = y
		@font_size = font_size
		@action = action
		@z = 0 # can be manipulated by outside scripts if need be
		@mouse_downed = false # saves if the mouse went down over this object
		@color = $colors["button_deselected"]
		@width = get_text_width(@text, @font_size)+10
		@height = @font_size+3
		draw
		$all_buttons.push self
	end
	def draw
		# remove
		@button.remove
		@underline.remove
		@button_text.remove
		# draw
		@button = Rectangle.new x: @x, y: @y, width: @width, height: @height, color: [0, 0, 0, 0]
		@underline = Line.new x1: @x, y1: @y+@font_size+4, x2: @x+@width, y2: @y+@font_size+4, width: 2, color: @color, z: @z
		@button_text = Text.new @text, x: @x+5, y: @y, size: @font_size, color: @color, z: @z
	end
	def click event
		if @button.contains? event.x, event.y and @mouse_downed
			@action.call
		end
	end
	def mouse_down event
		if @button.contains? event.x, event.y
			@mouse_downed = true
			@color = $colors["button_selected"]
			draw
		end
	end
	def mouse_up
		@mouse_downed = false
		if @color != $colors["button_deselected"]
			@color = $colors["button_deselected"]
			draw
		end
	end
	def remove
		@button.remove
		@underline.remove
		@button_text.remove
		$all_buttons.delete_at $all_buttons.find_index self
	end
	def hide # hides the button without removing it
		@button.remove
		@underline.remove
		@button_text.remove
	end
	def z= z
		@z = z
		draw
	end
end
class Gear_Button
	attr_accessor :x, :y
	def initialize x, y, action
		@x = x
		@y = y
		@action = action
		@z = 0 # can be manipulated by outside scripts if need be
		@color = $colors["button_deselected"]
		@mouse_downed = false # saves if the mouse went down over this object
		draw
		$all_buttons.push self
	end
	def draw
		# remove
		@container.remove
		@image.remove
		# draw
		@container = Rectangle.new x: @x, y: @y, width: 20, height: 20, color: [0, 0, 0, 0]
		@image = Image.new "resources/images/gear.png", x: @x, y: @y, width: 20, height: 20, color: @color, z: @z
	end
	def click event
		if @container.contains? event.x, event.y and @mouse_downed
			@color = $colors["button_deselected"]
			@action.call
			draw
		end
	end
	def mouse_down event
		if @container.contains? event.x, event.y
			@mouse_downed = true
			@color = $colors["button_selected"]
			draw
		end
	end
	def mouse_up
		@mouse_downed = false
		if @color != $colors["button_deselected"]
			@color = $colors["button_deselected"]
			draw
		end
	end
	def remove
		@container.remove
		@image.remove
		$all_buttons.delete_at $all_buttons.find_index self
	end
	def hide
		@container.remove
		@image.remove
	end
	def z= z
		@z = z
		draw
	end
end
class Key_Button
	attr_accessor :z
	def initialize x, y, key, action
		@x = x
		@y = y
		@key = key
		@action = action
		@z = 0 # can be manipulated by outside scripts if need be
		@mouse_downed = false # saves if the mouse went down over this object
		@color = $colors["button_deselected"]
		draw
		$all_buttons.push self
	end
	def draw
		# remove
		@outline.remove
		@button.remove
		@text.remove
		# draw
		@outline = Rectangle.new x: @x-1, y: @y-1, width: 22, height: 22, color: @color, z: @z
		@button = Rectangle.new x: @x, y: @y, width: 20, height: 20, color: $colors["background"], z: @z
		@text = Text.new @key.upcase, x: @x+9-(get_text_width(@key.upcase, 20)/2), y: @y-1, size: 20, color: @color, z: @z
	end
	def click event
		if @outline.contains? event.x, event.y and @mouse_downed
			if $active_key_button == self
				$active_key_button = nil
				@color = $colors["button_deselected"]
				draw
			else
				if $active_key_button.nil?
					$active_key_button = self
					@color = $colors["button_selected"]
					draw
				end
			end
		end
	end
	def mouse_down event
		if @outline.contains? event.x, event.y
			@mouse_downed = true
		end
	end
	def mouse_up
		@mouse_downed = false
	end
	def key_down event
		@key = event.key
		$active_key_button = nil
		@color = @color = $colors["button_deselected"]
		@action.call @key
		draw
	end
	def remove
		if $active_key_button == self
			$active_key_button = nil
		end
		@outline.remove
		@button.remove
		@text.remove
		$all_buttons.delete_at $all_buttons.find_index self
	end
	def z= z
		@z = z
		draw
	end
end
class Check_Box
	attr_accessor :z, :checked
	def initialize x, y, checked, text, action
		@x = x
		@y = y
		@checked = checked
		@text = text
		@action = action
		@z = 0 # can be manipulated by outside scripts if need be
		@mouse_downed = false # saves if the mouse went down over this object
		draw
		$all_buttons.push self
	end
	def draw
		# remove
		@container.remove
		@outline.remove
		@cover.remove
		@writing.remove
		@inner.remove
		# draw
		@container = Rectangle.new x: @x, y: @y, width: 20+get_text_width(@text, 20), height: 20, color: [0, 0, 0, 0]
		@outline = Rectangle.new x: @x, y: @y, width: 20, height: 20, color: $colors["string"], z: @z
		@cover = Rectangle.new x: @x+1, y: @y+1, width: 18, height: 18, color: $colors["background"], z: @z
		@writing = Text.new @text, x: @x+25, y: @y, size: 20, color: $colors["string"], z: @z
		if @checked
			@inner = Rectangle.new x: @x+3, y: @y+3, width: 14, height: 14, color: $colors["string"], z: @z
		end
	end
	def click event
		if @container.contains? event.x, event.y and @mouse_downed
			@checked = !@checked
			draw
			@action.call @checked
		end
	end
	def mouse_down event
		if @container.contains? event.x, event.y
			@mouse_downed = true
		end
	end
	def mouse_up
		@mouse_downed = false
	end
	def remove
		@container.remove
		@outline.remove
		@cover.remove
		@writing.remove
		@inner.remove
		$all_buttons.delete_at $all_buttons.find_index self
	end
	def z= z
		@z = z
		draw
	end
end
class Image_Button
	attr_accessor :z
	def initialize x, y, image_url, size, action
		@x = x
		@y = y
		@image_url = image_url
		@size = size
		@action = action
		@z = 0 # can be manipulated by outside scripts if need be
		@hidden = false # to define whether it's currently hidden so it doesn't draw on mouse_up
		@mouse_downed = false # saves if the mouse went down over this object
		@color = $colors["button_deselected"]
		@container = Rectangle.new x: @x, y: @y, width: @size, height: @size, color: [0, 0, 0, 0]
		draw
		$all_buttons.push self
	end
	def draw
		@hidden = false
		# remove
		@image.remove
		# draw
		@image = Image.new @image_url, x: @x, y: @y, width: @size, height: @size, color: @color, z: @z
	end
	def click event
		if @container.contains? event.x, event.y and @mouse_downed
			@action.call
		end
	end
	def mouse_down event
		if @container.contains? event.x, event.y and !@hidden
			@color = $colors["button_selected"]
			@mouse_downed = true
			draw
		end
	end
	def mouse_up
		@mouse_downed = false
		@color = $colors["button_deselected"]
		if !@hidden
			draw
		end
	end
	def remove
		@container.remove
		@image.remove
		$all_buttons.delete_at $all_buttons.find_index self
	end
	def hide
		@container.remove
		@image.remove
		@hidden = true
	end
	def z= z
		@z = z
		draw
	end
end