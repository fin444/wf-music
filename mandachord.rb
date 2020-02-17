$all_mandachord_instruments = ["Adau", "Alpha", "Beta", "Delta", "Gamma", "Epsilon", "Horos", "Druk", "Plogg"]

class Mandachord_UI
	attr_accessor :instrument_percussion, :instrument_bass, :instrument_melody, :y, :container, :looped, :notes
	def initialize
		@height = 315
		@y = $containers[-1].y+$containers[-1].container.height+5
		@looped = true
		@container = Rectangle.new x: 50, y: @y+$scrolled_y, width: $width-100, height: @height, color: [0, 0, 0, 0]
		@name = Text.new "Mandachord", x: 80, y: @y+$scrolled_y, size: 17, color: $colors["string"]
		@delete_button = Delete_Button.new $width-70, @y+$scrolled_y, self
		@options = Gear_Button.new 55, @y+$scrolled_y, Proc.new{ Popup_Instrument_Options.new self }
		@instrument_percussion = $all_mandachord_instruments[0]
		@instrument_bass = $all_mandachord_instruments[0]
		@instrument_melody = $all_mandachord_instruments[0]
		@notes = []
		@image = Image.new "resources/images/instruments/mandachord_background.png", x: 49, y: @y+30+$scrolled_y, width: $width-94, height: 278, z: 4
		@line_1 = Line.new x1: 50+(336-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(336-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		@line_2 = Line.new x1: 50+(672-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(672-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		@line_3 = Line.new x1: 50+(1008-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(1008-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		@line_4 = Line.new x1: 50+(1343-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(1343-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		if @line_1.x1 == 1393 or @line_2.x1 == 1393 or @line_3.x1 == 1393 or @line_4.x1 == 1393
			@line_5 = Line.new x1: 50, y1: @y+30+$scrolled_y, x2: 50, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		end
		@mouse_downed = false # saves if the mouse went down over this object
		$all_buttons.push self # to handle @mouse_downed
		$scroll_list_x.push self
		$scroll_list_y.push self
		$containers.push self
	end
	def click event
		if !$playing and @container.contains? event.x, event.y
			@delete_button.click event
			@options.click event
			@notes.each do |n|
				if n.notes.contains? event.x, event.y
					n.notes.remove
					@notes.delete_at @notes.find_index n
					return
				end
			end
			if event.x >= 49 and event.x <= $width-46 and event.y >= @y+$scrolled_y+30 and event.y <= @y+$scrolled_y+308 and @mouse_downed
				y = event.y-2
				if y < @y+30
					y = @y+30 # prevents putting notes too far down
				end
				if y > @y+302
					y = @y+302 # prevents putting notes too far up
				end
				if y-$scrolled_y < @y+93
					type = "percussion"
					num = (event.y-$scrolled_y-9-@y)/21 # identifier for which sound to play
					adjust_y = 0 # because there are thicker barriers between types
				elsif y-$scrolled_y < @y+198
					type = "bass"
					num = (y-$scrolled_y-73-@y)/21
					adjust_y = 2
				else
					type = "melody"
					num = (y-$scrolled_y-179-@y)/21
					adjust_y = 3
				end
				if @notes.filter{ |n| n.type == type and (n.x)/336 == (((event.x-49).floor_to(21)+7+$scrolled_x)/336)%4 }.length == 16
					Popup_Info.new "Warframe limits mandachord songs to 16 notes per type per quadrant."
					return
				end
				@notes.push Mandachord_Note.new type, (event.x-49).floor_to(21)+7+$scrolled_x, (y-@y-$scrolled_y-30).floor_to(21)+@y+30+adjust_y, num, self
				change
			end
		end
	end
	def mouse_down event
		if event.x >= 49 and event.x <= $width-46 and event.y >= @y+$scrolled_y+30 and event.y <= @y+$scrolled_y+308
			@mouse_downed = true
		end
		@delete_button.mouse_down event
		@options.mouse_down event
	end
	def mouse_up
		@mouse_downed = false
	end
	def get_last_sound
		h = 0
		@notes.each do |n|
			if n.x+42 > h
				h = n.x+42
			end
		end
		h
	end
	def play x, change
		(change-x).times do |n|
			if (x+n-49)%21 == 0
				if @looped
					arr = @notes.select{ |i| i.x-7 == (x+n-49)%1344 }
				else
					arr = @notes.select{ |i| i.x-7 == x+n-49 }
				end
				arr.each do |i|
					case i.type
					when "percussion"
						i.play @instrument_percussion
					when "bass"
						i.play @instrument_bass
					when "melody"
						i.play @instrument_melody
					end
				end
			end
		end
	end
	def remove
		change
		@notes.each do |n|
			n.notes.remove
		end
		@name.remove
		@delete_button.remove
		@options.remove
		@container.remove
		@image.remove
		@line_1.remove
		@line_2.remove
		@line_3.remove
		@line_4.remove
		@line_5.remove
		$scroll_list_x.delete_at $scroll_list_x.find_index self
		$scroll_list_y.delete_at $scroll_list_y.find_index self
		$containers.delete_at $containers.find_index self
		reposition_all
	end
	def reposition
		@y = $containers[$containers.find_index(self)-1].y+$containers[$containers.find_index(self)-1].container.height+5
		scroll_y
	end
	def export
		str = "#{{"true"=>0, "false"=>1}[@looped.to_s]}#{$all_mandachord_instruments.find_index(@instrument_percussion).to_s}#{$all_mandachord_instruments.find_index(@instrument_bass).to_s}#{$all_mandachord_instruments.find_index(@instrument_melody).to_s}"
		@notes = @notes.sort_by{ |n| n.x }
		@notes.each do |n|
			str += "#{n.number}#{n.type[0]}#{add_zeros (n.x+14)/21, 4}"
		end
		str
	end
	def import data
		letter_to_instrument = {"p"=>"percussion", "b"=>"bass", "m"=>"melody"}
		# set the instrument and update dropdown
		self.looped = [true, false][data[0].to_i]
		@instrument_percussion = $all_mandachord_instruments[data[1].to_i]
		@instrument_bass = $all_mandachord_instruments[data[2].to_i]
		@instrument_melody = $all_mandachord_instruments[data[3].to_i]
		data.slice! 0..3
		# loop through data in sets of 4
		curr_num = 0 # stores number for note being currently created
		curr_type = "percussion" # stores type for note being currently created
		curr_x = 0  # stores x for note being currently created
		data = data.split ""
		data.length.times do |i|
			if i%6 == 0
				curr_y = data[i].to_i
				curr_type = letter_to_instrument[data[i+1]]
				if curr_type == "bass"
					curr_y += 3
				elsif curr_type == "melody"
					curr_y += 8
				end
				adjust_y = 0
				if curr_type == "bass"
					adjust_y = 1
				elsif curr_type == "melody"
					adjust_y = 2
				end
				@notes.push Mandachord_Note.new curr_type, data[i+2, 4].join("").to_i*21-14, curr_y*21+10+adjust_y+@y, data[i], self
			end
		end
	end
	def scroll_x
		@notes.each do |n|
			n.draw
		end
		@line_1.remove
		@line_2.remove
		@line_3.remove
		@line_4.remove
		if !@line_5.nil?
			@line_5.remove
		end
		@line_1 = Line.new x1: 50+(335-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(335-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		@line_2 = Line.new x1: 50+(671-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(671-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		@line_3 = Line.new x1: 50+(1007-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(1007-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		@line_4 = Line.new x1: 50+(1343-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(1343-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		if @line_1.x1 == 1393 or @line_2.x1 == 1393 or @line_3.x1 == 1393 or @line_4.x1 == 1393
			@line_5 = Line.new x1: 50, y1: @y+30+$scrolled_y, x2: 50, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		end
	end
	def scroll_y
		@notes.each do |n|
			n.notes.remove
		end
		@name.remove
		@delete_button.hide
		@options.hide
		@container.remove
		@image.remove
		@line_1.remove
		@line_2.remove
		@line_3.remove
		@line_4.remove
		if !@line_5.nil?
			@line_5.remove
		end
		if @y+@height > $scrolled_y && @y < $height-$scrolled_y
			@container = Rectangle.new x: 50, y: @y+$scrolled_y, width: $width-100, height: @height, color: $colors["background"]
			@name = Text.new "Mandachord", x: 80, y: @y+$scrolled_y, size: 17, color: $colors["string"]
			@delete_button.y = @y+$scrolled_y
			@delete_button.draw
			@options.y = @y+$scrolled_y
			@options.draw
			@image = Image.new "resources/images/instruments/mandachord_background.png", x: 49, y: @y+30+$scrolled_y, width: $width-94, height: 278, z: 4
			@line_1 = Line.new x1: 50+(335-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(335-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
			@line_2 = Line.new x1: 50+(671-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(671-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
			@line_3 = Line.new x1: 50+(1007-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(1007-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
			@line_4 = Line.new x1: 50+(1343-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(1343-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
			if @line_1.x1 == 1393 or @line_2.x1 == 1393 or @line_3.x1 == 1393 or @line_4.x1 == 1393
				@line_5 = Line.new x1: 50, y1: @y+30+$scrolled_y, x2: 50, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
			end
			@notes.each do |n|
				n.draw
			end
		end
	end
	def looped= l
		@looped = l
		if l
			@notes.filter{ |d| d.x > 1330 }.each do |d|
				d.notes.remove
			end
			@notes = @notes.filter{ |d| d.x <= 1330 }
		else
			@notes.each do |d|
				d.x = d.x%1344
			end
		end
		scroll_x
	end
end

class Mandachord_Note
	attr_accessor :drawn, :selected, :x, :number, :type
	def initialize type, x, y, number, container
		@type = type
		@x = x
		@y = y
		@number = number
		@container = container
		draw
	end
	def play instrument
		url = "resources/sounds/mandachord/#{instrument.downcase}/#{@number}#{@type}.mp3"
		puts "[#{Time.now.strftime("%I:%M:%S")}] #{url}"
		# @sound = Sound.new(url) # causes bugs if not stored as variable
		# @sound.play
	end
	def draw
		# remove
		@drawn.remove
		# draw
		if @container.looped
			@drawn = Rectangle.new x: 43+(@x-$scrolled_x)%1344, y: @y+1+$scrolled_y, width: 21, height: 21, color: $colors[@type.downcase], z: 4
		elsif 64+@x-$scrolled_x >= 49 and @x-$scrolled_x <= 1344
			@drawn = Rectangle.new x: 43+@x-$scrolled_x, y: @y+1+$scrolled_y, width: 21, height: 21, color: $colors[@type.downcase], z: 4
		end
	end
	def determine_y container_y
		case @type
		when "percussion"
			@y = container_y+@number*21+10
		when "bass"
			@y = container_y+@number*21+74
		when "melody"
			@y = container_y+@number*21+180
		end
	end
end