from parse_svg import parse
from analysis import quick_transform
import bluetooth as bt


# TODO where does the robot start?

file = 'hex3.svg'
with open(file, 'r') as f:
	data = f.read()

paths, colors = parse(data)

print("number of paht" ,len(paths))

info = (500, 500, (-500, 1000), (1000, 1000))
transformed_paths = [[quick_transform(info, x, y) for x,y in path] for path in paths]


# send it!
ser = bt.start()
for path in transformed_paths:
	print("starting a new path")
	bt.goto(ser, path[0])
	bt.pen_down(ser)

	i = 1
	while i < len(path):
		bt.goto(ser, path[i])
		i += 1
	bt.pen_up(ser)

bt.stop(ser)