mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto()

PATH = _ENV["!plugins_mod_folder_path"]
NAMESPACE = "kitty"

local eventHorizon = nil

Initialize(function()
	local sprite_small = Resources.sprite_load(NAMESPACE, "DifficultyEventHorizon", path.combine(PATH, "DiffEventHorizon.png"), 5, 11, 9)
	local sprite_large = Resources.sprite_load(NAMESPACE, "DifficultyEventHorizon2x", path.combine(PATH, "DiffEventHorizon2x.png"), 4, 25, 19)
	local sound_select = Resources.sfx_load("NAMESPACE", "EventHorizonSelect", path.combine(PATH, "select.ogg"))

	eventHorizon = Difficulty.new(NAMESPACE, "eventHorizon")
	eventHorizon:set_sprite(sprite_small, sprite_large)
	eventHorizon:set_primary_color(Color.from_rgb(200, 200, 200))
	eventHorizon.sound_id = sound_select

	eventHorizon:set_scaling(0.3, 4.0, 3.0) --`diff_scale`, `general_scale`, `point_scale`
	eventHorizon:set_monsoon_or_higher(true)
	eventHorizon:set_allow_blight_spawns(true)

	Callback.add("onGameStart", "EventHorizonStart", function(self, other, result, args)
		-- self is oDirectorControl
		if eventHorizon:is_active() then
			self.enemy_buff = self.enemy_buff + 1.5
			self.elite_spawn_chance = 0.8
		end
	end)

	Callback.add("onDirectorPopulateSpawnArrays", "EventHorizonPreLoopMonsters", function(self, other, result, args)
		if self.loops == 0 and eventHorizon:is_active() then
			-- add loop-exclusive spawns to before loop
			local director_spawn_array = Array.wrap(self.monster_spawn_array)
			local current_stage = Stage.wrap(GM._mod_game_getCurrentStage())

			local loop_spawns = List.wrap(current_stage.spawn_enemies_loop)

			for _, card_id in ipairs(loop_spawns) do
				director_spawn_array:push(card_id)
			end
		end
	end)
end,
true) -- post

gm.post_script_hook(gm.constants.recalculate_stats, function(self, other, result, args)
	if self.team == 2.0 and eventHorizon:is_active() then
		self.attack_speed = self.attack_speed * 1.15
		self.cdr = 1-((1-self.cdr)*0.85)
		self.pHmax_raw = self.pHmax_raw * 1.15
		self.pHmax = self.pHmax * 1.15
	end
end)

gm.post_script_hook(gm.constants.enemy_stats_init, function(self, other, result, args)
	if eventHorizon:is_active() then
		self.exp_worth = self.exp_worth * 0.7
	end
end)
