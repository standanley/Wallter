use <wheel.scad>;

acrylic_thickness = 6.35;
margin = 5;
margin_cut = 2;
epsilon = .5;

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

wheel_radius = 100+10;//120.17;
body_width = wheel_radius*2+40;
body_height = body_width;
slotx = acrylic_thickness+2*epsilon;
sloty = spacer_width-10+2*epsilon;
top_width = slide_width+4*margin+2*(slotx-2*epsilon);



top_motor_offset = [15, 25];

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

module body(){
    union(){
        difference() {
            square([body_width,body_height]);
            //translate([90, 150]) circle(m5_radius);
            //translate([110, 150]) circle(m5_radius);
            
            translate([35, 20]) caster_holes();
            translate([body_width-35, 20]) caster_holes();
            
            translate([body_width/2, body_height/2]) difference(){
                scale([1, cos(pen_angle)]) circle(wheel_radius+10, $fn=100);
                square([wedge_width, wedge_length], center=true);
                translate([-body_width/2, -body_height]) square([body_width,body_height]);
            }
            translate([body_width/2, body_height/2-12]) circle(20);
            
            dx = top_motor_offset[0];
            dy = top_motor_offset[1];
            translate([dx, body_height-dy]) rotate(90) motor_holes();
            translate([body_width-dx, body_height-dy]) rotate(-90) motor_holes();
            
            translate([body_width/2 + 10, body_height-10]) circle(m5_radius, $fn = 24);
            translate([body_width/2 - 10, body_height-10]) circle(m5_radius, $fn = 24);
            translate([body_width/2 + 20, body_height-11]) circle(m5_radius, $fn = 24);
            translate([body_width/2 - 20, body_height-11]) circle(m5_radius, $fn = 24);
            translate([body_width/2 + 30, body_height-13]) circle(m5_radius, $fn = 24);
            translate([body_width/2 - 30, body_height-13]) circle(m5_radius, $fn = 24);
            translate([body_width/2 + 40, body_height-15]) circle(m5_radius, $fn = 24);
            translate([body_width/2 - 40, body_height-15]) circle(m5_radius, $fn = 24);
        
        
        
            translate([body_width/2 + 80, body_height-8]) circle(m5_radius, $fn = 24);
            translate([body_width/2 - 80, body_height-8]) circle(m5_radius, $fn = 24);
            translate([body_width/2 + 80, body_height-28]) circle(m5_radius, $fn = 24);
            translate([body_width/2 - 80, body_height-28]) circle(m5_radius, $fn = 24);
        
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
            translate([0, -extension]) square([body_width, extension]);
            translate([35, 20-extension]) caster_holes();
            translate([body_width-35, 20-extension]) caster_holes();
            translate([35, 20-extension/2]) caster_holes();
            translate([body_width-35, 20-extension/2]) caster_holes();
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
    
    translate([-body_width/2+35, 20]) rotate([180, 1,0]) caster();
    translate([body_width/2-35, 20]) rotate([180, 1,0]) caster();
    
    
    dx = top_motor_offset[0];
    dy = top_motor_offset[1];
    translate([-body_width/2+dx, body_height-dy]) rotate( 90) motor();
    translate([ body_width/2-dx, body_height-dy]) rotate(-90) motor();
    
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
                    translate([17.5,0]) circle(3.5);
                    translate([-17.5,0]) circle(3.5);
                }
                translate([17.5,0]) circle(2.1);
                translate([-17.5,0]) circle(2.1);
            }
        }
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
module caster_holes(){
    translate([-.75*25.4, 0]) circle(m3_radius, $fn=24);
    translate([ .75*25.4, 0]) circle(m3_radius, $fn=24);
    circle(17);
}
module motor_holes(){
    translate([-17.5, -8]) circle(m3_radius, $fn=24);
    translate([ 17.5, -8]) circle(m3_radius, $fn=24);
    //circle(8);
    translate([0,-8]) circle(15.5);
}

/*
module motor_top() {
    square([30, 20], center=true);
    
}
*/

module laser(){
    body();
    
    translate([0, -extension-wedge_length/cos(pen_angle)-margin_cut]){
        translate([0, wedge_raise]){
            wedge();
            translate([wedge_length,wedge_height+margin_cut]) rotate(180,[0,0,1]) wedge();
        }
        translate([wedge_length+margin_cut, 0]) ramp_top();
    }
    
}


//body();
//ramp();
//laser();
//motor();
assembly();
wheel_dy = (acrylic_thickness+collar_length)*sin(pen_angle);
wheel_dz = acrylic_thickness+wedge_height/2+wedge_raise+(acrylic_thickness+collar_length)*cos(pen_angle);
//translate([0, body_height/2+wheel_dy, wheel_dz]) rotate(-pen_angle, [1,0,0]) rotate(360*$t) assembled_wheel();
//caster();
//laser();
