class Popup_Info
	def initialize text
		$alert = self
		# figure out where text goes on lines
		arr = [""]
		text.split(" ").each do |t|
			if arr[-1] == ""
				arr[-1] = t
			elsif get_text_width("#{arr[-1]} #{t}", 20) <= 380
				arr[-1] = "#{arr[-1]} #{t}"
			else
				arr.push t
			end
		end
		height = 50+arr.length*20
		# draw
		@background = Rectangle.new x: 0, y: 0, width: $width, height: $height, color: [0, 0, 0, 0.8], z: 10
		@outline = Rectangle.new x: ($width/2)-201, y: ($height/2)-(height/2)-1, width: 402, height: height+2, color: $colors["string"], z: 10
		@container = Rectangle.new x: ($width/2)-200, y: ($height/2)-(height/2), width: 400, height: height, color: $colors["background"], z: 10
		@info = []
		arr.each do |a|
			@info.push Text.new a, x: ($width/2)-190, y: ($height/2)-(height/2)+(arr.find_index(a)*20)+5, size: 20, color: $colors["string"], z: 10
		end
		@button = Text_Button.new "Okay", ($width/2)-(get_text_width("Okay", 20)/2), ($height/2)+(height/2)-30, 20, Proc.new{ $alert.remove }
		@button.z = 10
	end
	def click event
		@button.click event
	end
	def mouse_down event
		@button.mouse_down event
	end
	def remove
		@background.remove
		@outline.remove
		@container.remove
		@info.each do |i|
			i.remove
		end
		@button.remove
		$alert = nil
	end
end
class Popup_Confirm
	def initialize text, action_1, action_2
		$alert = self
		@action_1 = action_1
		@action_2 = action_2
		# figure out where text goes on lines
		arr = [""]
		text.split(" ").each do |t|
			if arr[-1] == ""
				arr[-1] = t
			elsif get_text_width("#{arr[-1]} #{t}", 20) <= 380
				arr[-1] = "#{arr[-1]} #{t}"
			else
				arr.push t
			end
		end
		height = 50+arr.length*20
		# draw
		@background = Rectangle.new x: 0, y: 0, width: $width, height: $height, color: [0, 0, 0, 0.8], z: 10
		@outline = Rectangle.new x: ($width/2)-201, y: ($height/2)-(height/2)-1, width: 402, height: height+2, color: $colors["string"], z: 10
		@container = Rectangle.new x: ($width/2)-200, y: ($height/2)-(height/2), width: 400, height: height, color: $colors["background"], z: 10
		@info = []
		arr.each do |a|
			@info.push Text.new a, x: ($width/2)-190, y: ($height/2)-(height/2)+(arr.find_index(a)*20)+5, size: 20, color: $colors["string"], z: 10
		end
		@yes_button = Text_Button.new "Yes", ($width/2)-get_text_width("Yes", 20)-10, ($height/2)+(height/2)-30, 20, Proc.new{
			$alert.remove
			@action_1.call
		}
		@yes_button.z = 10
		@no_button = Text_Button.new "No", ($width/2)+10, ($height/2)+(height/2)-30, 20, Proc.new{
			$alert.remove
			@action_2.call
		}
		@no_button.z = 10
	end
	def click event
		@yes_button.click event
		@no_button.click event
	end
	def mouse_down event
		@yes_button.mouse_down event
		@no_button.mouse_down event
	end
	def remove
		@background.remove
		@outline.remove
		@container.remove
		@info.each do |i|
			i.remove
		end
		@yes_button.remove
		@no_button.remove
		$alert = nil
	end
end
class Popup_Ask
	def initialize title, action
		$alert = self
		@action = action
		@text = ""
		@background = Rectangle.new x: 0, y: 0, width: $width, height: $height, color: [0, 0, 0, 0.8], z: 10
		@outline = Rectangle.new x: ($width/2)-201, y: ($height/2)-51, width: 402, height: 102, color: $colors["string"], z: 10
		@container = Rectangle.new x: ($width/2)-200, y: ($height/2)-50, width: 400, height: 100, color: $colors["background"], z: 10
		@title = Text.new title, x: ($width/2)-(get_text_width(title, 25)/2), y: ($height/2)-45, size: 25, color: $colors["string"], z: 10
		@input_outline = Rectangle.new x: ($width/2)-191, y: ($height/2)-16, width: 382, height: 32, color: $colors["string"], z: 10
		@input_box = Rectangle.new x: ($width/2)-190, y: ($height/2)-15, width: 380, height: 30, color: $colors["background"], z: 10
		@writing = Text.new @text, x: ($width/2)-188, y: ($height/2)-12, size: 20, color: $colors["string"], z: 10
		@button = Text_Button.new "Okay", ($width/2)-(get_text_width("Okay", 20)/2), ($height/2)+20, 20, Proc.new{
			$alert.remove
			@action.call @text
		}
		@button.z = 10
		@position = 0
		@display_from = 0
		@display_to = 0
		@blinker = Line.new x1: ($width/2)-187+get_text_width(@text[0, @position], 20), y1: ($height/2)-10, x2: ($width/2)-187+get_text_width(@text[0, @position], 20), y2: ($height/2)+10, width: 2, color: $colors["string"], z: 10
	end
	def click event
		@button.click event
	end
	def mouse_down event
		@button.mouse_down event
	end
	def key_down event
		if "abcdefghijklmnopqrstuvwxyz".include? event.key # if letter, add either lowercase or uppercase
			if $keys_down.include? "left shift" or $keys_down.include? "right shift"
				@text = @text[0, @position] + event.key.upcase + @text[@position..-1]
			else
				@text = @text[0, @position] + event.key + @text[@position..-1]
			end
			@position += 1
		elsif "0123456789,./-".include? event.key # if special char, add either char or other if shift is down
			if $keys_down.include? "left shift" or $keys_down.include? "right shift"
				@text = @text[0, @position] + {"0"=>")", "1"=>"!", "2"=>"@", "3"=>"#", "4"=>"$", "5"=>"%", "6"=>"^", "7"=>"&", "8"=>"*", "9"=>"(", ","=>"<", "."=>">", "/"=>"?", "-"=>"_"}[event.key] + @text[@position..-1]
			else
				@text = @text[0, @position] + event.key + @text[@position..-1]
			end
			@position += 1
		elsif event.key == "space"
			@text = "#{@text[0, @position]} #{@text[@position..-1]}"
			@position += 1
		elsif event.key == "backspace" and @text.length > 0
			@text ="#{@text[0, @position-1]}#{@text[@position, @text.length-(@text.length-@position)]}"
			@position -= 1
		elsif event.key == "return" # submit when enter pressed
			$alert.remove
			@action.call @text
		elsif event.key == "left" && @position != 0
			@position -= 1
		elsif event.key == "right" && @position != @text.length
			@position += 1
		elsif event.key == "up"
			@position = 0
		elsif event.key == "down"
			@position = @text.length
		end
		if event.key != "return" # prevents re-rendering after being removed
			while get_text_width(@text[@display_from..@position], 20) > 380 do
				@display_from += 1				
			end
			if @display_from != 0 and @position != @text.length and get_text_width(@text[@display_from..@position], 20) < 380
				while get_text_width(@text[@display_from..@position], 20) < 380 and @display_from != 0
					@display_from -= 1
				end
				if get_text_width(@text[@display_from..@position], 20) > 380
					@display_from += 1
				end
			end
			while get_text_width(@text[@display_from..@display_to], 20) < 380 and @display_to < @text.length-1
				@display_to += 1
			end
			while get_text_width(@text[@display_from..@display_to], 20) > 380 and @display_to != 0
				@display_to -= 1
			end
			@writing.remove
			@writing = Text.new @text[@display_from..@display_to], x: ($width/2)-188, y: ($height/2)-12, size: 20, color: $colors["string"], z: 10
		end
	end
	def blink # blinking cursor
		@blinker.remove
		if $time_counter >= 30
			@blinker = Line.new x1: ($width/2)-187+get_text_width(@text[@display_from...@position], 20), y1: ($height/2)-10, x2: ($width/2)-187+get_text_width(@text[@display_from...@position], 20), y2: ($height/2)+10, width: 2, color: $colors["string"], z: 10
		end
	end
	def remove
		@background.remove
		@outline.remove
		@container.remove
		@title.remove
		@input_outline.remove
		@input_box.remove
		@writing.remove
		@blinker.remove
		@button.remove
		$alert = nil
	end
end
class Popup_File
	def initialize action
		$alert = self
		@action = action
		if !File.exists? "saves"
			$alert = nil
			Popup_Info.new "There are no files in the saves folder."
			return
		end
		@file_list = Dir.children("saves").filter{ |s| s[-4, 4] == ".txt" }
		if @file_list.length == 0
			$alert = nil
			Popup_Info.new "There are no files in the saves folder."
			return
		end
		# find height and width of window
		@height = 100+@file_list.length*20
		@width = get_text_width "Choose a File", 40
		@file_list.each do |f|
			if get_text_width(f, 17) > @width
				@width = get_text_width f, 17
			end
		end
		@width += 20 # padding
		# draw
		@background = Rectangle.new x: 0, y: 0, width: $width, height: $height, color: [0, 0, 0, 0.8], z: 10
		@outline = Rectangle.new x: ($width/2)-(@width/2)-1, y: ($height/2)-(@height/2)-1, width: @width+2, height: @height+2, color: $colors["string"], z: 10
		@container = Rectangle.new x: ($width/2)-(@width/2), y: ($height/2)-(@height/2), width: @width, height: @height, color: $colors["background"], z: 10
		@title = Text.new "Choose a File", x: ($width/2)-(@width/2)+10, y: ($height/2)-(@height/2)+10, size: 40, color: $colors["string"], z: 10
		@selector_containers = [] # bounding boxes for each file selector
		@selector_names = [] # the actual names of the file
		@file_list.each do |f|
			@selector_containers.push Rectangle.new x: ($width/2)-(@width/2), y: ($height/2)-(@height/2)+60+@file_list.find_index(f)*20, width: @width-20, height: 20, color: $colors["background"], z: 10
			@selector_names.push Text.new f, x: ($width/2)-(@width/2)+15, y: ($height/2)-(@height/2)+60+@file_list.find_index(f)*20, size: 17, color: $colors["string"], z: 10
		end
		@button = Text_Button.new "Select", ($width/2)-(get_text_width("Select", 20)/2), ($height/2)+(@height/2)-30, 20, Proc.new{ $alert.remove }
		@button.z = 10
		# set the first file to be currently selected
		@selected = @file_list[0]
		@selector_containers[0].remove
		@selector_names[0].remove
		@selector_containers[0] = Rectangle.new x: ($width/2)-(@width/2)+10, y: ($height/2)-(@height/2)+60+@file_list.find_index(@selected)*20, width: @width-20, height: 20, color: $colors["string"], z: 10
		@selector_names[0] = Text.new @selected, x: ($width/2)-(@width/2)+15, y: ($height/2)-(@height/2)+60+@file_list.find_index(@selected)*20, size: 17, color: $colors["background"], z: 10
	end
	def click event
		@selector_containers.each do |s|
			if s.contains? event.x, event.y
				old_index = @file_list.find_index @selected
				new_index = @selector_containers.find_index s
				# unselect the old file
				@selector_containers[old_index].remove
				@selector_names[old_index].remove
				@selector_containers[old_index] = Rectangle.new x: ($width/2)-(@width/2)+10, y: ($height/2)-(@height/2)+60+@file_list.find_index(@selected)*20, width: @width-20, height: 20, color: $colors["background"], z: 10
				@selector_names[old_index] = Text.new @selected, x: ($width/2)-(@width/2)+15, y: ($height/2)-(@height/2)+60+@file_list.find_index(@selected)*20, size: 17, color: $colors["string"], z: 10
				# select the new file
				@selected = @file_list[new_index]
				@selector_containers[new_index].remove
				@selector_names[new_index].remove
				@selector_containers[new_index] = Rectangle.new x: ($width/2)-(@width/2)+10, y: ($height/2)-(@height/2)+60+@file_list.find_index(@selected)*20, width: @width-20, height: 20, color: $colors["string"], z: 10
				@selector_names[new_index] = Text.new @selected, x: ($width/2)-(@width/2)+15, y: ($height/2)-(@height/2)+60+@file_list.find_index(@selected)*20, size: 17, color: $colors["background"], z: 10
			end
		end
		@button.click event
	end
	def mouse_down event
		@button.mouse_down event
	end
	def remove
		@action.call @selected
		@background.remove
		@outline.remove
		@container.remove
		@title.remove
		@selector_containers.each do |s|
			s.remove
		end
		@selector_names.each do |s|
			s.remove
		end
		@button.remove
		$alert = nil
	end
end
class Popup_Instrument_Options
	def initialize instrument
		$alert = self
		@instrument = instrument
		# draw
		@background = Rectangle.new x: 0, y: 0, width: $width, height: $height, color: [0, 0, 0, 0.8], z: 10
		@outline = Rectangle.new x: ($width/2)-201, y: ($height/2)-101, width: 402, height: 202, color: $colors["string"], z: 10
		@container = Rectangle.new x: ($width/2)-200, y: ($height/2)-100, width: 400, height: 200, color: $colors["background"], z: 10
		@title = Text.new "Options for #{instrument.class.name.split("_")[0]}", x: ($width/2)-(get_text_width("Options for #{instrument.class.name.split("_")[0]}", 30)/2), y: ($height/2)-90, size: 30, color: $colors["string"], z: 10
		@items = []
		@items.push Text_Button.new "Okay", ($width/2)-(get_text_width("Okay", 20)/2), ($height/2)+70, 20, Proc.new{ $alert.remove }
		case @instrument.class.name
		when "Shawzin_UI"
			@items.push Text_Button.new "Copy Song Code", ($width/2)-((get_text_width("Pentatonic Major", 20)+20)), ($height/2)-30, 20, Proc.new{ Clipboard.copy @instrument.export }
			@items.push Text_Button.new "Import Song Code", ($width/2), ($height/2)-30, 20, Proc.new{
				begin
					@instrument.import Clipboard.paste
				rescue => err
					$alert.remove
					Popup_Info.new "That song code is invalid."
				end
			}
			@items.push Dropdown.new ($width/2)-((get_text_width("Normal", 17)+get_text_width("Pentatonic Major", 17)+60)/2), ($height/2), $all_scales, @instrument.scale, Proc.new{ |s| @instrument.scale = s }
			@items.push Dropdown.new ($width/2)+((get_text_width("Pentatonic Major", 17)-get_text_width("Normal", 17))/2), ($height/2), $all_shawzin_types, @instrument.type, Proc.new{ |t| @instrument.type = t }
		when "Mandachord_UI"
			@items.push Check_Box.new ($width/2)-(get_text_width("Loop", 20)/2)-13, ($height/2)-40, @instrument.looped, "Loop", Proc.new{ |l|
				if l and @instrument.notes.any?{ |d| d.x > 1344 }
					$alert.remove
					Popup_Confirm.new "Doing this will delete #{@instrument.notes.filter{ |d| d.x > 1344 }.length} notes saved in your mandachord after the first 8 seconds. Are you sure?", Proc.new{
						@instrument.looped = true
						Popup_Instrument_Options.new @instrument
					}, Proc.new{
						$alert.items.filter{ |i| i.class.name == "Check_Box" }[0].checked = false
						$alert.items.filter{ |i| i.class.name == "Check_Box" }[0].draw
						Popup_Instrument_Options.new @instrument
					}
				elsif l
					@instrument.looped = true
				else
					@instrument.looped = false
				end
			}
			@items.push Dropdown.new ($width/2)-((get_text_width("Gamma", 17)+20)*1.5), ($height/2), $all_mandachord_instruments, @instrument.instrument_percussion, Proc.new{ |i| @instrument.instrument_percussion = i }
			@items.push Dropdown.new ($width/2)-((get_text_width("Gamma", 17)+20)/2), ($height/2), $all_mandachord_instruments, @instrument.instrument_bass, Proc.new{ |i| @instrument.instrument_bass = i }
			@items.push Dropdown.new ($width/2)+((get_text_width("Gamma", 17)+20)/2), ($height/2), $all_mandachord_instruments, @instrument.instrument_melody, Proc.new{ |i| @instrument.instrument_melody = i }
			@items.push Text_Button.new "Copy", ($width/2)-(get_text_width("Copy", 20)/2), ($height/2)+30, 20, Proc.new{
				$alert.remove
				if @instrument.notes.length == 0
					Popup_Info.new "Copy only works if there are notes in the mandachord."
				else
					Mandachord_Copy.new @instrument
				end
			}
		when "Lure_UI"
			@title.remove
			@title = Text.new "Options for Echo Lure", x: ($width/2)-(get_text_width("Options for Echo Lure", 30)/2), y: ($height/2)-90, size: 30, color: $colors["string"], z: 10
			@items.push Text_Button.new "Live Copy", ($width/2)-(get_text_width("Live Copy", 20)/2)-5, ($height/2)-30, 20, Proc.new{
				$alert.remove
				if @instrument.noises.length > 0
					Lure_Copy.new @instrument.noises
				else
					Popup_Info.new "Live Copy only works if there are noises in the echo lure."
				end
			}
			@items.push Dropdown.new ($width/2)-((get_text_width("Horrasque", 17)+20)/2), ($height/2), $all_animals, @instrument.animal, Proc.new{ |a| @instrument.animal = a }
		end
		@items.each do |i|
			i.z = 10
		end
	end
	def click event
		@items.each do |i|
			i.click event
		end
	end
	def mouse_down event
		@items.each do |i|
			i.mouse_down event
		end
	end
	def remove
		@background.remove
		@outline.remove
		@container.remove
		@title.remove
		@items.each do |i|
			i.remove
		end
		$alert = nil
	end
end