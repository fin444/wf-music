$all_animals = ["Pobbers", "Virmink", "Sawgaw", "Bolarola", "Horrasque", "Stover", "Kubrodon", "Kuaka", "Condroc", "Mergoo", "Vasca"]

class Lure_UI
	attr_accessor :animal, :y, :container, :noises
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
		@noises_by_time = {}
		13.times do |n|
			if n == 3 || n == 9
				@lines.push Line.new x1: 50, y1: @y+30+n*15+$scrolled_y, x2: $width-50, y2: @y+30+n*15+$scrolled_y, width: 2, color: "white"
				@lines[n].opacity = 0.4
			else
				@lines.push Line.new x1: 50, y1: @y+30+n*15+$scrolled_y, x2: $width-50, y2: @y+30+n*15+$scrolled_y, width: 1, color: "white"
				@lines[n].opacity = 0.3
			end
		end
		$scroll_list_x.push self
		$scroll_list_y.push self
		$containers.push self
	end
	def click event
		if !$playing and @container.contains? event.x, event.y
			@delete_button.click event
			@options.click event
		end
	end
	def right_click event
		if !$playing and @container.contains? event.x, event.y
			@noises.each do |n|
				if n.drawn.contains? event.x, event.y
					n.remove
					@noises.delete_at @noises.find_index n
					connect_noises
				end
			end
		end
	end
	def mouse_down event
		if !$playing and @container.contains? event.x, event.y
			new_noise event
			@delete_button.mouse_down event
			@options.mouse_down event
		end
	end
	def mouse_move event
		if !$playing and @container.contains? event.x, event.y
			new_noise event
		end
	end
	def new_noise event
		if event.y-$scrolled_y > @y+30 && event.y-$scrolled_y < @y+218 && event.x > 50 && event.x < $width-50
			if @noises_by_time[((event.x+$scrolled_x)/1000).to_s].nil?
				@noises_by_time[((event.x+$scrolled_x)/1000).to_s] = []
			end
			if @noises_by_time[((event.x+$scrolled_x)/1000).to_s].any?{ |n| n.x == (event.x+$scrolled_x-50).floor_to(21)+50 }
				@noises_by_time[((event.x+$scrolled_x)/1000).to_s].filter{ |n| n.x == (event.x+$scrolled_x-50).floor_to(21)+50 }.each do |n|
					n.y = (event.y-$scrolled_y-@y).round_to(15)+@y-5
					n.draw
				end
			else
				@noises.push Lure_Noise.new event.x+$scrolled_x, event.y-$scrolled_y, @y
				@noises_by_time[(@noises[-1].x/1000).to_s].push @noises[-1]
			end
			change
		end
	end
	def get_last_sound
		connect_noises
		highest = 0
		highest_key = "0"
		if @noises_by_time.length == 0
			return 0
		end
		@noises_by_time.keys.each do |k|
			if k.to_i > highest_key.to_i
				highest_key = k
			end
		end
		@noises_by_time[highest_key].each do |n|
			if n.x > highest
				highest = n.x
			end
		end
		highest
	end
	def play x
		if !@noises_by_time[(x/1000).to_s].nil?
			@noises_by_time[(x/1000).to_s].filter{ |n| x == n.x }.each do |n|
				n.play @animal # when actual noises are added, make it so that they flow based on @connected_noises
			end
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
				if @noises_by_time[(@noises[-1].x/1000).to_s].nil?
					@noises_by_time[(@noises[-1].x/1000).to_s] = []
				end
				@noises_by_time[(@noises[-1].x/1000).to_s].push @noises[-1]

			end
		end
		@noises.filter{ |n| n.x < $scrolled_x && n.x > $width+$scrolled_x }.each do |n|
			n.remove
		end
	end
	def connect_noises
		@noises.sort_by! { |n| n.x }
		@connected_noises = [[]]
		@noises.each do |n|
			if @noises[0] == n
				@connected_noises[0].push n
			elsif @connected_noises[-1][-1].x+21 == n.x
				@connected_noises[-1].push n
			else
				@connected_noises.push [n]
			end
		end
	end
	def scroll_x
		@noises.each do |n|
			n.remove
		end
		if !@noises_by_time[($scrolled_x/1000).to_s].nil?
			@noises_by_time[($scrolled_x/1000).to_s].filter{ |n| n.x-20 > $scrolled_x && n.x+20 < $scrolled_x+$width }.each do |n|
				n.draw
			end
		end
		if !@noises_by_time[(1+($scrolled_x/1000)).to_s].nil?
			@noises_by_time[(1+($scrolled_x/1000)).to_s].filter{ |n| n.x-20 > $scrolled_x && n.x+20 < $scrolled_x+$width }.each do |n|
				n.draw
			end
		end
		if (($scrolled_x/1000)+2)*1000 < $scrolled_x+$width and !@noises_by_time[(2+($scrolled_x/1000)).to_s].nil?
			@noises_by_time[(2+($scrolled_x/1000)).to_s].filter{ |n| n.x-20 > $scrolled_x && n.x+20 < $scrolled_x+$width }.each do |n|
				n.draw
			end
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
					@lines.push Line.new x1: 50, y1: @y+30+n*15+$scrolled_y, x2: $width-50, y2: @y+30+n*15+$scrolled_y, width: 2, color: "white"
					@lines[n].opacity = 0.4
				else
					@lines.push Line.new x1: 50, y1: @y+30+n*15+$scrolled_y, x2: $width-50, y2: @y+30+n*15+$scrolled_y, width: 1, color: "white"
					@lines[n].opacity = 0.3
				end
			end
			scroll_x # scroll noises
		end
	end
end

$lure_noise_colors = {"25"=>"#00E5FF", "40"=>"#0099FF", "55"=>"#0582FF", "70"=>"#004DFF", "85"=>"#0516FF", "100"=>"#3C00FF", "115"=>"#9900FF", "130"=>"#3C00FF", "145"=>"#0516FF", "160"=>"#004DFF", "175"=>"#0582FF", "190"=>"#0099FF", "205"=>"#00E5FF"}

class Lure_Noise
	attr_accessor :x, :y, :container_y, :drawn
	def initialize x, y, container_y
		@x = (x-50).floor_to(21)+50 # floors to 21, adjusting for the 50 pixel margin on left
		@y = (y-container_y).round_to(15)+container_y-5 # rounds to nearest 15, adjusting for container_y
		@container_y = container_y
		draw
	end
	def draw
		# remove
		@drawn.remove
		# draw
		@drawn = Rectangle.new x: @x-$scrolled_x, y: @y+$scrolled_y, width: 21, height: 10, color: $lure_noise_colors[(@y-@container_y).to_s]
	end
	def play animal
		url = "resources/sounds/echo_lure/#{(@y-@container_y)/15}#{animal.downcase}"
		puts "[#{Time.now.strftime("%I:%M:%S")}] #{url}"
		# @sound = Sound.new(url) # causes bugs if not stored as variable
		# @sound.play
	end
	def remove
		@drawn.remove
	end
end

class Lure_Copy
	def initialize noises
		$alert = self
		@noises = noises
		@drawn = []
		@lines = []
		@playing = false
		@scrolled = -1344 # how far the noises are scrolled
		@background = Rectangle.new x: 0, y: 0, width: $width, height: $height, color: [0, 0, 0, 0.8], z: 10
		@outline = Rectangle.new x: 49, y: ($height/2)-111, width: $width-98, height: 222, color: $colors["string"], z: 10
		@container = Rectangle.new x: 50, y: ($height/2)-110, width: $width-100, height: 220, color: $colors["background"], z: 10
		@delete_button = Delete_Button.new $width-75, ($height/2)-100, self
		@delete_button.z = 10
		@start_button = Text_Button.new "Start", ($width/2)-(get_text_width("Start", 25)/2), ($height/2)-10, 25, Proc.new{ start }
		@start_button.z = 10
	end
	def click event
		@delete_button.click event
		if !@playing
			@start_button.click event
		end
	end
	def mouse_down event
		@delete_button.mouse_down event
		if !@playing
			@start_button.mouse_down event
		end
	end
	def start
		@playing = true
		@start_button.remove
		13.times do |n|
			if n == 3 || n == 9
				@lines.push Line.new x1: 50, y1: ($height/2)-110+30+n*15, x2: $width-50, y2: ($height/2)-110+30+n*15, width: 2, color: "white", z: 10
				@lines[n].opacity = 0.4
			else
				@lines.push Line.new x1: 50, y1: ($height/2)-110+30+n*15, x2: $width-50, y2: ($height/2)-110+30+n*15, width: 1, color: "white", z: 10
				@lines[n].opacity = 0.3
			end
		end
		@lines.push Line.new x1: ($width/2)-10, y1: ($height/2)-110, x2: ($width/2)-10, y2: ($height/2)+110, color: "white", z: 11
		@lines.push Line.new x1: ($width/2)+10, y1: ($height/2)-110, x2: ($width/2)+10, y2: ($height/2)+110, color: "white", z: 11
	end
	def refresh
		if @playing
			@scrolled += (1340.0/480.0).round 3
			@drawn.each do |d|
				d.remove
			end
			@drawn = []
			if @noises.filter{ |n| n.x+21-@scrolled > 50 }.length != 0
				@noises.filter{ |n| n.x+21-@scrolled > 50 and n.x-@scrolled < $width-50 }.each do |n|
					if n.x-@scrolled < 50
						@drawn.push Rectangle.new x: 50, y: n.y+($height/2)-110-n.container_y, width: n.x-@scrolled-29, height: 10, color: n.drawn.color, z: 10
					elsif n.x+21-@scrolled > $width-50
						@drawn.push Rectangle.new x: n.x-@scrolled, y: n.y+($height/2)-110-n.container_y, width: $width-50-n.x+@scrolled, height: 10, color: n.drawn.color, z: 10
					else
						@drawn.push Rectangle.new x: n.x-@scrolled, y: n.y+($height/2)-110-n.container_y, width: 21, height: 10, color: n.drawn.color, z: 10
					end
				end
			else
				@lines.each do |l|
					l.remove
				end
				@lines = []
				@playing = false
				@start_button.draw
				@scrolled = -1344
			end
		end
	end
	def remove
		@background.remove
		@outline.remove
		@container.remove
		@delete_button.remove
		if !@playing
			@start_button.remove
		end
		@lines.each do |l|
			l.remove
		end
		@drawn.each do |d|
			d.remove
		end
		$alert = nil
	end
end