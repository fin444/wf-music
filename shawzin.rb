$all_scales = ["Pentatonic Minor", "Pentatonic Major", "Chromatic", "Hexatonic", "Major", "Minor", "Hirajoshi", "Phrygian", "Yo"]
$all_shawzin_types = ["Normal", "Nelumbo", "Corba"]

class Shawzin_UI
	attr_accessor :notes, :scale, :type, :y, :container
	def initialize
		@height = 280
		@y = $containers[-1].y+$containers[-1].container.height+5
		@container = Rectangle.new x: 50, y: @y+$scrolled_y, width: $width-100, height: @height, color: [0, 0, 0, 0]
		@name = Text.new "Shawzin", x: 80, y: @y+$scrolled_y, size: 17, color: $colors["string"]
		@delete_button = Delete_Button.new $width-70, @y+$scrolled_y, self
		@options = Gear_Button.new 55, @y+$scrolled_y, Proc.new{ Popup_Instrument_Options.new self }
		@scale = $all_scales[0]
		@type = $all_shawzin_types[0]
		@line_1 = Line.new x1: 50, y1: @y+80+$scrolled_y, x2: $width-50, y2: @y+80+$scrolled_y, width: 4, color: $colors["string"]
		@line_2 = Line.new x1: 50, y1: @y+160+$scrolled_y, x2: $width-50, y2: @y+160+$scrolled_y, width: 4, color: $colors["string"]
		@line_3 = Line.new x1: 50, y1: @y+240+$scrolled_y, x2: $width-50, y2: @y+240+$scrolled_y, width: 4, color: $colors["string"]
		@notes = []
		@mouse_downed = false # saves if the mouse went down over this object
		$all_buttons.push self # to handle @mouse_downed
		$scroll_list_x.push self
		$scroll_list_y.push self
		$containers.push self
	end
	def click event
		if !$playing
			if event.y-$scrolled_y > @y+20 and @mouse_downed
				if @notes.length == 1666
					Popup_Info.new "Due to Warframe's restrictions on shawzin songs, you can't put more than 1666 notes."
					return
				end
				@notes.each do |n|
					if n.drawn.contains? event.x, event.y
						return
					end
				end
				if event.y-$scrolled_y <= @y+120 # if below halfway between string 1 and string 2
					@notes.push Shawzin_Note.new 1, @y, event.x+$scrolled_x
				elsif event.y-$scrolled_y <= @y+200 # if below halfway between string 2 and string 3
					@notes.push Shawzin_Note.new 2, @y, event.x+$scrolled_x
				else
					@notes.push Shawzin_Note.new 3, @y, event.x+$scrolled_x
				end
				if $containers[0].editing
					$containers[0].editing_buttons[4].action.call
				end
				change
			else
				@delete_button.click event
				@options.click event
			end
		end
	end
	def mouse_down event
		if event.y-$scrolled_y > @y+20
			@mouse_downed = true
		end
		@delete_button.mouse_down event
		@options.mouse_down event
	end
	def mouse_up
		@mouse_downed = false
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
	def play x, change
		@notes.select{|n| (x...change).include? n.x }.each do |n|
			n.play @scale, @type
		end
	end
	def remove
		change
		@notes.each do |n|
			n.remove
		end
		@delete_button.remove
		@options.remove
		@name.remove
		@line_1.remove
		@line_2.remove
		@line_3.remove
		@container.remove
		$scroll_list_x.delete_at $scroll_list_x.find_index self
		$scroll_list_y.delete_at $scroll_list_y.find_index self
		$containers.delete_at $containers.find_index self
		reposition_all
	end
	def reposition
		@y = $containers[$containers.find_index(self)-1].y+$containers[$containers.find_index(self)-1].container.height+5
		scroll_y
	end
	def export # all data information is based off of https://warframe.fandom.com/wiki/Shawzin#Song_Transcription
		str = (($all_scales.find_index @scale)+1).to_s
		note_chars = "BCDEFGHJKLMNOPRSTUVWXhijklmnZabcdefpqrstuvxyz012356789+/"
		time_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
		fret_to_num = {[false, false, false]=>"0", [true, false, false]=>"7", [false, true, false]=>"14", [false, false, true]=>"21", [true, true, false]=>"28", [true, false, true]=>"35", [false, true, true]=>"42", [true, true, true]=>"49"}
		@notes = @notes.sort_by { |n| n.x }
		@notes.each do |n|
			num = n.string-1
			if num == 3
				num = 4 # slight change to adjust for how notes are stored
			end
			str += note_chars[num+fret_to_num[n.options].to_i] # first character is note, num is increased by multiples of 7 according to what fret the note is
			str += time_chars[(n.x-50)/670] # second character is measure (1/64 of song)
			str += time_chars[(((n.x-50)%670)/21)*2]
		end
		str
	end
	def import data
		note_chars = "BCDEFGHJKLMNOPRSTUVWXhijklmnZabcdefpqrstuvxyz012356789+/"
		time_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
		num_to_fret = {"0"=>[false, false, false], "1"=>[true, false, false], "2"=>[false, true, false], "3"=>[false, false, true], "4"=>[true, true, false], "5"=>[true, false, true], "6"=>[false, true, true], "7"=>[true, true, true]}
		# set the scale and update the dropdown
		@scale = $all_scales[data[0].to_i-1]
		data.slice! 0
		# loop through data in sets of three to create notes
		curr_string = 1 # stores string for notes currently being created
		curr_frets = [false, false, false] # stores frets for note currently being created
		curr_x = 0 # stores x position for note currently being created
		data = data.split ""
		data.length.times do |i|
			d = data[i]
			case i%3
			when 0
				curr_string = (note_chars.index(d)%7)+1
				if curr_string == 4
					curr_string = 3 # slight change to adjust for how notes are stored
				end
				curr_frets = num_to_fret[(note_chars.index(d)/7).to_s]
			when 1
				curr_x = time_chars.index(d)*670+50
			when 2
				curr_x += ((time_chars.index(d)/2)*21)
				@notes.push Shawzin_Note.new curr_string, @y, curr_x
				@notes[-1].options = curr_frets
				@notes[-1].draw
			end
		end
		@notes.filter{ |n| n.x-20 < $scrolled_x && n.x+20 > $scrolled_x+$width }.each do |n|
			n.remove
		end
	end
	def scroll_x
		@notes.each do |n|
			n.remove
		end
		@notes.filter{ |n| n.x-20 > $scrolled_x && n.x+20 < $scrolled_x+$width }.each do |n|
			n.draw
		end
	end
	def scroll_y
		@notes.each do |n|
			n.remove
		end
		@delete_button.hide
		@options.hide
		@name.remove
		@line_1.remove
		@line_2.remove
		@line_3.remove
		@container.remove
		if @y+@height > $scrolled_y and @y < $height-$scrolled_y
			@container = Rectangle.new x: 50, y: @y+$scrolled_y, width: $width-100, height: @height, color: [0, 0, 0, 0]
			@name = Text.new "Shawzin", x: 80, y: @y+$scrolled_y, size: 17, color: $colors["string"]
			@delete_button.y = @y+$scrolled_y
			@delete_button.draw
			@options.y = @y+$scrolled_y
			@options.draw
			@line_1 = Line.new x1: 50, y1: @y+80+$scrolled_y, x2: $width-50, y2: @y+80+$scrolled_y, width: 4, color: $colors["string"]
			@line_2 = Line.new x1: 50, y1: @y+160+$scrolled_y, x2: $width-50, y2: @y+160+$scrolled_y, width: 4, color: $colors["string"]
			@line_3 = Line.new x1: 50, y1: @y+240+$scrolled_y, x2: $width-50, y2: @y+240+$scrolled_y, width: 4, color: $colors["string"]
			@notes.each do |n|
				n.draw
			end
		end
	end
end

class Shawzin_Note
	attr_accessor :x, :container_y, :string, :options, :drawn, :color
	def initialize string, container_y, x
		@options = [false, false, false]
		if $keys_down.include? $options["sky_fret_key"]
			@options[0] = true
		end
		if $keys_down.include? $options["earth_fret_key"]
			@options[1] = true
		end
		if $keys_down.include? $options["water_fret_key"]
			@options[2] = true
		end
		@string = string
		@container_y = container_y
		@x = (x-50).round_to(21)+50
		@first_draw = true
		@color = $colors["note"]
		draw
	end
	def play scale, type # get url for the sound to play
		url = "resources/sounds/shawzin/#{type.downcase}/#{scale.downcase}/#{@string}"
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
		if !@first_draw
			@drawn.remove
			@drawn_sky.remove
			@drawn_earth.remove
			@drawn_water.remove
		else
			@first_draw = false
		end
		@drawn = Circle.new x: @x-$scrolled_x, y: @string*80+@container_y+$scrolled_y, radius: 20, color: @color
		if !@options[0] # draw either circle to show false
			@drawn_sky = Circle.new x: @drawn.x-20, y: @drawn.y-35, radius: 4, color: @color
		else # or mouse button to show true
			@drawn_sky = Image.new "resources/images/instruments/left_arrow_button.png", x: @drawn.x-38, y: @drawn.y-47, width: 24, height: 24, color: @color
		end
		if !@options[1]
			@drawn_earth = Circle.new x: @drawn.x, y: @drawn.y-35, radius: 4, color: @color
		else
			@drawn_earth = Image.new "resources/images/instruments/down_arrow_button.png", x: @drawn.x-12, y: @drawn.y-47, width: 24, height: 24, color: @color
		end
		if !@options[2]
			@drawn_water = Circle.new x: @drawn.x+20, y: @drawn.y-35, radius: 4, color: @color
		else
			@drawn_water = Image.new "resources/images/instruments/right_arrow_button.png", x: @drawn.x+15, y: @drawn.y-47, width: 24, height: 24, color: @color
		end
	end
	def remove
		@drawn.remove
		@drawn_sky.remove
		@drawn_earth.remove
		@drawn_water.remove
	end
end