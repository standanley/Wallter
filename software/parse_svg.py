import re


def parse(text):
	data = re.split('[, \n"]+', text)

	STATE = 'looking'
	pos = [0, 0]

	paths = []
	colors = []
	parse.i = 0
	parse.token = None
	parse.style = None

	def adv():
		'''
		if parse.i == len(data):
			parse.token = 'DONE'
			print(STATE, parse.token)
			return
		'''
		parse.token = data[parse.i]
		parse.i += 1
		#print(parse.i, parse.token)
	def finish_path():
		#print(parse.current_path)
		if parse.current_path != []:
			paths.append(parse.current_path.copy())
			colors.append(current_color)
			parse.current_path = []

	while parse.i < len(data):
		#print('in state', STATE, parse.token)
		adv()
		if STATE == 'looking':
			if parse.token == '<path':
				#print('got something!')
				#print('starting path!')
				STATE = 'path_header'
				parse.current_path = []
				current_color = []

		elif STATE == 'path_header':
			#print('PH')
			if parse.token[:5] == 'style':
				adv()
				print('TODO: parse this: ', parse.token)
				current_color = parse.token
			elif parse.token[:2] == 'd=':
				STATE = 'path'
				first_in_path = True
			else:
				print('unknown header token', parse.token)
				crash

		elif STATE == 'path':
			#print('P')

			if parse.token=='m':
				finish_path()
				if first_in_path:
					adv()
					pos[0] = float(parse.token)
					adv()
					pos[1] = float(parse.token)
				else:
					adv()
					pos[0] += float(parse.token)
					adv()
					pos[1] += float(parse.token)
				parse.current_path.append(pos.copy())
				parse.style = 'l'
				first_in_path = False
				continue
			if parse.token=='M':
				finish_path()
				adv()
				pos[0] = float(parse.token)
				adv()
				pos[1] = float(parse.token)
				parse.current_path.append(pos.copy())
				parse.style = 'L'
				first_in_path = False
				continue
			elif parse.token == 'v':
				parse.style = 'v'
				adv()
			elif parse.token == 'V':
				parse.style = 'V'
				adv()
			elif parse.token == 'h':
				parse.style = 'h'
				adv()
			elif parse.token == 'H':
				parse.style = 'H'
				adv()
			elif parse.token == 'l':
				parse.style = 'l'
				adv()
			elif parse.token == 'L':
				parse.style = 'L'
				adv()
			elif parse.token == 'z' or parse.token == 'Z':
				parse.current_path.append(parse.current_path[0])
				finish_path()
				parse.style = None
			elif parse.token[:2] == 'id':
				finish_path()
				parse.style = None
				STATE = 'looking'

			#print('style', parse.style)

			if parse.style == 'v':
				#print('v')
				pos[1] += float(parse.token)
				parse.current_path.append(pos.copy())
			elif parse.style == 'V':
				#print('V')
				pos[1] = float(parse.token)
				parse.current_path.append(pos.copy())
			elif parse.style == 'h':
				#print('h')
				pos[0] += float(parse.token)
				parse.current_path.append(pos.copy())
			elif parse.style == 'H':
				#print('H')
				pos[0] = float(parse.token)
				parse.current_path.append(pos.copy())
			elif parse.style == 'l':
				#print('l')
				pos[0] += float(parse.token)
				adv()
				pos[1] += float(parse.token)
				parse.current_path.append(pos.copy())
			elif parse.style == 'L':
				#print('L')
				pos[0] = float(parse.token)
				adv()
				pos[1] = float(parse.token)
				parse.current_path.append(pos.copy())
			first_in_path = False

		elif state == 'DONE':
			if state == 'looking':
				return paths, colors
			else:
				print('unexpected end')
				crash
			'''
		else:
			print('unexpected state', state)
			creash
			'''

	all_points = [p for path in paths for p in path]
	xs, ys = zip(*all_points)
	print('min x', min(xs))
	print('min y', min(ys))
	print('max x', max(xs))
	print('max y', max(ys))

	ax = max(xs) - min(xs)
	bx = (max(xs) + min(xs))/2
	ay = max(ys) - min(ys)
	by = (max(ys) + min(ys))/2

	a = max(ax, bx)

	clean_paths = []
	for path in paths:
		print('Length of this path', len(path))
		clean_path = []
		for x,y in path:
			clean_path.append([(x-bx)/a+.5, (y-by)/a+.5])
		clean_paths.append(clean_path)
		print(clean_path)


	#print(clean_paths)
	return clean_paths, colors

if __name__ == '__main__':

	filename = 'tree.svg'
	with open(filename, 'r') as f:
		#data = [x for line in f for x in line.split()]
		text = f.read()



	paths, colors = parse(text)
	print('finished!')
	print(len(paths))
	print(len(colors))


	print(sum(len(x) for x in paths))
