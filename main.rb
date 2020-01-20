# TODO
# mandachord import
# echo lure import
# move shawzin notes left or right in editing
# connecting echo lure noises
# scrolling
# time display on top_bar
# note/time limits on mandachord/shawzin
# options
# way to signify that can't add notes to instruments while playing

require "ruby2d"
require "clipboard"

$containers = []
$file_version = 1 # change if the way songs are stored is modified in the future
$saved = true
$keys_down = []
$colors = {"background"=>"#14121D", "string"=>"#BBA664", "button_selected"=>"#F2E1AD", "button_deselected"=>"#BDA76C", "note"=>"#EEEEEE", "percussion"=>"#5A5A5A", "bass"=>"#2B5B72", "melody"=>"#6A306F"}
$all_buttons = []
$file_name = ""
$fps = Text.new get(:fps).round(2), x: 0, y: 0, size: 15, color: "white", z: 20

$width = 1440
$height = 900
set background: $colors["background"], width: $width, height: $height, fullscreen: true

load "base_classes.rb"
load "top_bar.rb"
load "shawzin.rb"
load "mandachord.rb"
load "echo_lure.rb"
load "add.rb"
load "pop_up.rb"

# playing
$playing = false # set to true to move bar and play song

def play_all
	$playing_highest = 0
	$containers.each do |c| # go through every container to find out how long the song is
		h = c.get_last_sound
		if h > $playing_highest
			$playing_highest = h+5
		end
	end
	if $playing_highest > 5
		$playing = true
		$playing_counter = 50
		$playing_previous = 47
		if $playing_bar.nil?
			$playing_bar = Line.new x1: 50, y1: $containers[0].container.height, x2: 50, y2: $height, color: $colors["note"], width: 3, z: 8
		end
	end
end
def pause_all
	$playing = false
end

update do
	$fps.remove
	$fps = Text.new get(:fps).round(2), x: 0, y: 0, size: 15, color: "white", z: 20
	if $alert.respond_to? "blink"
		$alert.blink
	end
	if $playing
		$playing_previous = $playing_counter.floor
		$playing_counter += (1340.0/480.0).round 3
		$playing_bar.remove
		$playing_bar = Line.new x1: $playing_counter, y1: $containers[0].container.height, x2: $playing_counter, y2: $height, color: $colors["note"], width: 3, z: 8
		($playing_counter.floor-$playing_previous).times do |t|
			$containers.each do |c|
				c.play $playing_previous+t
			end
		end
		if $playing_counter > $playing_highest
			$playing = false
			$containers[0].buttons[0].image_url = "resources/images/play_icon.png"
			$containers[0].buttons[0].draw
		end
	end
end

# inputs
on :mouse_up do |event|
	$mouse_down = false
	if event.button == :left
		$all_buttons.each do |b|
			if !b.hidden
				b.mouse_up
			end
		end
	end
	if $alert.nil?
		case event.button
		when :left
			if !$open_dropdown.nil?
				if $open_dropdown.click event
					dont = true # used to signify that click was handled on dropdown
				end
			end
			if dont.nil?
				if !$export_window.nil?
					$export_window.click event
				else
					$containers.each do |c|
						if c.container.contains? event.x, event.y
							c.click event
						end
					end
				end
			end
		when :right
			$containers.select{ |c| c.class.name == "Shawzin_UI" || c.class.name == "Lure_UI" }.each do |c|
				c.right_click event
			end
		when :middle
			# not used right now, but save this for later
		end
	else
		$alert.click event
	end
end
on :mouse_down do |event|
	$mouse_down = true
	if $alert.nil?
		case event.button
		when :left
			$containers.each do |c|
				if c.container.contains? event.x, event.y
					c.mouse_down event
				end
			end
		when :right
			# not used right now, but save this for later
		when :middle
			# not used right now, but save this for later
		end
	else
		$alert.mouse_down event
	end
end
on :mouse_move do |event|
	if $mouse_down and $alert.nil?
		$containers.filter{ |c| c.class.name == "Lure_UI" }.each do |c|
			c.mouse_move event
		end
	end
end
on :key_down do |event|
	$keys_down.push event.key
	if $alert.respond_to? "key_down"
		$alert.key_down event
	elsif $keys_down.any?{ |k| k == "left command" } or $keys_down.any?{ |k| k == "right command" }
		if ($keys_down.any?{ |k| k == "left shift" } or $keys_down.any?{ |k| k == "right shift" }) and $keys_down.any?{ |k| k == "s" } # cmd + shift + s = save as
			Popup_Ask.new "File Name", Proc.new{ |t| save_as t }
		elsif $keys_down.any?{ |k| k == "s" } # cmd + s = save
			save
		elsif $keys_down.any?{ |k| k == "n" } # cmd + n = new
			new_file false
		elsif $keys_down.any?{ |k| k == "o" } # cmd + o = open
			open_file 1
		end
	end
end
on :key_up do |event|
	$keys_down.delete_at $keys_down.find_index event.key
end

# save/load
def save_as t
	if File.exist? "saves/#{t}.txt"
		Popup_Confirm.new "The file #{t}.txt already exists. Would you like to overwrite it?", Proc.new{
			$file_name = "#{t}.txt"
			save
		}, Proc.new{ Popup_Info.new "File not saved." }
	else
		$file_name = "#{t}.txt"
		save
	end
end
def save
	if $file_name == ""
		$file_name = Popup_Ask.new "File Name", Proc.new{ |t| save_as t }
	else
		File.open "saves/#{$file_name}", "w" do |file|
			file.syswrite "d v:#{$file_version}\n" # save file version is 1
			$containers.filter{ |c| c.class.name == "Shawzin_UI" or c.class.name == "Mandachord_UI" or c.class.name == "Lure_UI" }.each do |c|
				file.syswrite "#{c.class.name.downcase[0]} #{c.export}\n"
			end
		end
	end
	$saved = true
end
def new_file a # if a == true then redirect back to open() phase 2
	if $saved
		$containers.filter{ |c| c.class.name == "Shawzin_UI" or c.class.name == "Mandachord_UI" or c.class.name == "Lure_UI" }.each do |c|
			c.remove
		end
		$file_name = ""
		if a
			open_file 2
		end
	else
		Popup_Confirm.new "Your current work is unsaved. Are you sure you want to go to a new file?", Proc.new{
			$saved = true
			new_file a
		}, Proc.new{}
	end
end
def open_file a # a defines what phase of the process you are on
	$containers[-1].remove
	if a == 1
		new_file true
	elsif a == 2
		Popup_File.new Proc.new{ |f|
			$file_name = f
			open_file 3
		}
	elsif a == 3
		File.open "saves/#{$file_name}", "r" do |file|
			# begin # ruby equivalent of try
				file.read.split(/\n/).each do |r|
					case r[0] # first letter of r signifies type of data
					when "d"
						if r[-1].to_i < $file_version
							Popup_Info.new "This file has been made for a newer version of this program. Please update to the latest version in order to use it."
							break
						elsif r[-1].to_i > $file_version # in the future, this will be changed to update the file to the current version
							Popup_Info.new "This file has been made for an older version of this program. That shouldn't happen, as this is the first version of the program. The file may be bugged."
							break
						end
					when "s"
						r.slice! 0..1
						ui = Shawzin_UI.new
						if ui.import r # returns true if error occurred
							break
						end
					when "m"
						r.slice! 0..1
						ui = Mandachord_UI.new
						if ui.import r # returns true if error occurred
							break
						end
					when "l"
						r.slice! 0..1
						ui = Lure_UI.new
						if ui.import r # returns true if error occurred
							break
						end
					else
						Popup_Info.new "Error in line #{file.read.find_index r} of file: Type of data not known."
						break
					end
				end
			# rescue => err # ruby equivalent of catch
			# 	$saved = true
			# 	new_file false
			# 	Popup_Info.new "An error has occured in reading the file:\n#{err}"
			# end
		end
		Add_UI.new
	end
end

show # show the window