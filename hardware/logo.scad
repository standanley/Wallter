w = [[0,1],[.3,0],[.5,.4],[.7,0],[1,1]];
//text = [[0,1],[.3,0],[.5,.4],[.7,0],[1,1], [.7,0.01],[.5,.401],[.3,0.01]];
//a = [[0,0], [.3,1], [.6,0]];
a = [[0,0], [.3,1], [.3,.5], [.3,1], [.48,.4], [.12,.4], [.48,.4], [.6,0]];
l = [[0,1], [.3,0], [.6,0]];
t = [[-.2,1], [.5,1],[.3,1],[.3,0]];
e = [[.6,1],[.3,1],[0,0],[.3,0],[0,0],[.15,.5],[.45,.5]];
//r = [[0,0],[.3,1],[.48,.4],[.12,.4],[.6,0]];
r = [[0,0],[.3,1],[.3,.5], [.3,1],[.48,.4],[.12,.4],[.6,0]];

letters = [w,a,l,l,t,e,r];

//w2 = for(i in len(w)) { [w[i][0*2

kerning = [0, 1, 1.6, 2.2, 2.8,3.4,4];


module letter(ps){
    width = .01;
    union(){
        for(i=[0:len(ps)-2]){
            hull(){
                translate(ps[i]) circle(width, $fn=24);
                translate(ps[i+1]) circle(width, $fn=24);
            }
        }
    }
}

module style(){
    minkowski(){
        children(0);
        scale(75) hull(){
            //circle(.05, $fn=48);
            //translate([.08,.06]) circle(.05, $fn=48);
            translate([.00,.0]) circle(.03, $fn=36);
            translate([.03,.1]) circle(.03, $fn=36);
            translate([.06,.0]) circle(.03, $fn=36);
            //translate([.03,-.1]) circle(.05, $fn=48);
            //translate([.0,.0]) circle(.05, $fn=48);
        }
    }
}

module word(letters, spacing){
    for(i=[0:len(letters)-1]){
        translate([spacing[i],0]) letter(letters[i]);
    }
}
        


module logo(){
    style() word(50*letters, 50*kerning);
}

logo();

