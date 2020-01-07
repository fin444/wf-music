$all_mandachord_instruments = ["Adau", "Alpha", "Beta", "Delta", "Gamma", "Epsilon", "Horos", "Druk", "Plogg"]

class Mandachord_UI < UI_Element
	def draw
		@instrument = $all_mandachord_instruments[0]
		@drawn = [[]]
		@notes = []
		64.times do |a|
			3.times do |n|
				@drawn[0].push Mandachord_Note.new "percussion", 50+a*21, @y, n+1
			end
			5.times do |n|
				@drawn[0].push Mandachord_Note.new "bass", 50+a*21, @y, n+1
			end
			5.times do |n|
				@drawn[0].push Mandachord_Note.new "melody", 50+a*21, @y, n+1
			end
		end
		@select_instrument = Dropdown.new (60+determine_text_width("Mandachord", 17)), @y, $all_mandachord_instruments, @instrument, Proc.new{ |s| @instrument = s }
	end
	def click event
		@select_instrument.click event
		@delete_button.click event
		@drawn.each do |a| # loops through every column
			a.each do |n| # loops through everything in column
				if n.drawn.contains? event.x, event.y
					n.selected = !n.selected
					if @notes.include? n
						@notes = @notes - [n]
					else
						@notes.push n
					end
					n.draw
					return
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
		@drawn.each do |a| # loops through every column
			a.each do |n| # loops through everything in column
				n.remove
			end
		end
		@name.remove
		@select_instrument.remove
		@delete_button.remove
		@container.remove
		$containers.delete_at $containers.find_index self
		reposition_all
	end
	def reposition_unique
		@select_instrument.remove
		@select_instrument = Dropdown.new (70+determine_text_width("Mandachord", 17)), @y, $all_mandachord_instruments, @instrument, Proc.new{ |s| @instrument = s }
		@drawn.each do |a|
			a.each do |n|
				n.reposition @y
			end
		end
	end
	def export
		self.to_s
	end
end

class Mandachord_Note
	attr_accessor :drawn, :selected, :x
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
		if @selected
			puts "[#{Time.now.strftime("%I:%M:%S")}] resources/sounds/mandachord/#{instrument.downcase}/#{@number}#{@type}"
		end
	end
	def draw
		if !@first_draw # removes all current, but if they don't exist yet then it doesn't
			@drawn.remove
			@drawn_inner.remove
		end
		@first_draw = false
		@drawn = Rectangle.new x: @x, y: @y, width: 21, height: 21, color: $colors[@type]
		@drawn_inner = Rectangle.new x: @x+1, y: @y+1, width: 19, height: 19, color: determine_color
	end
	def determine_y container_y
		case @type
		when "percussion"
			@y = container_y+@number*21+10
		when "bass"
			@y = container_y+@number*21+73
		when "melody"
			@y = container_y+@number*21+178
		end
	end
	def determine_color
		if @selected
			return $colors[@type.downcase]
		end
		$colors["background"]
	end
	def remove
		@drawn.remove
		@drawn_inner.remove
	end
	def reposition container_y
		determine_y container_y
		draw
	end
end