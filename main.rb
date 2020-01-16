# TODO
# load files
# connecting echo lure noises
# scrolling
# time display on top_bar
# note/time limits on mandachord/shawzin
# options
# way to signify that can't add notes to instruments while playing

require "ruby2d"
require "clipboard"

$containers = []
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
			new_file
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
			$file_name = t
			save
		}, Proc.new{ Popup_Info.new "File not saved." }
	else
		$file_name = t
		save
	end
end
def save
	if $file_name == ""
		$file_name = Popup_Ask.new "File Name", Proc.new{ |t| save_as t }
	else
		File.open "saves/#{$file_name}.txt", "w" do |file|
			file.syswrite "d v:1\n" # save file version is 1
			$containers.filter{ |c| c.class.name == "Shawzin_UI" or c.class.name == "Mandachord_UI" or c.class.name == "Lure_UI" }.each do |c|
				file.syswrite "#{c.class.name.downcase[0]} #{c.export}\n"
			end
		end
	end
	$saved = true
end
def new_file
	if $saved
		$containers.filter{ |c| c.class.name == "Shawzin_UI" or c.class.name == "Mandachord_UI" or c.class.name == "Lure_UI" }.each do |c|
			c.remove
		end
		$file_name = ""
	else
		Popup_Confirm.new "Your current work is unsaved. Are you sure you want to go to a new file?", Proc.new{
			$saved = true
			new_file
		}, Proc.new{}
	end
end

show # show the window