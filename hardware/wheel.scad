
acrylic_thickness = 5;
epsilon = 3;


N = 12;
expo_top_radius = N*2*12/(6.283);
//r = .15; // pen radius

pen_tip_length = 35;
separator_width = 20;
slot_width = 10;
max_r_pen = 15;
separation = 30;
pen_angle = 20;
pen_length = 150;
pen_tips_radius = expo_top_radius+pen_length*sin(pen_angle);


large_pen_body_radius = pen_tips_radius - pen_tip_length*sin(pen_angle);
small_pen_body_radius = large_pen_body_radius - separation*tan(pen_angle);
slot_dist = large_pen_body_radius + max_r_pen + 10 - acrylic_thickness / 2;
R = slot_dist + 10 + acrylic_thickness / 2; // outer radius of big circle

echo("Wheel radius", large_pen_body_radius);

slot = [slot_width + epsilon, acrylic_thickness + epsilon];


module expo(){
    cylinder(10,3, 3);
    translate([0,0,10]) cylinder(15, 5, 5);
    translate([0,0,25]) cylinder(10, 5, 10.5);
    translate([0,0,35]) cylinder(pen_length-35, 10.5, 10.5);
}

module separator(){
    
    difference(){
        union(){
            w1 = slot_width;
            h1 = separation + acrylic_thickness;
            translate([-w1/2, -h1/2]){
                square([w1, h1]);
            }
            w2 = separator_width;
            h2 = separation;
            translate([-w2/2, -h2/2]){
                square([w2, h2]);
            }
        }
        circle(5.1/2);
        
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

module big_circle(N, R, slot, hole_dist) {

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

    }
}

//big_circle(N, R, r, slot, 3.5);
//translate([R*2+1,0,0]) big_circle(N, R, r, slot, 2.5);

module bottom_circle(){
    //skeleton() 
    big_circle(N, R, slot, large_pen_body_radius);
}

module top_circle(){
    //skeleton() 
    big_circle(N, R, slot, small_pen_body_radius);
}

module assembled(){
    linear_extrude(acrylic_thickness){
        bottom_circle();
    }
    translate([0,0,separation]){
        linear_extrude(acrylic_thickness){
            top_circle();
        }
    }
    
    for(i=[0:N]){
        angle = 360/N*(i+.25);
        rotate(angle, [0,0,1]){
            
            translate([0, slot_dist + acrylic_thickness, separation/2 + acrylic_thickness/2]){
                rotate(90, [1, 0, 0]){
                    linear_extrude(acrylic_thickness) separator();
                }
            }
            
            if(i>N/2){
                translate([0, large_pen_body_radius]){
                    rotate(pen_angle, [1,0,0])translate([0,0,-40]){
                        expo();
                    }
                }
            }
        }
    }
}


module laser(){
    margin = 5;
    translate([R, -R]) top_circle();
    translate([R, -3*R - margin]) bottom_circle();
    w = separator_width;
    h = separation + acrylic_thickness;
    for(n=[0:N-1]){
        i = n%2;
        j = floor(n/2);
        
        translate([R*2+margin+w/2 + i*(w+margin), -h/2-j*(h+margin)]) separator();
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

module skeleton(){
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
    

//separator();
//expo();
rotate(-pen_angle+90, [1, 0, 0]) rotate(-90/N, [0, 0, 1]) assembled();
//laser();
//skeleton() top_circle();
//negative() bottom_circle();
//translate([0,0,100]) cube([80,5,5], centered=true);