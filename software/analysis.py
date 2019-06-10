import pygame
from pygame.locals import *
import math


def linspace(a, b, n):
	return [a + x/(n-1)*(b-a) for x in range(n)]

class Position():
	dist = 10	# distance between string attachments on wall
	#anchor1 = (-.25, .25)	# x,y of string anchor relative to COM
	#anchor2 = (.25, .25)
	anchor1 = (-.5, .5)	# x,y of string anchor relative to COM
	anchor2 = (.5, .5)
	anchor1 = (*anchor1, (anchor1[0]**2+anchor1[1]**2)**.5, math.atan2(anchor1[1], anchor1[0]))
	anchor2 = (*anchor2, (anchor2[0]**2+anchor2[1]**2)**.5, math.atan2(anchor2[1], anchor2[0]))
	weight = -1
	#x, y, r		# pencil position/rotation
	#t1, t2		# tension
	#l1, l2		# length of strings
	#r1, r2 		# angle of strings
	#rt1, rt2 	# torque
	def __init__(self, x, y, rotation=None):
		if rotation != None:
			self.x = x
			self.y = y
			self.r = rotation
			r = rotation
			anchor1, anchor2 = self.anchor1, self.anchor2
			dist, weight = self.dist, self.weight

			# get positions of anchor points
			x1 = x + anchor1[2]*math.cos(anchor1[3]+r)
			y1 = y + anchor1[2]*math.sin(anchor1[3]+r)
			x2 = x + anchor2[2]*math.cos(anchor2[3]+r)
			y2 = y + anchor2[2]*math.sin(anchor2[3]+r)

			# get lengths and angles of strings
			l1 = ((x1-0)**2 + (y1-0)**2)**.5
			l2 = ((x2-dist)**2 + (y2-0)**2)**.5
			r1 = math.atan2(y1-0, x1-0)
			r2 = math.atan2(y2-0, x2-dist)

			# get tension in strings
			# t1*cos(r1) + t2*cos(r2) = 0
			# t1*sin(r1) + t2*sin(r2) = -weight
			#t1 = (weight + t2*math.sin(r2) - t1*math.sin(r1)) / (math.cos(r1)-math.cos(r2))
			#t2 = -t1*cos(r1)/cos(r2)
			sr1, cr1, sr2, cr2 = math.sin(r1), math.cos(r1), math.sin(r2), math.cos(r2)
			t1 = -weight*cr2/( cr2*sr1 - cr1*sr2)
			t2 = -weight*cr1/(-cr2*sr1 + cr1*sr2)
			assert(abs(t1*math.cos(r1) + t2*math.cos(r2)) < 1e-5)
			assert(abs(t1*math.sin(r1) + t2*math.sin(r2) + weight) < 1e-5)

			# get torque due to strings
			rt1 = math.sin(r+anchor1[3] - r1) * t1 * anchor1[2]
			rt2 = math.sin(r+anchor2[3] - r2) * t2 * anchor2[2]

			self.x, self.y = x, y 			# pencil position
			self.x1, self.y1 = x1, y1 		# string anchors
			self.x2, self.y2 = x2, y2 		# string anchors
			self.t1, self.t2 = t1, t2		# tension
			self.l1, self.l2 = l1, l2		# length of strings
			self.r1, self.r2 = r1, r2 		# angle of strings
			self.rt1, self.rt2 = rt1, rt2 	# torque
		
		else:
			# determine rotation ourselves
			candidates_r = linspace(-math.pi/2, math.pi/2, 1001)
			candidates_P = [Position(x, y, r) for r in candidates_r]
			results = [(P, P.get_torque()) for P in candidates_P]
			_, best_P, best_t = min((abs(result[1]), *result) for result in results)
			
			self.x, self.y, self.r = best_P.x, best_P.y, best_P.r			# pencil position
			self.x1, self.y1 = best_P.x1, best_P.y1 		# string anchors
			self.x2, self.y2 = best_P.x2, best_P.y2 		# string anchors
			self.t1, self.t2 = best_P.t1, best_P.t2		# tension
			self.l1, self.l2 = best_P.l1, best_P.l2		# length of strings
			self.r1, self.r2 = best_P.r1, best_P.r2 		# angle of strings
			self.rt1, self.rt2 = best_P.rt1, best_P.rt2 	# torque

	def get_torque(self):
		return self.rt1 + self.rt2

	def draw(self, screen):
		vs = [(self.x, self.y), (self.x1, self.y1), (self.x2, self.y2)]
		w,h = screen.get_width(), screen.get_height()
		scale = lambda x,y: (x/10*w, -y/10*h)
		vs_scaled = [scale(*v) for v in vs]
		pygame.draw.aalines(screen, (0, 0, 255), True, vs_scaled)

	def print(self):
		#print(self.x, self.y)
		#print(self.l1, self.l2)
		#print(self.t1, self.t2)
		#print(self.r1, self.t2)
		print('x=%.2f\ty=%.2f\tr=%.2f\tt=%.2f'%(self.x, self.y, self.r, self.get_torque()))


def quick_transform(info, x, y):
	# if our image is (0-dx, 0-dy) with 0,0 in the upper left, 
	# cables are at left[0],left[1], and right is at right[0],right[1]

	dx, dy, left, right = info

	xpos = x*dx
	ypos = y*dy

	lengthl = math.sqrt((xpos-left[0])**2 + (ypos-left[1])**2)
	lengthr = math.sqrt((xpos-right[0])**2 + (ypos-right[1])**2)
	return lengthr, lengthl


if __name__ == '__main__':

	test = Position(5, -3, 0)
	test.print()

	test2 = Position(3, -3, 0)
	test2.print()

	test3 = Position(3, -3)
	test3.print()




	w, h = 640*2, 480*2
	pygame.init()
	screen = pygame.display.set_mode((w, h))
	screen.fill((255, 255, 255))


	for x in linspace(.25, 9.75, 10):
		for y in linspace(0, -9.75, 10):
			pos = Position(x, y)
			pos.draw(screen)


	#pygame.draw.aaline(screen, (0, 255, 0), (0, 0), (50, 100))


	pygame.display.flip()
	running = True
	while running:
		for event in pygame.event.get():
			if event.type in (QUIT, KEYDOWN):
				running = False

