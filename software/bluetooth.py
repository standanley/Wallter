import serial
import time


def start():
	ser = serial.Serial('COM10', baudrate=9600, timeout=.5, parity=serial.PARITY_NONE)  # open serial port
	print(ser.name)         # check which port was really used
	
	time.sleep(5)
	# once to get through setup
	ser.write(b'#')
	ser.flush()

	#ser.write(b'#')

	print('wrote #, waiting')
	
	# once to acknowledge
	response = wait_for_response(ser)
	if response.decode('utf-8') != '@':
		print('unexpected response, ', response)
		return None
	else:
		print('Successfully connected to bluetooth')

	# start the drawing
	ser.write(b'S')
	return ser

def wait_for_response(ser):
	count = 0
	while not ser.in_waiting:
		count += 1
		#print('waiting')
		time.sleep(0.01)
		if count == 1000:
			#break
			pass
	#time.sleep(1)
	response = ser.read()
	#print('response', response)
	return response

def stop(ser):
	ser.write(b'T')

def pen_up(ser):
	ser.write(b'A')
	response = wait_for_response(ser)
	if response.decode('utf-8') != 'A':
		print('Issue putting pen up')

def pen_down(ser):
	ser.write(b'Z')
	response = wait_for_response(ser)
	if response.decode('utf-8') != 'Z':
		print('Issue putting pen down')

def next_color(ser):
	ser.write(b'C')
	response = wait_for_response(ser)
	if response.decode('utf-8') != 'C':
		print('Issue putting pen down')

def write_float(ser, x):
	int1 = str(int(x*10000))+'.'
	ser.write(int1.encode('utf-8'))
	print('Just sent float', x, ', waiting for response')
	response = wait_for_response(ser)
	print('got response, ', response.decode('utf-8'))
	#response = response.decode('utf-8')
	#print('a', response)
	#response = response[-3:-1]
	#print('b', response)
	#response = int(response)
	#print(response)
	#if response != len(int1)-1:
	#	print('WARNING: sent', int1, 'but it says', response, 'bytes were read')
	#	return False
	#else:
	#	#print('good response')
	#	pass
	return True

def goto(ser, pos):
	ser.write(b'L')
	success = True
	success &= write_float(ser, pos[0])
	success &= write_float(ser, pos[1])
	if not success:
		print('Issue sending coordinate', pos)

	response = wait_for_response(ser)
	if response.decode('utf-8') != 'L':
		print('unexpected response, ', response)
	else:
		print('Wallter made it to ', pos)

