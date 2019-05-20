acrylic_thickness = 5;
margin = 10;

pen_angle = 20;
wedge_width = 60;
wedge_length = 50;


wedge_height = wedge_length*tan(pen_angle);


module extrude(){
    linear_extrude(acrylic_thickness) children(0);
}

module wedge(){
    polygon([[0,0],[wedge_length,0],[0,wedge_height]]);
}

module extruded_wedge(){
    translate([0,wedge_length,0]) 
    rotate(-90,[0,1,0]) 
    rotate(-90,[0,0,1]) 
    extrude() wedge();
}

module ramp_top(){
    square([wedge_width, wedge_length/cos(pen_angle)]);
}

module ramp(){
    rotate(pen_angle, [1,0,0]) {
        extrude() ramp_top();
    }
    translate([acrylic_thickness,0,0]) extruded_wedge();
    translate([wedge_width,0,0]) extruded_wedge();
}

module motor(){
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


module laser(){
    wedge();
    translate([wedge_length,wedge_height+margin]) rotate(180,[0,0,1]) wedge();
    translate([wedge_length+margin, 0]) ramp_top();
    
}

ramp();
//laser();
motor();