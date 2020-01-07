$all_animals = ["Virmink", "Sawgaw", "Bolarola", "Horrasque", "Stover", "Kubrodon", "Kuaka", "Condroc", "Mergoo", "Vasca"]

class Lure_UI < UI_Element
	def draw
		@animal = $all_animals[0]
		@select_animal = Dropdown.new (60+determine_text_width("Echo Lure", 17)), @y, $all_animals, @animal, Proc.new{ |s| @animal = s }
		@lines = []
		@noises = []
		13.times do |n|
			if n == 3 || n == 9
				@lines.push Line.new x1: 50, y1: @y+30+n*15, x2: $width-50, y2: @y+30+n*15, width: 2, color: $colors["note"]
				@lines[n].opacity = 0.4
			else
				@lines.push Line.new x1: 50, y1: @y+30+n*15, x2: $width-50, y2: @y+30+n*15, width: 1, color: $colors["note"]
				@lines[n].opacity = 0.3
			end
		end
	end
	def click event
		@select_animal.click event
		@delete_button.click event
	end
	def mouse_down event
		if event.y > @y+20
			if event.x > 50 && event.x < $width-50 && !@noises.any?{ |n| n.x == (((event.x-50)/15).floor)*15+50 && n.y == (((event.y-@y)/15).floor)*15+@y-5 }
				@noises.push Lure_Noise.new event.x, event.y, @y
			end
		else
			@delete_button.mouse_down event
		end
	end
	def mouse_move event
		if event.y > @y+20 && event.y < @y+220 && event.x > 50 && event.x < $width-50 && !@noises.any?{ |n| n.x == (((event.x-50)/15).floor)*15+50 && n.y == (((event.y-@y)/15).floor)*15+@y-5 }
			@noises.push Lure_Noise.new event.x, event.y, @y
		end
	end
	def play x
		@noises.filter{ |n| n.x == x }.each do |n|
			n.play @animal
		end
	end
	def get_last_sound
		h = 0
		@noises.each do |n|
			if n.x+10 > h
				h = n.x+10
			end
		end
		h
	end
	def remove
		@select_animal.remove
		@delete_button.remove
		@name.remove
		@lines.each do |l|
			l.remove
		end
		$containers.delete_at $containers.find_index self
		reposition_all
	end
	def reposition_unique
		# TODO after finishing the code
	end
end

class Lure_Noise
	attr_accessor :x, :y
	def initialize x, y, container_y
		@x = (((x-50)/15).floor)*15+50 # rounds to nearest 15, adjusting for the 50 pixel margin on left
		@y = (((y-container_y)/15).floor)*15+container_y-5 # rounds to nearest 15, adjusting for container_y
		@container_y = container_y
		determine_color
		@first_draw = true
		draw
	end
	def determine_color # light blue on outer lines, more purple towards center
		puts @y
		puts @container_y
		if @y == @container_y+115
			@color = [42, 0, 81, 1]
		elsif @y < @container_y+115
			@color = [42, 4*(@y-@container_y), 255/(@y-@container_y), 1]
		else
			@color = [42, 4*(115-(@y-@container_y)), 255/(115-(@y-@container_y)), 1]
		end
	end
	def draw
		if !@first_draw
			@drawn.remove
		else
			@first_draw = false
		end
		@drawn = Rectangle.new x: @x, y: @y, width: 15, height: 10, color: @color
	end
	def play animal
		puts "[#{Time.now.strftime("%I:%M:%S")}] resources/sounds/echo_lure/#{(@y-@container_y)/15}#{animal.downcase}"
	end
	def remove
		@drawn.remove
	end
end