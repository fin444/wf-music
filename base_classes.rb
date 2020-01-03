# ui elements
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
			@height = 200
			@text = "Echo_Lure"
		when "Add_UI"
			@height = 40
			@text = ""
		end
		# generate base stuff
		@y = determine_y -1
		@container = Rectangle.new x: 50, y: @y, width: $width-100, height: @height, color: $colors["background"]
		@name = Text.new @text, x: 55, y: @y, size: 17, color: $colors["string"]
		@delete_button = Delete_Button.new $width-70, @y, self
		draw # individual for each sub-class
		$containers.push self
	end
	def determine_y index # automatically stack all of the ui elements
		if $containers.length > 0
			return $containers[index].container.height+$containers[index].y
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

# buttons
class Delete_Button
	attr_accessor :z, :x, :y
	def initialize x, y, ui_element
		@x = x
		@y = y
		@ui_element = ui_element
		@z = 0
		@color = $colors["button_deselected"]
		@container = Rectangle.new x: @x, y: @y, width: 20, height: 20, color: [0, 0, 0, 0.0]
		draw
		$all_buttons.push self
	end
	def draw
		if !@text.nil?
			@text.remove
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
	attr_accessor :image_url, :z, :x, :y
	def initialize text, x, y, image_url, action
		@text = text
		@x = x
		@y = y
		@image_url = image_url
		@action = action
		@z = 0
		@color = $colors["button_deselected"]
		@first_draw = true
		draw
		$all_buttons.push self
	end
	def draw
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
		@button_text = Text.new @text, x: @x+30-determine_text_width(@text, 15)/2, y: @y+65, size: 15, color: $colors["note"], z: @z
		@image = Image.new @image_url, x: @x+15, y: @y+15, width: 30, height: 30, color: $colors["background"], z: @z+1
	end
	def click event # placeholder, class is extended with this function
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
		$all_buttons.delete_at $all_buttons.find_index self
	end
end
class Text_Button
	attr_accessor :height, :z, :x, :y
	def initialize text, x, y, action
		@text = text
		@x = x
		@y = y
		@action = action
		@z = 0
		@height = 25 # to return in Export_Window's determine_element_y method
		@first_draw = true
		@color = $colors["button_deselected"]
		draw
		$all_buttons.push self
	end
	def draw
		# remove first
		if !@first_draw
			@button.remove
			@button_text.remove
		else
			@first_draw = false
		end
		@button = Rectangle.new x: @x, y: @y, width: determine_text_width(@text, 22)+10, height: 25, color: @color, z: @z
		@button_text = Text.new @text, x: @x+5, y: @y, size: 22, color: $colors["background"], z: @z+1
	end
	def click event # placeholder, class is extended with this function
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
end