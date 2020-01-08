# TODO
# clicking through dropdown in echo lure
# one echo lure noise per column?
# saving and loading files
# echo lure noise connection
# scrolling
# time display on top_bar
# note/time limits on mandachord/shawzin
# options

require "ruby2d"
require "clipboard"

$containers = []
$colors = {"background"=>"#14121D", "string"=>"#BBA664", "button_selected"=>"#F2E1AD", "button_deselected"=>"#BDA76C", "note"=>"#EEEEEE", "percussion"=>"#5A5A5A", "bass"=>"#2B5B72", "melody"=>"#6A306F"}
$all_buttons = []
$file_name = ""
$fps = Text.new get(:fps).round(2), x: 0, y: 0, size: 15, color: "white"

$width = 1440
$height = 900
set background: $colors["background"], width: $width, height: $height, fullscreen: true

def reposition_all # make all containers have proper y value after one is deleted
	$containers.each do |c|
		c.reposition
	end
	if !$playing_bar.nil?
		$playing_bar.remove
		$playing_bar = Line.new x1: $playing_counter, y1: $containers[0].container.height, x2: $playing_counter, y2: $height, color: $colors["note"], width: 3, z: 8
	end
end
def determine_text_width text, size
	width_getter = Text.new text, x: 0, y: 0, size: size
	w = width_getter.width
	width_getter.remove
	w
end

load "base_classes.rb"
load "top_bar.rb"
load "shawzin.rb"
load "mandachord.rb"
load "echo_lure.rb"
load "add.rb"

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
	$fps = Text.new get(:fps).round(2), x: 0, y: 0, size: 15, color: "white"
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
	case event.button
	when :left
		$all_buttons.each do |b|
			if !b.hidden
				b.mouse_up
			end
		end
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
		$containers.select{ |c| c.class.name == "Shawzin_UI" or c.class.name == "Lure_UI" }.each do |c|
			c.right_click event
		end
	when :middle
		# not used right now, but save this for later
	end
end
on :mouse_down do |event|
	$mouse_down = true
	case event.button
	when :left
		if !$export_window.nil?
			$export_window.mouse_down event
		else
			$containers.each do |c|
				if c.container.contains? event.x, event.y
					c.mouse_down event
				end
			end
		end
	when :right
		# not used right now, but save this for later
	when :middle
		# not used right now, but save this for later
	end
end
on :mouse_move do |event|
	if $mouse_down
		$containers.filter{ |c| c.class.name == "Lure_UI" }.each do |c|
			c.mouse_move event
		end
	end
end
on :key_down do |event|
	case event.key
	when "a" # sky fret
		$shawzin_settings[0] = true
	when "s" # earth fret
		$shawzin_settings[1] = true
	when "d" # water fret
		$shawzin_settings[2] = true
	end
end
on :key_up do |event|
	case event.key
	when "a" # sky fret
		$shawzin_settings[0] = false
	when "s" # earth fret
		$shawzin_settings[1] = false
	when "d" # water fret
		$shawzin_settings[2] = false
	end
end

# save/load files
def save
	if $file_name == ""
		$file_name = "song.txt" # get a file name, this is just placeholder
	end
	File.open "saves/#{$file_name}", "w" do |file|
		$containers.filter{ |c| c.class.name == "Shawzin_UI" }.each do |c|
			file.syswrite "s #{c.export}\n"
		end
		$containers.filter{ |c| c.class.name == "Mandachord_UI" }.each do |c|
			file.syswrite "m #{c.export}\n"
		end
	end
end

show # show the window