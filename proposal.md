# Wallter

Daniel Stanley, Jake McKinnon, Michelle Wan

## Responsibilities

Everyone will contribute to:
- Mechanical construction (because none of us have much experience with that)
- Incremental redesign of whatever fails on Version 1 (because that's hard to plan for)
- Making art! (because that's the whole point!)

Daniel is in charge of:
- Choosing parts
- Electrical design
- Designing laser cut and/or 3D printed parts

Michelle is in charge of:
- svg -> paths  
- paths -> string lengths  

Jake is in charge of:
- What order to do paths (out->in to overcome friction)  
- string lengths -> motor steps  
- How to move data onto the arduino (we have 2-way text over bluetooth)  

Note that responsibilities may move around as we continue to develop the robot, and optimizing the robot once we've created the working version.

## What do you want to be able to make?
Vertical plotter capable of covering a fairly large space, switching between colors, pretty-good (as good as we can make it) precision, & ideally having quick set up time.

## What is innovative about this proposal?
There are many homemade wall bots online, but even ones with multiple colors seem fairly limited in the range of colors they allow.  Furthermore, they seem less precise than one might want (e.g. for transitioning a line from one color into another smoothly). The kickstarter robot Scribit could do up to 4 markers, but ours should be able to do more with fewer moving parts.

## What do you think will be the hardest part of the project?
Getting the right pressure of the pen on the wall and minimizing shutters/sways to achieve high precision (e.g. minimizing friction, correcting for predictable errors where possible (e.g. near edge of canvas lateral force by strings may be weak), and minimizing other sources of error, such as thread spooling on top of itself & changing the distance one "step" of rotation moves the drawing head)

## Milestones
1. Preliminary design for version 1
2. Order parts
3. Mechanical design
4. Test all electrical parts before assembly
5. Laser cut and/or 3D print parts
6. Mechanical assembly
7. Bare-bones drawing, as a proof of concept
8. Software that can do SVG -> drawing  
  a. SVG -> Paths  
  b. Intelligent ordering and direction of paths  
  c. Paths -> Cable lengths  
  d. Move cable lengths onto the Arduino over Bluetooth  
  e. Cable lengths -> Motor steps  
9. Are we happy with the precision? Maybe iterate on parts of design
10. Awesome art!

## Parts List
- Motors
  - Most likely 28BYJ-48 stepper motors because they are light and super cheap
- Motor controllers
  - Typically 28BYJ-48 motors come with a ULN2003 controller, so we'll probably use those
- Random wires for connecting motor and controllers
- Arduino
  - Caution: the ULN2003 controllers take 4 digital signals to drive, and Arduino Uno only has 12 digital outputs after serial communication. We either need a bigger Arduino or maybe we can use the stepper motor shield from the Tbot, modified for 6-wire steppers... 
- Battery
  - Probably a 7.4V rechargeable battery meant for an RC car or plane
  - Maybe we also want a long wired connection so we don't have to pause debugging every time the battery dies
- Bluetooth Arduino dongle HC-05 (<$10 on amazon)
  - Lets us send text wirelessly from python (or whatever) on a laptop to the Arduino
- Acrylic for laser cutter 
  - Robot body
  - Wheel of colors
- Screws for attaching motors?
- Thumb screws for pen holders
- Caster wheels
- Cord (fishing line? Thread?)
- Linear slide / rack & pinion / lead screw for pushing off of wall
  - We will ask for hep on this one
  
## References
- http://makerblock.com/2013/03/ideal-qualities-in-a-drawing-robot-pen-holder/
