class Add_UI < UI_Element
	def init
		@buttons = []
		@buttons.push Text_Button.new "Shawzin", $width/2-192, @y+$scrolled_y, 22, Proc.new{ new_element "Shawzin" }
		@buttons.push Text_Button.new "Mandachord", $width/2-90, @y+$scrolled_y, 22, Proc.new{ new_element "Mandachord" }
		@buttons.push Text_Button.new "Echo Lure", $width/2+49, @y+$scrolled_y, 22, Proc.new{ new_element "Echo Lure" }
		@delete_button.remove # don't delete the add section
		$scroll_list_y.push self
	end
	def click event
		@buttons.each do |b|
			b.click event
		end
	end
	def mouse_down event
		@buttons.each do |b|
			b.mouse_down event
		end
	end
	def remove
		@buttons.each do |b|
			b.remove
		end
		@container.remove
		$scroll_list_y.delete_at $scroll_list_y.find_index self
		$containers.delete_at $containers.find_index self
	end
	def reposition # just delete it and remake, a lot easier to do
		remove
		Add_UI.new
	end
	def scroll_y
		@buttons.each do |b|
			b.remove
		end
		@buttons = []
		@container.remove
		if @y+@height > $scrolled_y and @y < $height-$scrolled_y
			@container = Rectangle.new x: 50, y: @y+$scrolled_y, width: $width-100, height: @height, color: [0, 0, 0, 0]
			@buttons.push Text_Button.new "Shawzin", $width/2-192, @y+$scrolled_y, 22, Proc.new{ new_element "Shawzin" }
			@buttons.push Text_Button.new "Mandachord", $width/2-90, @y+$scrolled_y, 22, Proc.new{ new_element "Mandachord" }
			@buttons.push Text_Button.new "Echo Lure", $width/2+49, @y+$scrolled_y, 22, Proc.new{ new_element "Echo Lure" }
		end
	end
end

def new_element type
	$containers[-1].remove
	case type
	when "Shawzin"
		Shawzin_UI.new
	when "Mandachord"
		Mandachord_UI.new
	when "Echo Lure"
		Lure_UI.new
	end
	Add_UI.new
	change
end

Add_UI.new