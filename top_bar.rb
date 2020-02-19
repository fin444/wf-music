class Top_UI
	attr_accessor :buttons, :editing, :editing_buttons, :y, :container
	def initialize
		@height = 125
		@y = 0
		@container = Rectangle.new x: 0, y: @y+$scrolled_y, width: $width, height: @height, color: $colors["background"], z: 6
		@buttons = []
		@buttons.push Quad_Button.new "Play", 50, @y+10, "resources/images/top_bar/play_icon.png", Proc.new{
			if $playing
				pause_all
			else
				play_all
			end
		}
		@buttons.push Quad_Button.new "Save", 140, @y+10, "resources/images/top_bar/save.png", Proc.new{ save }
		@buttons.push Quad_Button.new "New", 230, @y+10, "resources/images/top_bar/new.png", Proc.new{ new_file false }
		@buttons.push Quad_Button.new "Open", 320, @y+10, "resources/images/top_bar/open.png", Proc.new{ open_file 1 }
		@buttons.push Quad_Button.new "Options", 410, @y+10, "resources/images/gear.png", Proc.new { $options_window.draw }
		@buttons.each do |b|
			b.z = 6
		end
		# buttons for editing shawzin, will hide until needed
		@editing = false
		@note = nil
		@editing_buttons = []
		@editing_buttons.push Toggle_Quad_Button.new "Sky Fret", 50, @y+10, "resources/images/top_bar/left_arrow.png", false
		@editing_buttons.push Toggle_Quad_Button.new "Earth Fret", 140, @y+10, "resources/images/top_bar/down_arrow.png", false
		@editing_buttons.push Toggle_Quad_Button.new "Water Fret", 230, @y+10, "resources/images/top_bar/right_arrow.png", false
		@editing_buttons.push Quad_Button.new "Delete", 320, @y+10, "resources/images/top_bar/delete.png", Proc.new{ } # Proc filled in later
		@editing_buttons.push Quad_Button.new "Stop Editing", 410, @y+10, "resources/images/top_bar/close.png", Proc.new{ } # Proc filled in later
		@editing_buttons.each do |b|
			b.z = 6
			b.hide
		end
		# time marker
		@time_bottom_line = Line.new x1: 50, y1: @y+120, x2: $width-46, y2: @y+120, width: 1, color: $colors["string"], z: 6
		@time_markers = []
		@time_numbers = []
		33.times do |i|
			@time_markers.push Line.new x1: (i)*42+50, y1: @y+110, x2: (i)*42+50, y2: @y+120, width: 1, color: $colors["string"], z: 6
		end
		32.times do |i|
			@time_markers.push Line.new x1: (i)*42+71, y1: @y+114, x2: (i)*42+71, y2: @y+120, width: 1, color: $colors["string"], z: 6
		end
		9.times do |i|
			@time_numbers.push Text.new "#{(i+($scrolled_x/168))/60}:#{add_zeros (i+($scrolled_x/168))%60, 2}", x: (i)*168+50-(get_text_width("0:00", 12)/2), y: @y+95, size: 12, color: $colors["string"], z: 6
		end
		$scroll_list_x.push self
		$containers.push self
	end
	def click event
		if @editing # two sets of buttons, has to determine which ones to click
			@editing_buttons.each do |b|
				a = b.click event
				if [true, false].include? a # check if boolean
					@note.options[@editing_buttons.find_index b] = a
					@note.draw
					change
				end
			end
		else
			@buttons.each do |b|
				b.click event
			end
		end
	end
	def mouse_down event
		if @editing # two sets of buttons, has to determine which ones to click
			@editing_buttons.each do |b|
				b.mouse_down event
			end
		else
			@buttons.each do |b|
				b.mouse_down event
			end
		end
	end
	def edit note
		if @note == note
			@editing_buttons[4].action.call
			@note = nil
			return
		end
		@note = note
		if @editing # closes the old editing setup
			@editing_buttons[4].action.call
		end
		@editing = true
		@buttons.each do |b| # swaps the set of buttons
			b.hide
		end
		@editing_buttons.each do |b|
			b.draw
		end
		3.times do |t| # sets all of the fret buttons to what is in the note
			if @editing_buttons[t].action != @note.options[t]
				@editing_buttons[t].action = @note.options[t]
				if @note.options[t]
					@editing_buttons[t].color = $colors["button_selected"]
				else
					@editing_buttons[t].color = $colors["button_deselected"]
				end
				@editing_buttons[t].draw
			end
		end
		@editing_buttons[3].action = Proc.new{ # sets the action for the delete button
			@editing_buttons[4].action.call # close the editing section before removing
			@note.remove
			$containers.select{ |c| c.class.name == "Shawzin_UI" }.each do |c|
				if c.notes.any?{ |n| n == @note }
					c.notes_by_time[(@note.x/1000).to_s].delete_at c.notes.find_index @note
					c.notes.delete_at c.notes.find_index @note
				end
			end
		}
		@editing_buttons[4].action = Proc.new{ # closes editing
			@editing = false
			@editing_buttons.each do |b|
				b.hide
			end
			@buttons.each do |b|
				b.draw
			end
			@note.color = $colors["note"]
			@note.draw
		}
	end
	def reposition # empty to avoid errors
	end
	def scroll_x
		@time_markers.each do |t|
			t.remove
		end
		@time_numbers.each do |t|
			t.remove
		end
		@time_markers = []
		@time_numbers = []
		33.times do |i|
			if !(i*42+50-($scrolled_x%42) < 50) # prevents from rendering too far to left
				@time_markers.push Line.new x1: i*42+50-($scrolled_x%42), y1: @y+110, x2: i*42+50-($scrolled_x%42), y2: @y+120, width: 1, color: $colors["string"], z: 6
			end
		end
		32.times do |i|
			if !(i*42+71-($scrolled_x%42) < 50) # prevents from rendering too far to left
				@time_markers.push Line.new x1: (i)*42+71-($scrolled_x%42), y1: @y+114, x2: (i)*42+71-($scrolled_x%42), y2: @y+120, width: 1, color: $colors["string"], z: 6
			end
		end
		9.times do |i|
			if !(i*168+50-($scrolled_x%168) < 50) # prevents from rendering too far to left
				@time_numbers.push Text.new "#{(i+($scrolled_x/168))/60}:#{add_zeros (i+($scrolled_x/168))%60, 2}", x: i*168+50-(get_text_width("0:00", 12)/2)-($scrolled_x%168), y: @y+95, size: 12, color: $colors["string"], z: 6
			end
		end
	end
end

Top_UI.new