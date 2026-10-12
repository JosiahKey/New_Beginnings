extends Node
#next level to levelmanager
signal load_area_entered
#itemgenerator to inventorypanel
signal item_collected
#inventorypanel to equippanel
signal item_equipped
#equippanel/levelup to statpanel
signal update_stat_panel
#enemy to combat
signal hit_player
#enemy to combatui
signal combat_victory
#enemy_interactable to main
signal enemy_encountered
#enemy interactable to scene transition
signal combat_entered
#combat to scene transition
signal combat_exited
#enemy to combat
signal miss_player
#combat to levelup
signal levelup
#itemgen to combat
signal update_reward_item
#inventoryitem to equippanel
signal highlight_slot
#inventoryitem to equippanel
signal unhighlight_slot
#chest to main
signal reward
#levelup ui to combat(reward)
signal check_for_levelup
#combatant to combat_engine
signal turn_start
#combatant to combat_engine
signal turn_finished
#enemy to combat_engine
signal enemy_selected
#combatplayer to combatui
signal player_hp_changed
#enemy_interactable to player
signal player_paused
#combatdata to combatui
signal num_enemies_changed
#levelup to combatreward
signal exp_finished
#combat_engine to equip_panel
signal player_died
#equip_panel to combat_engine
signal gameover_item_deleted
#chest to itemgenerator
signal reward_generated
#anywhere to world_map
signal world_map_entered
#action_button to combat ui
signal action_button_pressed
#action button to combat engine
signal player_action_selected

### REVIEW LATER: kept during cleanup, currently half-wired
#emitted by scene_transition when the fade into combat ends, but nothing listens for it yet
#planned: combat_engine._ready() could await this instead of its fixed 1.2s timer
#combatui to combatengine
signal scene_transition_finished
