#class_name Card
#extends MarginContainer
#
#@onready var card_background: Panel = %CardBackgroundPanel
#@onready var strength_label: Label = %StrengthLabel
#@onready var name_label: Label = %NameLabel
#@onready var info_label: Label = %InfoLabel
#@onready var icons_container: HBoxContainer = %IconsContainer
#
#const ATLAS_PATH := "res://assets/sprites/cards/atlas_card_combat_icons.png"
#const ICON_SIZE := Vector2(64, 64)
#const SWORD_ORIGIN := Vector2(0, 0)
#const FORT_ORIGIN := Vector2(64, 0)
#const ICON_DISPLAY := Vector2(56, 56)
#
#const CARD_ART_BASE := "res://assets/sprites/cards/"
#const CARD_ART_NONE := "res://assets/sprites/cards/card_none.png"
#
#
#func setup(card: HouseCard) -> void:
	#strength_label.text = str(card.combat_strength)
	#name_label.text = str(card.id).replace("_", " ").capitalize()
	#_set_art(card.house, card.id)
	#_set_info(card)
#
#
#func _set_art(house: String, card_id: StringName) -> void:
	#var path := "%s%s/%s.png" % [CARD_ART_BASE, house.to_lower(), str(card_id)]
	#if not ResourceLoader.exists(path):
		#path = CARD_ART_NONE
	#
	#var texture: Texture2D = load(path)
	#var style := StyleBoxTexture.new()
	#style.texture = texture
	#card_background.add_theme_stylebox_override("panel", style)
#
#
#func _set_info(card: HouseCard) -> void:
	#var has_ability := card.ability_text != ""
	#var has_icons   := card.sword_icons > 0 or card.fortification_icons > 0
	#
	#if has_ability:
		#info_label.visible      = true
		#icons_container.visible = false
		#info_label.text         = card.ability_text
	#elif has_icons:
		#info_label.visible      = false
		#icons_container.visible = true
		#_populate_icons(card.sword_icons, card.fortification_icons)
	#else:
		#info_label.visible      = false
		#icons_container.visible = false
#
#
#func _populate_icons(sword_count: int, fort_count: int) -> void:
	#for child in icons_container.get_children():
		#child.queue_free()
	#
	#var atlas: Texture2D = load(ATLAS_PATH)
	#
	#for _i in sword_count:
		#icons_container.add_child(_make_icon(atlas, SWORD_ORIGIN))
	#for _i in fort_count:
		#icons_container.add_child(_make_icon(atlas, FORT_ORIGIN))
#
#
#func _make_icon(atlas: Texture2D, origin: Vector2) -> TextureRect:
	#var region        := AtlasTexture.new()
	#region.atlas      = atlas
	#region.region     = Rect2(origin, ICON_SIZE)
#
	#var tr                     := TextureRect.new()
	#tr.texture                 = region
	#tr.custom_minimum_size     = ICON_DISPLAY
	#tr.expand_mode             = TextureRect.EXPAND_IGNORE_SIZE
	#tr.stretch_mode            = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	#return tr
