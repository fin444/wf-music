$all_scales = ["Pentatonic Minor", "Pentatonic Major", "Chromatic", "Hexatonic", "Major", "Minor", "Hirajoshi", "Phrygian", "Yo"]
$shawzin_settings = [false, false, false]

class Shawzin_UI < UI_Element
	attr_accessor :notes
	def draw
		@scale = $all_scales[0]
		@line_1 = Line.new x1: 50, y1: @y+80, x2: $width-50, y2: @y+80, width: 4, color: $colors["string"]
		@line_2 = Line.new x1: 50, y1: @y+160, x2: $width-50, y2: @y+160, width: 4, color: $colors["string"]
		@line_3 = Line.new x1: 50, y1: @y+240, x2: $width-50, y2: @y+240, width: 4, color: $colors["string"]
		@notes = []
	end
	def click event
		if event.y > @y+20
			if event.x < 50 or event.x > $width-50 # don't put outside the strings on left or right
			elsif event.y <= @y+120 # if below halfway between string 1 and string 2
				@notes.push Shawzin_Note.new 1, y, $shawzin_settings, event.x
			elsif event.y <= @y+200 # if below halfway between string 2 and string 3
				@notes.push Shawzin_Note.new 2, y, $shawzin_settings, event.x
			else
				@notes.push Shawzin_Note.new 3, y, $shawzin_settings, event.x
			end
			if $containers[0].editing
				$containers[0].editing_buttons[4].action.call
			end
		else
			@delete_button.click event
		end
	end
	def mouse_down event
		@delete_button.mouse_down event
	end
	def right_click event
		@notes.each do |n|
			if n.drawn.contains? event.x, event.y
				if $containers[0].editing
					$containers[0].editing_buttons[4].action.call
				end
				n.color = $colors["button_selected"]
				n.draw
				$containers[0].edit n
			end
		end
	end
	def get_last_sound
		h = 0
		@notes.each do |n|
			if n.x > h
				h = n.x
			end
		end
		h
	end
	def play x
		@notes.select{|n| n.x == x }.each do |n|
			n.play @scale
		end
	end
	def remove
		@notes.each do |n|
			n.remove
		end
		@delete_button.remove
		@name.remove
		@line_1.remove
		@line_2.remove
		@line_3.remove
		@container.remove
		$containers.delete_at $containers.find_index self
		reposition_all
	end
	def reposition_unique
		@line_1.remove
		@line_2.remove
		@line_3.remove
		@line_1 = Line.new x1: 50, y1: @y+80, x2: $width-50, y2: @y+80, width: 4, color: $colors["string"]
		@line_2 = Line.new x1: 50, y1: @y+160, x2: $width-50, y2: @y+160, width: 4, color: $colors["string"]
		@line_3 = Line.new x1: 50, y1: @y+240, x2: $width-50, y2: @y+240, width: 4, color: $colors["string"]
		@notes.each do |n|
			n.container_y = @y
			n.draw
		end
	end
	def export # all data information is based off of the warframe wiki
		# limit 4:16 song with 1666 notes
		str = (($all_scales.find_index @scale)+1).to_s
		note_chars = "BCDEFGHJKLMNOPRSTUVWXhijklmnZabcdefpqrstuvxyz012356789+/"
		time_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
		@notes = @notes.sort_by { |n| n.x }
		@notes.each do |n|
			num = n.string-1
			if num == 3
				num = 4
			end
			case n.options
			when [false, false, false]
				num += 0
			when [true, false, false]
				num += 7
			when [false, true, false]
				num += 14
			when [false, false, true]
				num += 21
			when [true, true, false]
				num += 28
			when [true, false, true]
				num += 35
			when [false, true, true]
				num += 42
			when [true, true, true]
				num += 49
			end
			str += note_chars[num] # first character is note
			str += time_chars[(n.x-50)/670] # second character is measure (1/64 of song)
			str += time_chars[((n.x-50)%670)/60] # third character is 1/64 of measure
		end
		str
	end
end

class Shawzin_Note
	attr_accessor :x, :container_y, :string, :options, :drawn, :color
	def initialize string, container_y, options, x
		@string = string
		@container_y = container_y
		@options = options.dup
		@x = x
		@first_draw = true
		@color = $colors["note"]
		draw
	end
	def play scale # get url for the sound to play
		url = "resources/sounds/shawzin/#{scale}/#{@string}"
		if @options[0]
			url += "sky"
		end
		if @options[1]
			url += "earth"
		end
		if @options[2]
			url += "water"
		end
		puts "[#{Time.now.strftime("%I:%M:%S")}] #{url}"
	end
	def draw
		if !@first_draw # removes all current, but if they don't exist yet then it doesn't
			@drawn.remove
			@drawn_sky.remove
			@drawn_earth.remove
			@drawn_water.remove
		end
		@first_draw = false
		@drawn = Circle.new x: @x, y: @string*80+@container_y, radius: 20, color: @color
		if !@options[0] # draw either circle to show false
			@drawn_sky = Circle.new x: @drawn.x-20, y: @drawn.y-35, radius: 4, color: @color
		else # or mouse button to show true
			@drawn_sky = Image.new "resources/images/left_mouse_button.png", x: @drawn.x-31, y: @drawn.y-47, width: 16, height: 24, color: @color
		end
		if !@options[1]
			@drawn_earth = Circle.new x: @drawn.x, y: @drawn.y-35, radius: 4, color: @color
		else
			@drawn_earth = Image.new "resources/images/middle_mouse_button.png", x: @drawn.x-8, y: @drawn.y-47, width: 16, height: 24, color: @color
		end
		if !@options[2]
			@drawn_water = Circle.new x: @drawn.x+20, y: @drawn.y-35, radius: 4, color: @color
		else
			@drawn_water = Image.new "resources/images/right_mouse_button.png", x: @drawn.x+16, y: @drawn.y-47, width: 16, height: 24, color: @color
		end
	end
	def remove
		@drawn.remove
		@drawn_sky.remove
		@drawn_earth.remove
		@drawn_water.remove
		$containers.select{ |c| c.class.name == "Shawzin_UI" }.each do |c|
			if c.notes.any?{ |n| n == self }
				c.notes.delete_at c.notes.find_index self
			end
		end
	end
end