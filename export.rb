class Export_Window
	def initialize
		@background = Rectangle.new x: 0, y: 0, width: $width, height: $height, color: [0, 0, 0, 0.8], z: 10
		@outline = Rectangle.new x: 50, y: 50, width: $width-100, height: $height-100, color: $colors["string"], z: 11
		@container = Rectangle.new x: 51, y: 51, width: $width-102, height: $height-102, color: $colors["background"], z: 12
		@title = Text.new "Export", x: 60, y: 60, size: 50, color: $colors["string"], z: 13
		@delete_button = Delete_Button.new $width-80, 65, self
		@delete_button.z = 13
		@delete_button.draw
		@elements = [] # all things created later wil be put here so they can be easily removed
		# get all exports from instruments
		shawzin_exports = []
		mandachord_exports = []
		$containers.select{ |c| c.class.name == "Shawzin_UI" }.each do |c|
			shawzin_exports.push c.export
		end
		$containers.select{ |c| c.class.name == "Mandachord_UI" }.each do |c|
			mandachord_exports.push c.export
		end
		# draw them down
		if shawzin_exports.length != 0
			@elements.push Text.new "Shawzin", x: 60, y: determine_element_y, size: 30, color: $colors["string"], z: 13
			@elements.push Text.new "Press the buttons below to copy these codes and paste them into your shawzin songs list.", x: 60, y: determine_element_y, size: 20, color: $colors["string"], z: 13
			shawzin_exports.each do |e|
				@elements.push Text_Button.new "Shawzin Track #{shawzin_exports.find_index e} (#{$all_scales[e[0].to_i]})", 60, determine_element_y, Proc.new{ Clipboard.copy e }
				@elements[-1].z = 13
				@elements[-1].draw
			end
		end
		if mandachord_exports.length != 0
			@elements.push Text.new "Mandachord", x: 60, y: determine_element_y, size: 30, color: $colors["string"], z: 13
			@elements.push Text.new "Press the buttons below to copy these codes and paste them into your mandachord songs list.", x: 60, y: determine_element_y, size: 20, color: $colors["string"], z: 13
			mandachord_exports.each do |e|
				@elements.push Text_Button.new "Mandachord Track #{mandachord_exports.find_index e}", 60, determine_element_y, Proc.new{ Clipboard.copy e }
				@elements[-1].z = 13
				@elements[-1].draw
			end
		end
	end
	def determine_element_y # to automatically place dynamically generated elements
		if @elements.length == 0
			return 70+@title.height
		end
		@elements[-1].y+@elements[-1].height+10
	end
	def click event
		@delete_button.click event
		@elements.select{ |e| e.class.name == "Text_Button" || e.class.name == "Quad_Button" }.each do |e|
			e.click event
		end
	end
	def mouse_down event
		@delete_button.mouse_down event
		@elements.select{ |e| e.class.name == "Text_Button" || e.class.name == "Quad_Button" }.each do |e|
			e.mouse_down event
		end
	end
	def remove
		@background.remove
		@outline.remove
		@container.remove
		@title.remove
		@delete_button.remove
		@elements.each do |e|
			e.remove
		end
		$export_window = nil
	end
end