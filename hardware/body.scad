use <wheel.scad>;
use <logo.scad>;

acrylic_thickness = 6.35;
margin = 5;
margin_cut = 2;
epsilon = .5;

min_width = 5;

pen_angle = 20;
wedge_width = 60;
wedge_length = 70;
wedge_raise = 20;
m5_radius = 5.1/2;
m3_radius = 3.3/2;

spacer_width = 20;
spacer_height = 50;
slide_width = 70;
top_height = 50;
extension = 100;

collar_length = 7;

wheel_radius = 93-8;
body_width = wheel_radius*2+min_width*4+20;
body_height = body_width;
slotx = acrylic_thickness+2*epsilon;
sloty = spacer_width-10+2*epsilon;
top_width = slide_width+4*margin+2*(slotx-2*epsilon);

front_offset = 40;



top_motor_offset = [22, 15];

wedge_height = wedge_length*tan(pen_angle);


module extrude(){
    linear_extrude(acrylic_thickness) children(0);
}

module wedge(){
    union(){
        polygon([[0,0],[wedge_length,0],[0,wedge_height]]);
        translate([0,-wedge_raise]) square([wedge_length, wedge_raise]);
    }
}

module extruded_wedge(){
    translate([0,wedge_length,0]) 
    rotate(-90,[0,1,0]) 
    rotate(-90,[0,0,1]) 
    extrude() wedge();
}

module ramp_top(){
    difference(){
        square([wedge_width, wedge_length/cos(pen_angle)]);
        y_val = wedge_length/cos(pen_angle)/2;
        translate([wedge_width/2, y_val]){
            rotate(180) motor_holes();
        }
        translate([wedge_width/2, y_val+5]){
            rotate(180) motor_holes();
        }
        translate([wedge_width/2, y_val-5]){
            rotate(180) motor_holes();
        }
        translate([wedge_width/2, y_val+10]){
            rotate(180) motor_holes();
        }
        translate([wedge_width/2, y_val-10]){
            rotate(180) motor_holes();
        }
    }
    
}

module ramp(){
    rotate(180) translate([-wedge_width/2, 0, wedge_raise]) {
        rotate(pen_angle, [1,0,0]) {
            extrude() ramp_top();
        }
        translate([acrylic_thickness,0,0]) extruded_wedge();
        translate([wedge_width,0,0]) extruded_wedge();
    }
}

function hole_pos(angle, extra=0) = 
    [body_width/2 + sin(angle)*(wheel_radius+m5_radius+min_width+extra),
     body_height/2 + cos(angle)*(wheel_radius*cos(pen_angle)+m5_radius+min_width+extra)];

module body(){
    union(){
        difference() {
            square([body_width,body_height]);
            //translate([90, 150]) circle(m5_radius);
            //translate([110, 150]) circle(m5_radius);
            
            translate([35, 20]) caster_holes();
            translate([body_width-35, 20]) caster_holes();
            
            translate([body_width/2, body_height/2]) difference(){
                scale([1, cos(pen_angle)]) circle(wheel_radius, $fn=100);
                square([wedge_width, wedge_length], center=true);
                translate([-body_width/2, -body_height]) square([body_width,body_height]);
            }
            translate([body_width/2, body_height/2]) difference(){
                translate([-wheel_radius, -20]) square([wheel_radius*2, 20]);
                translate([-wedge_width/2, -20]) square([wedge_width, 20]);
            }
            //translate([body_width/2, body_height/2-12]) circle(20);
            
            dx = top_motor_offset[0];
            dy = top_motor_offset[1];
            translate([dx, body_height-dy]) rotate() motor_holes(true);
            translate([body_width-dx, body_height-dy]) rotate() motor_holes(true);
            
            for (angle=[5:5:20] ){
                translate(hole_pos(angle)) circle(m5_radius, $fn = 24);
                translate(hole_pos(-angle)) circle(m5_radius, $fn = 24);
                translate(hole_pos(angle, 10)) circle(m5_radius, $fn = 24);
                translate(hole_pos(-angle, 10)) circle(m5_radius, $fn = 24);
            }
            
            
        
        
            
            translate([body_width/2 + 50, body_height-8]) circle(m5_radius, $fn = 24);
            translate([body_width/2 - 50, body_height-8]) circle(m5_radius, $fn = 24);
            translate([body_width/2 + 50, body_height-28]) circle(m5_radius, $fn = 24);
            translate([body_width/2 - 50, body_height-28]) circle(m5_radius, $fn = 24);
            
            
            translate([body_width/2 + 75, body_height-57]) circle(m5_radius, $fn = 24);
            translate([body_width/2 - 75, body_height-57]) circle(m5_radius, $fn = 24);
            
            dist = 0.5*25.4;
            translate([body_width/2 - 6*dist/2, 10]){
                for(j = [0:4]){
                    for(i=[0:6]){
                        translate([i*dist, j*dist]) circle(m3_radius, $fn = 24);
                    }
                }
            }
            translate([body_width/2 - 14*dist/2, 10]){
                for(j = [3:4]){
                    for(i=[0:14]){
                        translate([i*dist, j*dist]) circle(m3_radius, $fn = 24);
                    }
                }
            }
        
        }
            
        
        
        /*
        translate([body_width/2, body_height+top_height/2]){
            
            difference() {
                square([top_width, top_height], center=true);
                I_hole();
                circle(37/2);
                translate([37/2, 0]) circle(13);
                translate([-37/2, 0]) circle(13);
            }
        }
    */
        
        difference() {
            translate([0, -extension/2]) square([body_width, extension/2]);
            //translate([35, 20-extension]) caster_holes();
            //translate([body_width-35, 20-extension]) caster_holes();
            translate([35, 25-extension/2]) caster_holes();
            translate([body_width-35, 25-extension/2]) caster_holes();
            
            translate([body_width/2-35, -extension/2+5]) scale(.31) logo();
            
            dist = 0.5*25.4;
            translate([body_width/2 - 6*dist/2, 10-2*dist]){
                for(j = [0:2]){
                    for(i=[0:6]){
                        translate([i*dist, j*dist]) circle(m3_radius, $fn = 24);
                    }
                }
            }
        }
    }
}


module I_hole() {
    square([slide_width+2*epsilon, acrylic_thickness+2*epsilon], center=true);
                translate([slide_width/2+slotx/2+margin, 0]) square([slotx, sloty], center=true);
                translate([-slide_width/2-slotx/2-margin, 0]) square([slotx, sloty], center=true);
}

module assembly() {
    translate([-body_width/2, 0]) extrude() body();
    translate([0, body_height/2+wedge_length/2, acrylic_thickness]) ramp();
    
    translate([0, body_height/2, wedge_height/2+acrylic_thickness+wedge_raise]) {
        rotate(-pen_angle, [1,0,0]) motor();
    }
    
    translate([-body_width/2+35, 20, 10]) rotate([180, 1,0]) caster();
    translate([body_width/2-35, 20, 10]) rotate([180, 1,0]) caster();
    
    
    dx = top_motor_offset[0];
    dy = top_motor_offset[1];
    translate([-body_width/2+dx, body_height-dy, 15]) rotate() motor();
    translate([ body_width/2-dx, body_height-dy, 15]) rotate() motor();
    
    translate([-50, body_height-28, acrylic_thickness]) front();
    
    //test();
    
}

module test() {
    translate([0, body_height+top_height/2]){
        rotate(180, [1,0,0]) caster();
        rotate(90,[-1,0,0]) translate([0,0,-acrylic_thickness/2]) extrude() slide();
        translate([0, 0, spacer_height]) extrude() slide_top();
        
        translate([-slide_width/2-slotx/2-margin-acrylic_thickness/2, 0]) {
            rotate(90, [0,0,1]) rotate(90, [1,0,0]) extrude() spacer();
        }
        translate([slide_width/2+slotx/2+margin-acrylic_thickness/2, 0]) {
            rotate(90, [0,0,1]) rotate(90, [1,0,0]) extrude() spacer();
        }
        
        translate([-10, top_height/2+20, 30]) rotate(90) rotate(90, [1,0]) motor();
        
        translate([0, top_height/2+25, 30]) rotate(-90) rotate(90, [1,0]) extrude() arm();
    }
}
    
module slide_top() {
    difference(){
        square([top_width, spacer_width], center=true);
        I_hole();
        square([slide_width-10, acrylic_thickness+10], center=true);
    }
}

module slide() {
    difference() {
        translate([0, -70/2]) square([slide_width, 70], center=true);
        translate([0, -30]) square([30, 30], center=true);
    }
    
}

module arm() {
    translate([0, -2.5]) square([60, 10]);
}

module spacer() {
    translate([0, spacer_height/2+acrylic_thickness/2]) union() {
        square([spacer_width, spacer_height-acrylic_thickness], center=true);
        square([spacer_width-10, spacer_height+acrylic_thickness], center=true);
    }
}
    

module motor(){
    union(){
        translate([0, -8, -19]){
            cylinder(19, 14, 14, centered=true);
            translate([0,8,19]) cylinder(1.5, 4.5, 4.5, centered=true);
            translate([0,8,20.5]){
                difference(){
                    cylinder(8.5, 2.5, 2.5);
                    translate([1.5,-5,2.5]) cube([10,10,10]);
                    translate([-11.5,-5,2.5]) cube([10,10,10]);
                }
            }
            
            translate([0, 0, 18])linear_extrude(1){
                difference(){
                    union(){
                        square([35, 7], center=true);
                        translate([17.5,0]) circle(3.5, $fn=12);
                        translate([-17.5,0]) circle(3.5, $fn=12);
                    }
                    translate([17.5,0]) circle(2.1);
                    translate([-17.5,0]) circle(2.1);
                }
            }
        }
        
        translate([-14.5/2, -(8+17.5), -16.3]) cube([14.5, 10, 16.3]);
    }
}

module caster() {
    union(){
        cylinder(16, 27/2, 27/2);
        translate([0,0,12]) sphere(8);
        linear_extrude(0.8) difference(){
            union(){
                translate([ 19,0]) circle(8);
                translate([-19,0]) circle(8);
                square([38,16], center=true);
            }
            translate([ 19,0]) circle(2);
            translate([-19,0]) circle(2);
        }
            
    }
}
module caster_holes(cut=true){
    translate([-.75*25.4, 0]) circle(m3_radius, $fn=24);
    translate([ .75*25.4, 0]) circle(m3_radius, $fn=24);
    if(cut){
        circle(17);
    }
}
module motor_holes(nema=false){
    translate([-17.5, -8]) circle(m3_radius, $fn=24);
    translate([ 17.5, -8]) circle(m3_radius, $fn=24);
    //circle(8);
    translate([0,-8]) circle(15.5);
    translate([-14.5/2-2, -(8+17.5)-10]) square([14.5+4, 15]);
    
    if(nema){
        nema = 31/2;
        translate([0, -5]){
            translate([-nema,-nema]) circle(m3_radius, $fn=24);
            translate([-nema, nema]) circle(m3_radius, $fn=24);
            translate([ nema,-nema]) circle(m3_radius, $fn=24);
            translate([ nema, nema]) circle(m3_radius, $fn=24);
        }
    }
}

/*
module motor_top() {
    square([30, 20], center=true);
    
}
*/


module negative_front(){
    difference(){
        hull() children(0);
        children(0);
    }
}

module skeleton_front(){
    intersection(){
        union(){
            difference(){
                minkowski(){
                    union(){
                        negative_front() children(0);
                    }
                    circle(5);
                }
                negative_front() children(0);
            }
        }
        children(0);
    }
}

module front1(){
    difference(){
        union(){
            translate([-5, -5]) square([10,35]);
            translate([-5,25]) square([front_offset,20]);
            translate([front_offset-5,35]) square([acrylic_thickness,10]);
            
        }
        translate([0,  0]) circle(m5_radius, $fn=24);
        translate([0, 20]) circle(m5_radius, $fn=24);
    }
}

module front2(){
    union() {
        skeleton_front() difference(){
            square([60, 58]);
            translate([35, 10]) rotate(180) motor_holes();
            translate([35, 18]) rotate(180) motor_holes();
            translate([7-.2, acrylic_thickness-.2]) square([10+.4, acrylic_thickness+.4]);
        }difference(){
            square([30, 20]);
            translate([35, 10]) rotate(180) motor_holes();
            translate([35, 18]) rotate(180) motor_holes();
            translate([7-.2, acrylic_thickness-.2]) square([10+.4, acrylic_thickness+.4]);
        }
    }
}

module front3(adj) {
    difference(){
        square([20, 10], center=true);
        axle_hole(adj);
    }
}

module front4() {
    length = 30;
    difference(){
        union(){
            square([10, length]);
            translate([-50/2+10/2, length]) square([50, 10]);
        }
        translate([5, length+5]) caster_holes(false);
    }
}

module front(){
    extrude() front1();
    translate([front_offset-5, 28, -acrylic_thickness])rotate(90, [0,1,0]) rotate(90) extrude() front2();
    axle = [front_offset-5+acrylic_thickness+1, 28+35, 10-6];
    translate(axle) rotate(90, [0,1,0]) rotate(-90) motor();
    translate(axle + [4, 0, 0])  rotate(90, [0,1,0]) rotate(-90) extrude() front3a();
    translate(axle + [4-1.5, -10, -10]) extrude() front4();
    translate(axle + [4-1.5+5, -10+35, -10]) rotate(180, [1,0,0]) caster();
    
}


module motor_spacer(){
    difference(){
        circle(24);
        translate([0, 8]) motor_holes();
    }
}



module laser_body(){
    body();
}

module laser_misc(){
    translate([0, -48-wedge_length/cos(pen_angle)-margin_cut]){
        translate([0, wedge_raise]){
            wedge();
            translate([wedge_length,wedge_height+margin_cut]) rotate(180,[0,0,1]) wedge();
        }
        translate([wedge_length+margin_cut, 0]) ramp_top();
    }
    
    for(i=[0:3]){
        translate([24+i*(48+margin_cut), -24]) motor_spacer();
    }
    
    translate([135,-48-margin_cut]){
        translate([5, -45]) front1();
        translate([0, -80]) front2();
        translate([70, -40]) front4();

        adj_axle = [0, 0.05, 0.1];
        total = 0;
        for(i=[0:2]){
            translate([75,-50-i*(10+margin_cut)]) front3(adj_axle[i]);
        }
    }
}


//body();
//ramp();
//motor();
assembly();
//motor_spacer();
wheel_dy = (acrylic_thickness+collar_length)*sin(pen_angle);
wheel_dz = acrylic_thickness+wedge_height/2+wedge_raise+(acrylic_thickness+collar_length)*cos(pen_angle);
translate([0, body_height/2+wheel_dy, wheel_dz]) rotate(-pen_angle, [1,0,0]) rotate(360*$t) assembled_wheel();
//caster();
//laser();

//front2();
//laser_misc();
