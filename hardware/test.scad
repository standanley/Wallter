//square([40, 40]);

tooth_l = 2;
outer_c = 2*20;
outer_r = outer_c / (2*3.14159);
inner_r = outer_r - tooth_l;
echo(inner_r);
N = 20;


module gear(r, adj) {
    for (i = [1:N]){
        circle(r+.1, $fn = N*4);
        rotate(360/N*i, [0,0,1]) translate([0,r]) tooth(adj);
    }
}


module tooth(adj) {
    theta = 30;
    w = 1.5*.25*adj;
    h = .25*adj;
    translate([0,h]) circle(h, $fn=24);
    polygon([[w,0], [cos(theta)*h,h+sin(theta)*h], [-cos(theta)*h,h+sin(theta)*h], [-w,0]]);
    //translate([-1,0]) square(2);
}
    



difference(){
    d = 12;
    square([d*3.1, d*3.1], center=true);
    adj = [.9, 1, 1.25];
    adj2 = [.9, 1, 1.1];
    for(i = [0:2]){
        for(j = [0:2]){
            //translate([-d+d*i, -d+d*j]) gear(inner_r*adj2[i], adj[j]);
            translate([-d+d*i, -d+d*j]) gear2(adj2[i]);
        }
    }
    
}
module gear2(adj2) {
    r = inner_r*adj2;
    for (i = [1:20]){
        circle(r+.1, $fn = 20*4);
        rotate(360/20*i, [0,0,1]) translate([0,r]) tooth(1.25);
    }
}