$options = {
	"ui_theme"=>"Vitruvian",
	"sky_fret_key"=>"a",
	"sky_fret_toggle"=>"false",
	"earth_fret_key"=>"d",
	"earth_fret_toggle"=>"false",
	"water_fret_key"=>"s",
	"water_fret_toggle"=>"false",
	"developer_mode"=>"false"
}
$ui_themes = {
	"Vitruvian"=>{"background"=>"#14121D", "string"=>"#BBA664", "button_selected"=>"#F2E1AD", "button_deselected"=>"#BDA76C", "note"=>"#EEEEEE", "percussion"=>"#5A5A5A", "bass"=>"#2B5B72", "melody"=>"#6A306F"}
}

class Options_Window
	attr_accessor :hidden
	def initialize
		@hidden = true
		if File.exist? "options.txt"
			File.open "options.txt", "r" do |file|
				file.read.split(/\n/).each do |r|
					if r.length != 0 # don't read the final newline
						$options[r.split("=>")[0]] = r.split("=>")[1]
					end
				end
			end
		end
		$colors = $ui_themes[$options["ui_theme"]]
		save_options # applies options
	end
	def draw
		@hidden = false
		@background = Rectangle.new x: 0, y: 0, width: $width, height: $height, color: [0, 0, 0, 0.8], z: 10
		@outline = Rectangle.new x: 149, y: 49, width: $width-298, height: $height-98, color: $colors["string"], z: 10
		@container = Rectangle.new x: 150, y: 50, width: $width-300, height: $height-100, color: $colors["background"], z: 10
		@text = []
		@elements = []
		@text.push Text.new "Options", x: ($width/2)-(get_text_width("Options", 40)/2), y: 60, size: 40, color: $colors["string"], z: 10
		@elements.push Delete_Button.new $width-175, 60, self
		@text.push Text.new "Display", x: 160, y: 100, size: 30, color: $colors["string"], z: 10
		@text.push Text.new "UI Theme", x: 160, y: 140, size: 20, color: $colors["string"], z: 10
		@elements.push Dropdown.new 170+get_text_width("UI Theme", 20), 140, $ui_themes.keys, $options["ui_theme"], Proc.new{ |t|
			$options["ui_theme"] = t
			save_options
			Popup_Info.new "Display settings will be applied after a program restart."
		}
		@text.push Text.new "Shawzin", x: 160, y: 180, size: 30, color: $colors["string"], z: 10
		@text.push Text.new "Sky Fret", x: 160, y: 220, size: 25, color: $colors["string"], z: 10
		@text.push Text.new "Key:", x: 160+get_text_width("Sky Fret  ", 25), y: 222, size: 20, color: $colors["string"], z: 10
		@elements.push Key_Button.new 160+get_text_width("Sky Fret  ", 25)+get_text_width("Key:  ", 20), 223, $options["sky_fret_key"], Proc.new{ |k|
			$options["sky_fret_key"] = k
			save_options
		}
		@text.push Text.new "Earth Fret", x: 160, y: 250, size: 25, color: $colors["string"], z: 10
		@text.push Text.new "Key:", x: 160+get_text_width("Earth Fret  ", 25), y: 252, size: 20, color: $colors["string"], z: 10
		@elements.push Key_Button.new 160+get_text_width("Earth Fret  ", 25)+get_text_width("Key:  ", 20), 253, $options["earth_fret_key"], Proc.new{ |k|
			$options["earth_fret_key"] = k
			save_options
		}
		@text.push Text.new "Water Fret", x: 160, y: 280, size: 25, color: $colors["string"], z: 10
		@text.push Text.new "Key:", x: 160+get_text_width("Water Fret  ", 25), y: 282, size: 20, color: $colors["string"], z: 10
		@elements.push Key_Button.new 160+get_text_width("Water Fret  ", 25)+get_text_width("Key:  ", 20), 283, $options["water_fret_key"], Proc.new{ |k|
			$options["water_fret_key"] = k
			save_options
		}
		@text.push Text.new "Developer Mode:", x: 160, y: 400, size: 20, color: $colors["string"], z: 10
		@elements.push Dropdown.new 160+get_text_width("Developer Mode: ", 20), 403, ["Enabled", "Disabled"], {"true"=>"Enabled", "false"=>"Disabled"}[$options["developer_mode"]], Proc.new{ |m|
			$options["developer_mode"] = {"Enabled"=>"true", "Disabled"=>"false"}[m]
			save_options
			if $options["developer_mode"] == "false"
				$stdout = File.new("log.txt", "w")
				$stdout.sync = true
				$stderr.reopen($stdout)
			else
				$stdout = $stdout_old
				$stdout.sync = true
				$stderr.reopen($stdout)
			end
		}
		@elements.each do |e|
			e.z = 10
		end
	end
	def click event
		@elements.each do |e|
			e.click event
		end
	end
	def mouse_down event
		@elements.each do |e|
			e.mouse_down event
		end
	end
	def remove # actually just hides, but this works better for the delete button
		@hidden = true
		@background.remove
		@outline.remove
		@container.remove
		@text.each do |t|
			t.remove
		end
		@elements.each do |e|
			e.remove
		end
	end
	def save_options
		File.open "options.txt", "w" do |file|
			$options.each do |key, value|
				file.syswrite "#{key}=>#{value}\n"
			end
		end
	end
end
$options_window = Options_Window.new