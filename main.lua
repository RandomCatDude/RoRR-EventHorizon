mods["RoRRModdingToolkit-RoRR_Modding_Toolkit"].auto(true)

PATH = _ENV["!plugins_mod_folder_path"]
NAMESPACE = "kitty"

local eventHorizon = nil

Initialize(function()
	local sprite_small = Resources.sprite_load(NAMESPACE, "DifficultyEventHorizon", path.combine(PATH, "DiffEventHorizon.png"), 5, 11, 9)
	local sprite_large = Resources.sprite_load(NAMESPACE, "DifficultyEventHorizon2x", path.combine(PATH, "DiffEventHorizon2x.png"), 4, 25, 19)
	local sound_select = Resources.sfx_load("NAMESPACE", "EventHorizonSelect", path.combine(PATH, "UI_Diff_Horizon.ogg"))

	eventHorizon = Difficulty.new(NAMESPACE, "eventHorizon")
	eventHorizon:set_sprite(sprite_small, sprite_large)
	eventHorizon:set_primary_color(Color.from_rgb(200, 200, 200))
	eventHorizon.sound_id = sound_select

	eventHorizon:set_scaling(0.3, 4.0, 3.0) --`diff_scale`, `general_scale`, `point_scale`
	eventHorizon:set_monsoon_or_higher(true)
	eventHorizon:set_allow_blight_spawns(true)

	Callback.add(Callback.TYPE.onGameStart, "EventHorizonStart", function()
		if eventHorizon:is_active() then
			local director = GM._mod_game_getDirector()
			director.enemy_buff = director.enemy_buff + 1.5
			director.elite_spawn_chance = 0.8
		end
	end)

	Callback.add(Callback.TYPE.onDirectorPopulateSpawnArrays, "EventHorizonPreLoopMonsters", function()
		local director = GM._mod_game_getDirector()
		if director.loops == 0 and eventHorizon:is_active() then
			-- add loop-exclusive spawns to before loop
			local director_spawn_array = director.monster_spawn_array
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
		--self.cdr = 1-((1-self.cdr)*0.85) -- doesn't work lmao'
		self.pHmax_raw = self.pHmax_raw * 1.15
		self.pHmax = self.pHmax * 1.15

		local actor = Instance.wrap(self)
		local skills = {
			actor:get_active_skill(Skill.SLOT.primary),
			actor:get_active_skill(Skill.SLOT.secondary),
			actor:get_active_skill(Skill.SLOT.utility),
			actor:get_active_skill(Skill.SLOT.special),
		}
		for i, skill in ipairs(skills) do
			skill.cooldown = math.ceil(skill.cooldown * 0.85)
		end
	end
end)

gm.post_script_hook(gm.constants.enemy_stats_init, function(self, other, result, args)
	if eventHorizon:is_active() then
		self.exp_worth = self.exp_worth * 0.7
	end
end)
