class Top_UI < UI_Element
	attr_accessor :buttons
	def draw
		@delete_button.remove # don't delete the top bar
		@buttons = []
		@buttons.push Quad_Button.new "Play", @buttons.length*90+50, @y+10, "resources/images/play_icon.png", Proc.new{
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
		@buttons.push Quad_Button.new "Export", @buttons.length*90+50, @y+10, "resources/images/clear.png", Proc.new{ $export_window = Export_Window.new }
	end
	def click event
		@buttons.each do |b|
			b.click event
		end
	end
	def mouse_down event
		@buttons.each do |b|
			b.mouse_down event
		end
	end
	def reposition # redefining because it never moves
	end
end

Top_UI.new