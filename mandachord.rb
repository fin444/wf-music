$all_mandachord_instruments = ["Adau", "Alpha", "Beta", "Delta", "Gamma", "Epsilon", "Horos", "Druk", "Plogg"]

class Mandachord_UI < UI_Element
	def init
		@instrument = $all_mandachord_instruments[0]
		@drawn = Array.new
		@notes = Array.new
		@percussion_background = Rectangle.new x: 49, y: @y+30, width: $width-94, height: 66, color: $colors["percussion"], z: 4
		@bass_background = Rectangle.new x: 49, y: @y+95, width: $width-94, height: 106, color: $colors["bass"], z: 4
		@melody_background = Rectangle.new x: 49, y: @y+201, width: $width-94, height: 106, color: $colors["melody"], z: 4
		@line_1 = Line.new x1: 50+(336+$scrolled_x)%1344, y1: @y+30, x2: 50+(336+$scrolled_x)%1344, y2: @y+307, width: 2, color: "white", z: 4
		@line_2 = Line.new x1: 50+(672+$scrolled_x)%1344, y1: @y+30, x2: 50+(672+$scrolled_x)%1344, y2: @y+307, width: 2, color: "white", z: 4
		@line_3 = Line.new x1: 50+(1008+$scrolled_x)%1344, y1: @y+30, x2: 50+(1008+$scrolled_x)%1344, y2: @y+307, width: 2, color: "white", z: 4
		@line_4 = Line.new x1: 50+(1343+$scrolled_x)%1344, y1: @y+30, x2: 50+(1343+$scrolled_x)%1344, y2: @y+307, width: 2, color: "white", z: 4
		if @line_1.x1 == 1393 or @line_2.x1 == 1393 or @line_3.x1 == 1393 or @line_4.x1 == 1393
			@line_5 = Line.new x1: 50, y1: @y+30, x2: 50, y2: @y+307, width: 2, color: "white", z: 4
		end
		64.times do |a|
			arr = Array.new
			3.times do |n|
				arr.push Mandachord_Note.new "percussion", 50+a*21, @y, n+1
			end
			5.times do |n|
				arr.push Mandachord_Note.new "bass", 50+a*21, @y, n+1
			end
			5.times do |n|
				arr.push Mandachord_Note.new "melody", 50+a*21, @y, n+1
			end
			@drawn.push arr
		end
		@select_instrument = Dropdown.new (60+get_text_width("Mandachord", 17)), @y, $all_mandachord_instruments, @instrument, Proc.new{ |s| @instrument = s }
		$scroll_list_x.push self
	end
	def click event
		if !$playing
			@select_instrument.click event
			@delete_button.click event
			@drawn.each do |a| # loops through every column
				a.each do |n| # loops through everything in column
					if event.x >= n.drawn.x-1 and event.x <= n.drawn.x+20 and event.y >= n.drawn.y-1 and event.y <= n.drawn.y+20
						n.selected = !n.selected
						if @notes.include? n
							@notes = @notes - [n]
						else
							@notes.push n
						end
						n.draw
						$saved = false
						return
					end
				end
			end
		end
	end
	def mouse_down event
		@delete_button.mouse_down event
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
		if (x-50)%21 == 0
			@notes.select{|n| n.x == x }.each do |n|
				n.play @instrument
			end
		end
	end
	def remove
		$saved = false
		@drawn.each do |a| # loops through every column
			a.each do |n| # loops through everything in column
				n.drawn.remove
			end
		end
		@name.remove
		@select_instrument.remove
		@delete_button.remove
		@container.remove
		@percussion_background.remove
		@bass_background.remove
		@melody_background.remove
		$containers.delete_at $containers.find_index self
		reposition_all
	end
	def reposition_unique
		@select_instrument.remove
		@select_instrument = Dropdown.new (60+get_text_width("Mandachord", 17)), @y, $all_mandachord_instruments, @instrument, Proc.new{ |s| @instrument = s }
		@percussion_background.remove
		@bass_background.remove
		@melody_background.remove
		@percussion_background = Rectangle.new x: 49, y: @y+30, width: $width-94, height: 65, color: $colors["percussion"]
		@bass_background = Rectangle.new x: 49, y: @y+94, width: $width-94, height: 105, color: $colors["bass"]
		@melody_background = Rectangle.new x: 49, y: @y+199, width: $width-94, height: 105, color: $colors["melody"]
		@drawn.each do |a|
			a.each do |n|
				n.determine_y @y
				n.draw
			end
		end
	end
	def export
		str = $all_mandachord_instruments.find_index(@instrument).to_s
		@notes = @notes.sort_by{ |n| n.x }
		@notes.each do |n|
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
				@notes.push @drawn[curr_x+d.to_i][curr_num-1]
			end
		end
	end
	def scroll_x
		@drawn.each do |d|
			d.each do |n|
				n.draw
			end
		end
		@line_1.remove
		@line_2.remove
		@line_3.remove
		@line_4.remove
		@line_5.remove
		@line_1 = Line.new x1: 50+(335+$scrolled_x)%1344, y1: @y+30, x2: 50+(335+$scrolled_x)%1344, y2: @y+307, width: 2, color: "white", z: 4
		@line_2 = Line.new x1: 50+(671+$scrolled_x)%1344, y1: @y+30, x2: 50+(671+$scrolled_x)%1344, y2: @y+307, width: 2, color: "white", z: 4
		@line_3 = Line.new x1: 50+(1007+$scrolled_x)%1344, y1: @y+30, x2: 50+(1007+$scrolled_x)%1344, y2: @y+307, width: 2, color: "white", z: 4
		@line_4 = Line.new x1: 50+(1343+$scrolled_x)%1344, y1: @y+30, x2: 50+(1343+$scrolled_x)%1344, y2: @y+307, width: 2, color: "white", z: 4
		if @line_1.x1 == 1393 or @line_2.x1 == 1393 or @line_3.x1 == 1393 or @line_4.x1 == 1393
			@line_5 = Line.new x1: 50, y1: @y+30, x2: 50, y2: @y+307, width: 2, color: "white", z: 4
		end
	end
end

class Mandachord_Note
	attr_accessor :drawn, :selected, :x, :number, :type
	def initialize type, x, container_y, number
		@type = type
		@x = x
		@number = number
		@selected = false
		@first_draw = true
		determine_y container_y
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
		@drawn = Rectangle.new x: 43+(@x+$scrolled_x)%1344, y: @y+1, width: 19, height: 19, color: determine_color, z: 4
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
	def determine_color
		if @selected
			return $colors[@type.downcase]
		end
		$colors["background"]
	end
end