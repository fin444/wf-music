$all_mandachord_instruments = ["Adau", "Alpha", "Beta", "Delta", "Gamma", "Epsilon", "Horos", "Druk", "Plogg"]

class Mandachord_UI < UI_Element
	def init
		@instrument = $all_mandachord_instruments[0]
		@drawn = []
		@image = Image.new "resources/images/mandachord_background.png", x: 49, y: @y+30+$scrolled_y, width: $width-94, height: 278, z: 4
		@line_1 = Line.new x1: 50+(336-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(336-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		@line_2 = Line.new x1: 50+(672-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(672-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		@line_3 = Line.new x1: 50+(1008-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(1008-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		@line_4 = Line.new x1: 50+(1343-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(1343-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		if @line_1.x1 == 1393 or @line_2.x1 == 1393 or @line_3.x1 == 1393 or @line_4.x1 == 1393
			@line_5 = Line.new x1: 50, y1: @y+30+$scrolled_y, x2: 50, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		end
		@select_instrument = Dropdown.new (60+get_text_width("Mandachord", 17)), @y+$scrolled_y, $all_mandachord_instruments, @instrument, Proc.new{ |s| @instrument = s }
		@select_instrument.z = 4
		@select_instrument.draw
		$scroll_list_x.push self
		$scroll_list_y.push self
	end
	def click event
		if !$playing
			@select_instrument.click event
			@delete_button.click event
			@drawn.each do |n|
				if n.drawn.contains? event.x, event.y
					n.drawn.remove
					@drawn.delete_at @drawn.find_index n
					return
				end
			end
			if event.x >= 49 and event.x <= $width-46 and event.y >= @y+$scrolled_y+30 and event.y <= @y+$scrolled_y+308
				if event.y-$scrolled_y < @y+94
					type = "percussion"
					adjust_y = 0 # because there are 2 pixel thick barriers between types
				elsif event.y-$scrolled_y < @y+200
					type = "bass"
					adjust_y = 1
				else
					type = "melody"
					adjust_y = 2
				end
				@drawn.push Mandachord_Note.new type, (((event.x-49-$scrolled_x)/21.0).floor-2)*21+49, ((event.y-@y-$scrolled_y-30)/21.0).floor*21+@y+30+adjust_y
			end
		end
	end
	def mouse_down event
		@delete_button.mouse_down event
	end
	def get_last_sound
		h = 0
		@drawn.each do |n|
			if n.x-$scrolled_x > h
				h = n.x-$scrolled_x
			end
		end
		h
	end
	def play x
		if (x-49)%21 == 0
			@drawn.select{ |n| n.x == x%1344 }.each do |n|
				n.play @instrument
			end
		end
	end
	def remove
		change
		@drawn.each do |n|
			n.drawn.remove
		end
		@name.remove
		@select_instrument.remove
		@delete_button.remove
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
	def reposition_unique
		@select_instrument.remove
		@select_instrument = Dropdown.new (60+get_text_width("Mandachord", 17)), @y, $all_mandachord_instruments, @instrument, Proc.new{ |s| @instrument = s }
		@image.remove
		@line_1.remove
		@line_2.remove
		@line_3.remove
		@line_4.remove
		@line_5.remove
		@image = Image.new "resources/images/mandachord_background.png", x: 49, y: @y+30+$scrolled_y, width: $width-94, height: 278, z: 4
		@line_1 = Line.new x1: 50+(335-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(335-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		@line_2 = Line.new x1: 50+(671-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(671-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		@line_3 = Line.new x1: 50+(1007-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(1007-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		@line_4 = Line.new x1: 50+(1343-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(1343-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		if @line_1.x1 == 1393 or @line_2.x1 == 1393 or @line_3.x1 == 1393 or @line_4.x1 == 1393
			@line_5 = Line.new x1: 50, y1: @y+30+$scrolled_y, x2: 50, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		end
		@drawn.each do |n|
			n.determine_y @y
			n.draw
		end
	end
	def export
		str = $all_mandachord_instruments.find_index(@instrument).to_s
		@drawn = @drawn.sort_by{ |n| n.x }
		@drawn.each do |n|
			str += "#{n.number}#{n.type[0]}#{add_zeros (n.x-50)/21, 2}"
		end
		str
	end
	def import data
		letter_to_instrument = {"p"=>"percussion", "b"=>"bass", "m"=>"melody"}
		# set the instrument and update dropdown
		@instrument = $all_mandachord_instruments[data[0].to_i]
		@select_instrument.selected = @instrument
		@select_instrument.draw
		data.slice! 0
		# loop through data in sets of 4
		curr_num = 0 # stores number for note being currently created
		curr_type = "percussion" # stores type for note being currently created
		curr_x = 0  # stores x for note being currently created
		data = data.split ""
		data.length.times do |i|
			d = data[i]
			case i%4
			when 0
				curr_num = d.to_i
			when 1
				curr_type = letter_to_instrument[d]
				if curr_type == "bass"
					curr_num += 3
				elsif curr_type == "melody"
					curr_num += 8
				end
			when 2
				curr_x = d.to_i*10
			when 3
				@drawn[curr_x+d.to_i][curr_num-1].selected = true
				@drawn[curr_x+d.to_i][curr_num-1].draw
				@drawn.push @drawn[curr_x+d.to_i][curr_num-1]
			end
		end
	end
	def scroll_x
		@drawn.each do |n|
			n.draw
		end
		@line_1.remove
		@line_2.remove
		@line_3.remove
		@line_4.remove
		@line_5.remove
		@line_1 = Line.new x1: 50+(335-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(335-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		@line_2 = Line.new x1: 50+(671-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(671-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		@line_3 = Line.new x1: 50+(1007-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(1007-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		@line_4 = Line.new x1: 50+(1343-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(1343-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		if @line_1.x1 == 1393 or @line_2.x1 == 1393 or @line_3.x1 == 1393 or @line_4.x1 == 1393
			@line_5 = Line.new x1: 50, y1: @y+30+$scrolled_y, x2: 50, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
		end
	end
	def scroll_y
		@drawn.each do |n|
			n.drawn.remove
		end
		@name.remove
		@select_instrument.remove
		@delete_button.hide
		@container.remove
		@image.remove
		@line_1.remove
		@line_2.remove
		@line_3.remove
		@line_4.remove
		@line_5.remove
		if @y+@height > $scrolled_y && @y < $height-$scrolled_y
			@select_instrument.y = @y+$scrolled_y
			@select_instrument.draw
			@container = Rectangle.new x: 50, y: @y+$scrolled_y, width: $width-100, height: @height, color: $colors["background"]
			@name = Text.new @text, x: 55, y: @y+$scrolled_y, size: 17, color: $colors["string"]
			@delete_button.y = @y+$scrolled_y
			@delete_button.draw
			@image = Image.new "resources/images/mandachord_background.png", x: 49, y: @y+30+$scrolled_y, width: $width-94, height: 278, z: 4
			@line_1 = Line.new x1: 50+(335-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(335-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
			@line_2 = Line.new x1: 50+(671-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(671-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
			@line_3 = Line.new x1: 50+(1007-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(1007-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
			@line_4 = Line.new x1: 50+(1343-$scrolled_x)%1344, y1: @y+30+$scrolled_y, x2: 50+(1343-$scrolled_x)%1344, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
			if @line_1.x1 == 1393 or @line_2.x1 == 1393 or @line_3.x1 == 1393 or @line_4.x1 == 1393
				@line_5 = Line.new x1: 50, y1: @y+30+$scrolled_y, x2: 50, y2: @y+307+$scrolled_y, width: 2, color: "white", z: 5
			end
			@drawn.each do |n|
				n.draw
			end
		end
	end
end

class Mandachord_Note
	attr_accessor :drawn, :selected, :x, :number, :type
	def initialize type, x, y
		@type = type
		@x = x
		@y = y
		@first_draw = true
		draw
	end
	def play instrument
		puts "[#{Time.now.strftime("%I:%M:%S")}] resources/sounds/mandachord/#{instrument.downcase}/#{@number}#{@type}"
	end
	def draw
		if !@first_draw # removes all current, but if they don't exist yet then it doesn't
			@drawn.remove
		end
		@first_draw = false
		@drawn = Rectangle.new x: 43+(@x-$scrolled_x)%1344, y: @y+1+$scrolled_y, width: 21, height: 21, color: $colors[@type.downcase], z: 4
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