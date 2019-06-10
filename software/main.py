from parse_svg import parse
from analysis import quick_transform
import bluetooth as bt


# TODO where does the robot start?

file = 'art3.svg'
with open(file, 'r') as f:
	data = f.read()

paths, colors = parse(data)


#for c in colors:
#	print('c', c)
#exit()

cp = list(zip(colors, paths))
cp.sort()
colors, paths = zip(*cp)
for c in colors:
	print('color', c)
exit()

print("number of paths" ,len(paths))

#info = (250, 250, (-500, 1000), (750, 1000))
info = (100, 100, (-1143/2+50, 680), (1143/2+50, 680))
transformed_paths = [[quick_transform(info, x, y) for x,y in path] for path in paths]

# send it!
current_color = colors[0]
ser = bt.start()

#bt.pen_down(ser)
#bt.pen_up(ser)
#bt.next_color(ser)
#exit()


for color, path in zip(colors, transformed_paths):
	print("starting a new path")

	

	bt.goto(ser, path[0])
	if color != current_color:
			print('changing color')
			bt.next_color(ser)

	bt.pen_down(ser)

	i = 1
	while i < len(path):
		
		bt.goto(ser, path[i])
		i += 1

	bt.pen_up(ser)

bt.stop(ser)