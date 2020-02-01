$all_animals = ["Pobbers", "Virmink", "Sawgaw", "Bolarola", "Horrasque", "Stover", "Kubrodon", "Kuaka", "Condroc", "Mergoo", "Vasca"]

class Lure_UI
	attr_accessor :animal, :y, :container
	def initialize
		@height = 220
		@y = $containers[-1].y+$containers[-1].container.height+5
		@container = Rectangle.new x: 50, y: @y+$scrolled_y, width: $width-100, height: @height, color: [0, 0, 0, 0]
		@name = Text.new "Echo Lure", x: 80, y: @y+$scrolled_y, size: 17, color: $colors["string"]
		@delete_button = Delete_Button.new $width-70, @y+$scrolled_y, self
		@options = Gear_Button.new 55, @y+$scrolled_y, Proc.new{ Popup_Instrument_Options.new self }
		@animal = $all_animals[0]
		@lines = []
		@noises = []
		13.times do |n|
			if n == 3 || n == 9
				@lines.push Line.new x1: 50, y1: @y+30+n*15+$scrolled_y, x2: $width-50, y2: @y+30+n*15+$scrolled_y, width: 2, color: $colors["note"]
				@lines[n].opacity = 0.4
			else
				@lines.push Line.new x1: 50, y1: @y+30+n*15+$scrolled_y, x2: $width-50, y2: @y+30+n*15+$scrolled_y, width: 1, color: $colors["note"]
				@lines[n].opacity = 0.3
			end
		end
		$scroll_list_x.push self
		$scroll_list_y.push self
		$containers.push self
	end
	def click event
		if !$playing
			@delete_button.click event
			@options.click event
		end
	end
	def right_click event
		if !$playing
			@noises.each do |n|
				if n.drawn.contains? event.x, event.y
					n.remove
					@noises.delete_at @noises.find_index n
				end
			end
		end
	end
	def mouse_down event
		if !$playing
			new_noise event
			@delete_button.mouse_down event
			@options.mouse_down event
		end
	end
	def mouse_move event
		if !$playing
			new_noise event
		end
	end
	def new_noise event
		if event.y-$scrolled_y > @y+30 && event.y-$scrolled_y < @y+220 && event.x > 50 && event.x < $width-50
			if @noises.any?{ |n| n.x == (((event.x-50)/21).floor)*21+50 }
				@noises.filter{ |n| n.x == (((event.x-50)/21).floor)*21+50 }.each do |n|
					n.y = (event.y-$scrolled_y-@y).round_to(15)+@y-5
					n.draw
				end
			else
				@noises.push Lure_Noise.new event.x+$scrolled_x, event.y-$scrolled_y, @y
			end
			change
		end
	end
	def get_last_sound
		connect_noises
		h = 0
		@noises.each do |n|
			if n.x+10 > h
				h = n.x+10
			end
		end
		h
	end
	def play x, change
		@noises.filter{ |n| n.x.between? x, change }.each do |n|
			n.play @animal
		end
	end
	def remove
		@delete_button.remove
		@options.remove
		@name.remove
		@lines.each do |l|
			l.remove
		end
		@noises.each do |n|
			n.remove
		end
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
		str = add_zeros($all_animals.find_index(@animal), 2).to_s
		@noises.each do |n|
			t = "#{add_zeros (n.x-50)/21, 3}#{add_zeros (n.y-@y-25)/15, 2}"
			str += t
		end
		str
	end
	def import data
		# set the animal and update dropdown
		@animal = $all_animals[data[0, 2].to_i]
		data.slice! 0..1
		# loop through data in sets of 5
		data = data.split ""
		data.length.times do |i|
			if i%5 == 0 and !data[i+4].nil?
				@noises.push Lure_Noise.new data[i, 3].join("").to_i*21+50, data[i+3, 2].join("").to_i*15+@y+30, @y
			end
		end
		@noises.filter{ |n| n.x < $scrolled_x && n.x > $width+$scrolled_x }.each do |n|
			n.remove
		end
	end
	def connect_noises
		@noises.sort_by! { |n| n.x }
		@connected_noises = []
		curr_start = 0 # have to define in higher scope
		curr_length = 1 # have to define in higher scope
		@noises.each do |n|
			if @noises[0] == n
				curr_start = ((n.x-50)/21)
			elsif curr_start*21+curr_length*21 == n.x-50
				curr_length += 1
			else
				@connected_noises.push [curr_start, curr_length]
				curr_start = ((n.x-50)/21) # also sets up for next connection
				curr_length = 1
			end
		end
		if curr_start != -1
			@connected_noises.push [curr_start, curr_length]
		end
		@connected_noises.each do |n|
			# puts "#{n[0]}, #{n[1]}"
		end
	end
	def scroll_x
		@noises.each do |n|
			n.remove
		end
		@noises.filter{ |n| n.x > $scrolled_x && n.x < $width+$scrolled_x }.each do |n|
			n.draw
		end
	end
	def scroll_y
		@container.remove
		@delete_button.hide
		@options.hide
		@name.remove
		@lines.each do |l|
			l.remove
		end
		@noises.each do |n|
			n.remove
		end
		if @y+@height > $scrolled_y and @y < $height-$scrolled_y
			@container = Rectangle.new x: 50, y: @y+$scrolled_y, width: $width-100, height: @height, color: [0, 0, 0, 0]
			@name = Text.new "Echo Lure", x: 80, y: @y+$scrolled_y, size: 17, color: $colors["string"]
			@delete_button.y = @y+$scrolled_y
			@delete_button.draw
			@options.y = @y+$scrolled_y
			@options.draw
			# redraw lines
			@lines = []
			13.times do |n|
				if n == 3 || n == 9
					@lines.push Line.new x1: 50, y1: @y+30+n*15+$scrolled_y, x2: $width-50, y2: @y+30+n*15+$scrolled_y, width: 2, color: $colors["note"]
					@lines[n].opacity = 0.4
				else
					@lines.push Line.new x1: 50, y1: @y+30+n*15+$scrolled_y, x2: $width-50, y2: @y+30+n*15+$scrolled_y, width: 1, color: $colors["note"]
					@lines[n].opacity = 0.3
				end
			end
			@noises.each do |n|
				n.draw
			end
		end
	end
end

$lure_noise_colors = {"25"=>"#00E5FF", "40"=>"#0099FF", "55"=>"#0582FF", "70"=>"#004DFF", "85"=>"#0516FF", "100"=>"#3C00FF", "115"=>"#9900FF", "130"=>"#3C00FF", "145"=>"#0516FF", "160"=>"#004DFF", "175"=>"#0582FF", "190"=>"#0099FF", "205"=>"#00E5FF"}

class Lure_Noise
	attr_accessor :x, :y, :container_y, :drawn
	def initialize x, y, container_y
		@x = (((x-50)/21).floor)*21+50 # floors to 21, adjusting for the 50 pixel margin on left
		@y = (y-container_y).round_to(15)+container_y-5 # rounds to nearest 15, adjusting for container_y
		@container_y = container_y
		@first_draw = true
		draw
	end
	def draw
		if !@first_draw
			@drawn.remove
		else
			@first_draw = false
		end
		@drawn = Rectangle.new x: @x-$scrolled_x, y: @y+$scrolled_y, width: 21, height: 10, color: $lure_noise_colors[(@y-@container_y).to_s]
	end
	def play animal
		puts "[#{Time.now.strftime("%I:%M:%S")}] resources/sounds/echo_lure/#{(@y-@container_y)/15}#{animal.downcase}"
	end
	def remove
		@drawn.remove
	end
end