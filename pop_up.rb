class Popup_Info
	def initialize text
		# figure out where text goes on lines
		arr = [""]
		text.split(" ").each do |t|
			if arr[-1] == ""
				arr[-1] = t
			elsif get_text_width("#{arr[-1]} #{t}", 17) <= 380
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
		@button.draw
		$alert = self
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
		@action_1 = action_1
		@action_2 = action_2
		# figure out where text goes on lines
		arr = [""]
		text.split(" ").each do |t|
			if arr[-1] == ""
				arr[-1] = t
			elsif get_text_width("#{arr[-1]} #{t}", 17) <= 380
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
		@yes_button.draw
		@no_button = Text_Button.new "No", ($width/2)+10, ($height/2)+(height/2)-30, 20, Proc.new{
			$alert.remove
			@action_2.call
		}
		@no_button.z = 10
		@no_button.draw
		$alert = self
	end
	def click event
		puts "hello"
		@yes_button.click event
		@no_button.click event
	end
	def mouse_down event
		@yes_button.mouse_down event
		@yes_button.mouse_down event
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
		@action = action
		@text = ""
		@background = Rectangle.new x: 0, y: 0, width: $width, height: $height, color: [0, 0, 0, 0.8], z: 10
		@outline = Rectangle.new x: ($width/2)-201, y: ($height/2)-101, width: 402, height: 202, color: $colors["string"], z: 10
		@container = Rectangle.new x: ($width/2)-200, y: ($height/2)-100, width: 400, height: 200, color: $colors["background"], z: 10
		@title = Text.new title, x: ($width/2)-(get_text_width(title, 25)/2), y: ($height/2)-90, size: 25, color: $colors["string"], z: 10
		@input_outline = Rectangle.new x: ($width/2)-191, y: ($height/2)-16, width: 382, height: 32, color: $colors["note"], z: 10
		@input_box = Rectangle.new x: ($width/2)-190, y: ($height/2)-15, width: 380, height: 30, color: $colors["background"], z: 10
		@writing = Text.new @text, x: ($width/2)-188, y: ($height/2)-12, size: 20, color: $colors["note"], z: 10
		@button = Text_Button.new "Okay", ($width/2)-(get_text_width("Okay", 20)/2), ($height/2)+70, 20, Proc.new{
			$alert.remove
			@action.call @text
		}
		@button.z = 10
		@button.draw
		@blinker = Line.new x1: ($width/2)-187+get_text_width(@text, 20), y1: ($height/2)-10, x2: ($width/2)-187+get_text_width(@text, 20), y2: ($height/2)+10, width: 2, color: $colors["note"], z: 10
		$alert = self
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
				@text += event.key.upcase
			else
				@text += event.key.downcase
			end
		elsif "0123456789,./".include? event.key # if special char, add either char or other if shift is down
			if $keys_down.include? "left shift" or $keys_down.include? "right shift"
				@text += {"0"=>")", "1"=>"!", "2"=>"@", "3"=>"#", "4"=>"$", "5"=>"%", "6"=>"^", "7"=>"&", "8"=>"*", "9"=>"(", ","=>"<", "."=>">", "/"=>"?"}[event.key]
			else
				@text += event.key
			end
		elsif event.key == "backspace" and @text.length > 0
			@text = @text.delete_suffix! @text[-1] # delete suffix will delete end of string given that it is provided, and also that string is not empty
		elsif event.key == "space"
			@text += " "
		end
		@writing.remove
		@writing = Text.new @text, x: ($width/2)-188, y: ($height/2)-12, size: 20, color: $colors["note"], z: 10
	end
	def blink # blinking cursor
		@blinker.remove
		if Time.now.to_i%2 == 0
			@blinker = Line.new x1: ($width/2)-187+get_text_width(@text, 20), y1: ($height/2)-10, x2: ($width/2)-187+get_text_width(@text, 20), y2: ($height/2)+10, width: 2, color: $colors["note"], z: 10
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