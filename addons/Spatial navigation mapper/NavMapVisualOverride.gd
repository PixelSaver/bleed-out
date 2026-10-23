@tool
extends Resource
class_name NavMapVisualOverride

## Scaling value for all visualization
@export_range(1.0,10.0,0.01) var visuals_scaling_value : float = 1.0

## Controls overall opacity of all debug visuals
@export_range(0.0,100.0,0.1,"suffix:percent") var opacity : float = 100.0

## Color used for arrows of up-direction mapping
@export var up_color : Color = Color(0.89, 0.34, 0.18, 1.00)

## Color used for arrows of down-direction mapping
@export var down_color : Color = Color(0.00, 0.62, 1.00, 1.00)

## Color used for arrows of left-direction mapping
@export var left_color : Color = Color(0.67, 0.85, 0.36, 1.00)

## Color used for arrows of right-direction mapping
@export var right_color : Color = Color(0.73, 0.22, 0.60, 1.00)

## Color used for group container box visuals
@export var group_box_color : Color = Color(0.95, 1.0, 0.0, 0.298)

## Color used for arrows of up-direction group-to-group mapping
@export var group_up_color : Color = Color(1.0, 0.541, 0.0, 1.00)

## Color used for arrows of down-direction group-to-group mapping
@export var group_down_color : Color = Color(0.00, 0.30, 1.00, 1.00)

## Color used for arrows of left-direction group-to-group mapping
@export var group_left_color : Color = Color(0.39, 0.93, 0.59, 1.00)

## Color used for arrows of right-direction group-to-group mapping
@export var group_right_color : Color = Color(0.98, 0.13, 0.4, 1.00)

## Fontsize of group label
@export_range(1.0,100.0,1.0) var group_label_size : int = 12

## Controls padding of group container box
@export var group_box_padding : int = 6:
	set(value):
		value = clamp(value,-5,999)
		group_box_padding = value

## Texture used by group container box
@export var container_tex : Texture2D = load("res://addons/Spatial navigation mapper/ContainerBorder_box_ants.png")

## Patch margin of Nine-slice group box texture
@export_range(1.0,999.0,1.0) var group_box_patch_margin : int

## Texture used by mapping visualization arrows
@export var arrow_tex : Texture2D = load("res://addons/Spatial navigation mapper/arrow.png")
