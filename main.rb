# TODO
# echo lures
# change scale/instrument/animal
# time scale display on top bar

require "ruby2d"
require "clipboard"

$containers = []
$colors = {"background"=>"#14121D", "string"=>"#BBA664", "button_selected"=>"#F2E1AD", "button_deselected"=>"#BDA76C", "note"=>"#EEEEEE", "percussion"=>"#5A5A5A", "bass"=>"#2B5B72", "melody"=>"#6A306F"}
$all_buttons = []

$width = 1440
$height = 900
set background: $colors["background"], width: $width, height: $height, fullscreen: true

def reposition_all # make all containers have proper y value after one is deleted
	$containers.each do |c|
		c.reposition
	end
	if !$playing_bar.nil?
		$playing_bar.remove
		$playing_bar = Line.new x1: $playing_counter, y1: $containers[0].container.height, x2: $playing_counter, y2: $height, color: $colors["note"], width: 3
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
load "export.rb"

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
	if $playing_highest != 5
		$playing = true
		$playing_counter = 50
		$playing_previous = 47
		if $playing_bar.nil?
			$playing_bar = Line.new x1: 50, y1: $containers[0].container.height, x2: 50, y2: $height, color: $colors["note"], width: 3
		end
	end
end
def pause_all
	$playing = false
end

update do
	if $playing
		$playing_previous = $playing_counter.floor
		$playing_counter += (1340.0/480.0).round 3
		$playing_bar.remove
		$playing_bar = Line.new x1: $playing_counter, y1: $containers[0].container.height, x2: $playing_counter, y2: $height, color: $colors["note"], width: 3
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
	$all_buttons.each do |b|
		b.mouse_up
	end
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
on :mouse_down do |event|
	if !$export_window.nil?
		$export_window.mouse_down event
	else
		$containers.each do |c|
			if c.container.contains? event.x, event.y
				c.mouse_down event
			end
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

show # show the window