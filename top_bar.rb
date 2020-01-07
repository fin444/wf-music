class Top_UI < UI_Element
	attr_accessor :buttons, :editing, :editing_buttons
	def draw
		@delete_button.remove # don't delete the top bar
		@buttons = []
		@buttons.push Quad_Button.new "Play", 50, @y+10, "resources/images/play_icon.png", Proc.new{
			if $playing
				pause_all
				$containers[0].buttons[0].image_url = "resources/images/play_icon.png"
				$containers[0].buttons[0].draw
			else
				play_all
				$containers[0].buttons[0].image_url = "resources/images/pause_icon.png"
				$containers[0].buttons[0].draw
			end
		}
		# buttons for editing shawzin, will hide until needed
		@editing = false
		@note = nil
		@editing_buttons = []
		@editing_buttons.push Toggle_Quad_Button.new "Sky Fret", 50, @y+10, "resources/images/left_arrow.png", false
		@editing_buttons.push Toggle_Quad_Button.new "Earth Fret", 140, @y+10, "resources/images/down_arrow.png", false
		@editing_buttons.push Toggle_Quad_Button.new "Water Fret", 230, @y+10, "resources/images/right_arrow.png", false
		@editing_buttons.push Quad_Button.new "Delete", 320, @y+10, "resources/images/clear.png", Proc.new{ } # Proc filled in later
		@editing_buttons.push Quad_Button.new "Stop Editing", 410, @y+10, "resources/images/clear.png", Proc.new{ } # Proc filled in later
		@editing_buttons.each do |b|
			b.hide
		end
	end
	def click event
		if @editing # two sets of buttons, has to determine which ones to click
			@editing_buttons.each do |b|
				a = b.click event
				if [true, false].include? a # check if boolean
					@note.options[@editing_buttons.find_index b] = a
					@note.draw
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
	def reposition # redefining because it never moves
	end
end

Top_UI.new