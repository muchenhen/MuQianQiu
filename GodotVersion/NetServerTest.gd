extends Node

var peer = StreamPeerTCP.new()
var host = "39.98.42.26"  # 替换为您的服务器 IP
var port = 8888  # 替换为您的服务器端口
var connected = false
var connecting = false
var connection_timeout = 10.0  # 连接超时时间（秒）
var connection_timer = 0.0
var last_status = -1

func _ready():
	pass
	print("Attempting to connect to %s:%d" % [host, port])
	connect_to_server()

func _process(delta):
	pass
	connection_timer += delta
	
	if connection_timer >= 0.5:  # 每0.5秒检查一次状态
		connection_timer = 0.0
		peer.poll()
		var status = peer.get_status()
		
		if status != last_status:
			print("Connection status changed to: ", status)
			last_status = status
		
		match status:
			StreamPeerTCP.STATUS_NONE:
				if connected:
					print("Disconnected from server.")
					connected = false
			StreamPeerTCP.STATUS_CONNECTING:
				if connection_timer > connection_timeout:
					print("Connection attempt timed out")
					connecting = false
					peer.disconnect_from_host()
			StreamPeerTCP.STATUS_CONNECTED:
				if not connected:
					print("Connected to server.")
					connected = true
					connecting = false
					peer.set_no_delay(true)  # 禁用 Nagle 算法
					await get_tree().create_timer(1.0).timeout  # 等待1秒再发送初始消息
					send_message("Hello, Server!")
			StreamPeerTCP.STATUS_ERROR:
				print("Error in connection")
				connected = false
				connecting = false

func connect_to_server():
	var error = peer.connect_to_host(host, port)
	if error != OK:
		print("Failed to initiate connection. Error code: ", error)
	else:
		connecting = true
		connection_timer = 0.0

func check_for_data(max_attempts := 5, delay := 0.2):
	for attempt in range(max_attempts):
		var bytes_available = peer.get_available_bytes()
		if bytes_available > 0:
			var data = peer.get_partial_data(bytes_available)
			if data[0] == OK:
				var received = data[1].get_string_from_utf8()
				if received.strip_edges() != "":
					print("Received: '" + received.strip_edges() + "'")
					return
				else:
					print("Received empty or whitespace-only response")
			else:
				print("Error reading data")
		else:
			print("No data available, attempt %d of %d" % [attempt + 1, max_attempts])
		
		if attempt < max_attempts - 1:
			await get_tree().create_timer(delay).timeout
	
	print("No valid data received after %d attempts" % max_attempts)

func send_message(message: String):
	if connected:
		print("Sending: '" + message + "'")
		peer.put_data((message + "\n").to_utf8_buffer())
		await get_tree().create_timer(0.5).timeout  # 等待更长时间
		await check_for_data()
	else:
		print("Not connected. Can't send message.")

# func _input(event):
	# if event is InputEventKey and event.pressed:
	# 	if event.keycode == KEY_SPACE:
	# 		send_message("Hello again!")
	# 	elif event.keycode == KEY_ESCAPE:
	# 		disconnect_from_server()

func disconnect_from_server():
	if connected or connecting:
		peer.disconnect_from_host()
		print("Disconnecting from server.")
		connected = false
		connecting = false

func _exit_tree():
	disconnect_from_server()
