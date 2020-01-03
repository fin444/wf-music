$all_animals = ["Virmink", "Sawgaw", "Bolarola", "Horrasque", "Stover", "Kubrodon", "Kuaka", "Condroc", "Mergoo", "Vasca"]

class Lure_UI < UI_Element
	def draw
		@animal = $all_animals[0]
	end
	def click event
		@delete_button.click event
	end
	def mouse_down event
		@delete_button.mouse_down event
	end
	def play x
	end
	def get_last_sound
		0
	end
	def remove
		# TODO after finishing this code
		@delete_button.remove
		@name.remove
		$containers.delete_at $containers.find_index self
		reposition_all
	end
	def reposition_unique
		# TODO after finishing this code
	end
end