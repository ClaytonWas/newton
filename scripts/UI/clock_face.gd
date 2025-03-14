extends Node2D

const MINUTE_HAND_LENGTH = 100

@onready var minute_hand: Line2D = $SecondHand
@onready var timer: Timer = %Timer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	minute_hand.points[1] = calculate_minute_hand_tip_location()

# Calculate the coordinates of the tip of the minute hand
func calculate_minute_hand_tip_location() -> Vector2:
	# Calculate angle based on elapsed time within a 60-second cycle
	var elapsed_time = 60 - timer.get_time_left()
	var angle = deg_to_rad(elapsed_time * 6.0)  # 360° / 60 seconds = 6° per second

	var x = -MINUTE_HAND_LENGTH * sin(angle)
	var y = -MINUTE_HAND_LENGTH * cos(angle)

	return Vector2(x, y)
