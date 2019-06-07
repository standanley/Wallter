use<test.scad>

acrylic_thickness = 6.35;
acrylic_thickness2 = 6.35/2;
epsilon = .3;
m5 = 5.1/2;

min_width = 5;


N = 12;
expo_top_radius = N*2*(11-1.5)/(6.283);
//r = .15; // pen radius

pen_tip_length = 35;
separator_width = 20;
slot_width = 10;
max_r_pen = 11;
separation = 30;
pen_angle = 20;
pen_length = 125;
pen_tips_radius = expo_top_radius+pen_length*sin(pen_angle);


large_pen_body_radius = pen_tips_radius - (pen_tip_length+5)*sin(pen_angle);
small_pen_body_radius = large_pen_body_radius - separation*tan(pen_angle);
slot_dist = large_pen_body_radius + max_r_pen + min_width + acrylic_thickness / 2*0;
R = slot_dist + min_width + acrylic_thickness; // outer radius of big circle

echo("Wheel radius", large_pen_body_radius);
echo("Big circle radius", R);

slot = [slot_width + epsilon, acrylic_thickness + epsilon];



module separator(){
    
    difference(){
        union(){
            w1 = slot_width;
            h1 = separation + acrylic_thickness2;
            translate([-w1/2, -h1/2]){
                square([w1, h1]);
            }
            w2 = separator_width;
            h2 = separation - acrylic_thickness2;
            translate([-w2/2, -h2/2]){
                square([w2, h2]);
            }
        }
        circle(m5, $fn = 24);
        
    }
    
}


module pen_hole(){
    union(){
        rotate(45)
        translate([-max_r_pen, -max_r_pen]){
            square([max_r_pen, max_r_pen]);
            translate([max_r_pen, max_r_pen]) circle(max_r_pen, $fn = 48);
        }
    }
}

module big_circle(N, R, slot, hole_dist, holes=false) {

    difference(){
        translate([0, 0]){
            circle(R, $fn = N*2);
        }

        for(i=[0:N]){
            angle = 360/N*(i+.25);
            rotate(angle, [0,0,1]){
                translate([0, hole_dist]){
                    pen_hole();
                }
                translate([0, slot_dist]){
                    translate([-slot_width/2 - epsilon/2, 0 - epsilon/2]) square(slot);
                }
            }
        }
        circle(2.5, $fn=24);
        
        if(holes){
            translate([-15, 0]) circle(m5);
            translate([ 15, 0]) circle(m5);
        }

    }
}

//big_circle(N, R, r, slot, 3.5);
//translate([R*2+1,0,0]) big_circle(N, R, r, slot, 2.5);


module spiral(){
    for(i=[0:6]){
        rotate(60*i) translate([8,-5]) square([8,60]);
    } 
}

module bottom_circle(){
    skeleton() 
    big_circle(N, R, slot, large_pen_body_radius, true);
}

module top_circle(){
    skeleton() 
    big_circle(N, R, slot, small_pen_body_radius);
}




module expo(){
    cylinder(10,3, 3);
    translate([0,0,10]) cylinder(15, 5, 5);
    translate([0,0,25]) cylinder(10, 5, 9.5);
    translate([0,0,35]) cylinder(pen_length-35, 9.5, 9.5);
}

module pencil() {
    cylinder(10,0,5);
    translate([0, 0, 10]) cylinder(pen_length+10, 5, 5);
}


module assembled_wheel(){
    linear_extrude(acrylic_thickness2){
        bottom_circle();
    }
    translate([0,0,separation]){
        linear_extrude(acrylic_thickness2){
            top_circle();
        }
    }
    
    for(i=[0:N]){
        angle = 360/N*(i+.25);
        rotate(angle, [0,0,1]){
            
            translate([0, slot_dist + acrylic_thickness, separation/2 + acrylic_thickness2/2]){
                rotate(90, [1, 0, 0]){
                    linear_extrude(acrylic_thickness) separator();
                }
            }
            
            if(i>N/2){
                translate([0, large_pen_body_radius]){
                    rotate(pen_angle, [1,0,0])translate([0,0,-pen_tip_length-5]){
                        expo();
                    }
                }
            } else {
                translate([0, large_pen_body_radius]){
                    rotate(pen_angle, [1,0,0])translate([0,0,-pen_tip_length-5]){
                        //pencil();
                    }
                }
            }
        }
    }
}


module laser_thin(){
    margin = 5;
    translate([R, -R]) top_circle();
    translate([R, -3*R - margin]) bottom_circle();
    
    translate([-20-margin, 0]) scale([1, -1]) laser_connectors();
    
}

module laser_thick(){
    margin = 5;
    w = separator_width;
    h = separation + acrylic_thickness2;
    for(n=[0:N-1+2]){
        i = n%3;
        j = floor(n/3);
        
        translate([40+i*(w+margin), h/2+j*(h+margin)]) separator();
    }
    laser_connectors();
}

module laser_connectors(){
    margin = 2;
    adj_gear = [1.3, 1.4, 1.5];
    adj_axle = [0, 0.05, 0.1];
    for(i=[0:2]){
        translate([0,12+i*(23+margin)]) connector_gear(adj_gear[i]);
    }
    total = 12+3*(23+margin);
    for(i=[0:2]){
        translate([0,total+i*(16+margin)]) connector_axle(adj_axle[i]);
    }
}

module laser_connectors2(){
    margin = 5;
    adj_gear = [1.3, 1.4, 1.5];
    adj_axle = [0, 0.05, 0.1];
    for(i=[0:2]){
        translate([0,12+i*(23+margin)]) connector_gear(adj_gear[i]);
    }
    total = 12+3*(23+margin);
    for(i=[0:2]){
        translate([0,total+i*(16+margin)]) connector_axle(adj_axle[i]);
    }
}

module negative(){
    difference(){
        minkowski(){
            hull() children(0);
            circle(10);
        }
        //circle(R);
        children(0);
    }
}

module empty(){}

module skeleton_orig(){
    intersection(){
        difference(){
            minkowski(){
                negative() children(0);
                circle(10);
            }
            negative() children(0);
        }
        children(0);
    }
    
    
}

module skeleton(){
    intersection(){
        union(){
            difference(){
                minkowski(){
                    union(){
                        negative() children(0);
                    }
                    circle(10);
                }
                negative() children(0);
            }
            spiral();
        }
        children(0);
        
    }
    
}


module negative2(){
    difference(){
        hull() children(0);
        children(0);
    }
}

module skeleton2(){
    intersection(){
        union(){
            difference(){
                union(){
                    minkowski(){
                        union(){
                            negative2() children(0);
                        }
                        circle(5, $fn=48);
                    }
                    square([30, 15], center=true);
                }
                negative2() children(0);
            }
        }
        children(0);
    }
}


module connector_gear(adj2){
    skeleton2() 
    //negative2()
    difference() {
        square([100, 100], center=true);
        translate([-15, 0]) circle(m5, $fn=24);
        translate([ 15, 0]) circle(m5, $fn=24);
        gear2(adj2);
    }
}

module axle_hole(eps=.05){
    intersection(){
        circle((2.5+eps*2), $fn = 48);
        square([3+eps*2,15], center=true);
    }
}

module connector_axle(adj){
    skeleton2() 
    //negative2()
    difference() {
        square([100, 100], center=true);
        translate([-15, 0]) circle(m5, $fn=24);
        translate([ 15, 0]) circle(m5, $fn=24);
        rotate(90) axle_hole(adj);
    }
}
    
//assembled_wheel();
//separator();
//expo();
//rotate(-pen_angle+90, [1, 0, 0]) 
//rotate(-90/N+ 360*$t, [0, 0, 1]) assembled_wheel();
laser_thin();
//laser_thick();
//skeleton() top_circle();
//negative() bottom_circle();
//translate([0,0,100]) cube([80,5,5], centered=true);