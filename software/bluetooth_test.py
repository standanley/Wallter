import time
import serial
ser = serial.Serial('COM8', baudrate=9600, timeout=.5, parity=serial.PARITY_NONE)  # open serial port
print(ser.name)         # check which port was really used


start_time = time.time()
next_write = start_time + 2

while time.time() < start_time + 10:
	
	data = ser.read()
	print(data.decode("utf-8"), end='', flush=True)

	if time.time() > next_write:
		next_write += 5
		#string = b'12\n3.0\n4.0\n'
		string = b'12345 7 8 '
		ser.write(string)     # write a string
		print('writing', string.decode("utf-8") )
		'''
		string = b'3.0\n'
		ser.write(string)     # write a string
		print('writing', string.decode("utf-8") )
		string = b'4.0\n'
		ser.write(string)     # write a string
		print('writing', string.decode("utf-8") )
		'''

	time.sleep(.001)

ser.close()             # close port

