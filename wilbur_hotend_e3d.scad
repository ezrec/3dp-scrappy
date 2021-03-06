//
// Copyright (C) 2017, Jason S. McMullan <jason.mcmullan@gmail.com>
// All rights reserved.
//
// Licensed under the MIT License:
//
// Permission is hereby granted, free of charge, to any person obtaining
// a copy of this software and associated documentation files (the "Software"),
// to deal in the Software without restriction, including without limitation
// the rights to use, copy, modify, merge, publish, distribute, sublicense,
// and/or sell copies of the Software, and to permit persons to whom the
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
// FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
// All units are in mm

use <E3D/v6_lite.scad>
use <mini_height_sensor.scad>

hardware=true;

e3d_v6_clamp_diameter = 12;
e3d_v6_clamp_height = 6.0;;
e3d_v6_bulk_diameter = 16;

e3d_v6_bulk_length = 35.5;
function e3d_v6_nozzle_height(volcano = false) = 5.5 + (volcano ? 20 : 11.5);

m3_nut_flat=5.5;
m3_nut_height=2.25;

m4_nut_flat=7;
m4_nut_height=3.5;

drill_tolerance = 0.20;

wall = 3;

fn=30;

module drill(d=3, h=1, tolerance=drill_tolerance, fn=fn)
{
    translate([0, 0, -0.1]) rotate([0, 0, 30]) cylinder(d=d + tolerance*2, h=h+0.2, $fn =fn);
}

module e3d_v6_duct()
{
    // https://www.thingiverse.com/thing:340312
    // import("E3D/V6.6_Duct.stl");
}

module hotend_e3d_v6_of(cut=false, volcano=false)
{
    threaded_screw_d = 2.2;
    
    if (!cut)
    {
        translate([0, 0, e3d_v6_clamp_height/2]) cube([40+0.02, 40, e3d_v6_clamp_height], center=true);
        
        // Extra mounting bracket - front
        rotate([0, 0, -90]) translate([20-wall, -20, -10]) cube([wall, 40, 10+e3d_v6_clamp_height]);        
        
        rotate([0, 0, -180]) translate([20-wall, -20, -10]) cube([wall, 40, 10+e3d_v6_clamp_height]);        
        
        // Extra mounting bracket - rear
        rotate([0, 0, -90]) translate([-20, -20, -10]) cube([wall, 40, 10+e3d_v6_clamp_height]);        
    }
    else
    {
        // Mounting slot
        rotate([0, 0, 90]) translate([0, 0, -0.01]) linear_extrude(height=e3d_v6_clamp_height+0.02) hull()
        {
            circle(d=e3d_v6_clamp_diameter + drill_tolerance+0.1, $fn=fn);
            translate([0, -300, 0])
                circle(d=e3d_v6_clamp_diameter*2+0.1);
        }
        
        // M4 mounting holes, 20mm apart
        for (r = [0:90:270]) rotate([0, 0, 45+r]) translate([20*sin(45), 0, 0]) {
            drill(h=e3d_v6_clamp_height, d=4);
            translate([0, 0, -20])
                rotate([0, 0, 30]) rotate([0, 0, 45+r]) cylinder(r=m4_nut_flat/sqrt(3)+drill_tolerance, h=m4_nut_height+20+0.1, $fn=6);
        }
        
        // Front mounting bracket drills
        rotate([0, 0, -90]) translate([20-wall, 0, -5]) {
            translate([0, -12, 0]) rotate([0, 90, 0]) drill(h=5, d=threaded_screw_d);
            translate([0, 12, 0]) rotate([0, 90, 0]) drill(h=5, d=threaded_screw_d);
        }
        
        // Rear mounting bracket drills - 24mm, m3
        rotate([0, 0, 180]) translate([20-wall, 0, -5]) {
            translate([0, -12, 0]) rotate([0, 90, 0]) drill(h=5, d=threaded_screw_d);
            translate([0, 12, 0]) rotate([0, 90, 0]) drill(h=5, d=threaded_screw_d);
        }
        
        // Front mounting bracket drills - 24mm, m3
        rotate([0, 0, -90]) translate([-20, 0, -5]) {
            translate([0, -12, 0]) rotate([0, 90, 0]) drill(h=5, d=threaded_screw_d);
            translate([0, 12, 0]) rotate([0, 90, 0]) drill(h=5, d=threaded_screw_d);
        }
        
        % translate([0, 0, -33]) rotate([0, 0, 180]) rotate([90, 0, 0]) e3d_v6_duct();
    }
}

module wilbur_hotend_e3d_v6(volcano=false)
{
    difference()
    {
        hotend_e3d_v6_of(cut=false, volcano=volcano);
        hotend_e3d_v6_of(cut=true, volcano=volcano);
    }
}


m3_square_nut = [2, 5.5, 5.5];
m3_bolt_head_d = 5.5;
m3_bolt_head_h = 3;
m3_bolt_d = 3;

module m3_spacer_bolt_cut(w = 20, tolerance=0.2)
{
            // Top shaft cutout
	       hull() {
			translate([-w/2, 0, 0]) {
				cylinder(d = m3_bolt_d, h = wall/2 + wall + m3_bolt_head_h, $fn = fn);
			}
			translate([0, 0, 0]) {
				cylinder(d = m3_bolt_d, h = wall/2 + wall + m3_bolt_head_h, $fn = fn);
			}
		  }

            // Top head cutout
	       hull() {
			translate([-w/2, 0, wall + wall/2]) {
				cylinder(d = m3_bolt_head_d + tolerance*2, h = m3_bolt_head_h + tolerance, $fn=fn);
			}
			translate([0, 0, wall + wall/2]) {
				cylinder(d = m3_bolt_head_d + tolerance*2, h = m3_bolt_head_h + tolerance, $fn=fn);
			}
		  }

        
            // Bottom shaft cutout
		  translate([0, 0, -wall/2 - wall - m3_square_nut[0] - wall - 0.1])
			cylinder(d = m3_bolt_d, h = wall/2 + wall + m3_square_nut[0] + wall + 0.2, $fn=fn);


}

module m3_spacer_bar_of(cut = false, w = 20,tolerance=0.2)
{
    if (!cut)
    {
        translate([-w/2, -(wall + m3_square_nut[1]), -(wall + m3_square_nut[0] + wall + wall/2)])
        cube([w, wall + m3_square_nut[1], wall + m3_square_nut[0] + wall + wall + wall + m3_bolt_head_h + wall]);
    }
    else
    {
        // Middle gap
        translate([-w/2-0.1, -(wall + m3_square_nut[1]) - 0.1, -wall/2])
		cube([w + 0.2, wall + m3_square_nut[1] + 0.2, wall]);

	   // Guide bolts
	   for (d = [0:1])  translate([0, -(wall + m3_square_nut[1]/2), 0])  rotate([0, 0, 180 * d]) { 
		  translate([-w/3, 0, 0]) m3_spacer_bolt_cut(w=w, tolerance=tolerance);
       }

	  translate([0, -(wall + m3_square_nut[1]/2), 0])  rotate([0, 0, 90]) { 
		  m3_spacer_bolt_cut(w=w, tolerance=tolerance);
       }

       // Square nut slot
	  translate([0, -wall - m3_square_nut[1]/2, -wall/2 - wall - m3_square_nut[0]/2])
		cube([m3_square_nut[2]+tolerance*2, m3_square_nut[1] + tolerance*2, m3_square_nut[0]], center = true);

	   
    }
}

module wilbur_sensor_e3d_v6(volcano=false)
{
    height=e3d_v6_bulk_length+e3d_v6_nozzle_height(volcano)-7;
    translate([20+wall, 0, -height]) {
        difference()
        {
            translate([-wall, -20, 0])
                cube([wall, 40, height]);
            translate([-wall-0.01, 0, height-5]) {
                translate([0, -12, 0]) rotate([0, 90, 0]) drill(h=wall, d=3-drill_tolerance*2);
                translate([0, 12, 0]) rotate([0, 90, 0]) drill(h=wall, d=3-drill_tolerance*2);
            }
            * translate([-wall, 0, 0])
                scale([wall, 40-wall/2, height*1.75]) sphere(r=0.5, $fn=fn*2);
        }

        translate([0, 0, -5]) rotate([0, 0, 90]) mini_height_sensor_mount();
    }
}

module fan_40mm_drill(h=11, d=3, fn=fn)
{
    translate([20-16, 20-16, 0]) drill(d=d, h=h, fn=fn);
    translate([20+16, 20-16, 0]) drill(d=d, h=h, fn=fn);
    translate([20-16, 20+16, 0]) drill(d=d, h=h, fn=fn);
    translate([20+16, 20+16, 0]) drill(d=d, h=h, fn=fn);
}

module fan_40mm_of(cut=false)
{
    if (!cut)
    {
        cube([40, 40, 11]);
    }
    else
    {
        translate([20, 20, 0]) drill(d=37.5, h = 11);
        fan_40mm_drill(h=11);
    }
}

module fan_e3d_v6_of(cut=false, volcano = false)
{
    angle = 55;
    fan_height = 2;
    fan_gap = 1.5;
    
    height=e3d_v6_bulk_length+e3d_v6_nozzle_height(volcano=volcano)-7;
    translate([-20, 0, -height]) 
    {
        if (!cut)
        {
            translate([-wall, -20, 0]) {
                cube([wall, 40, height]);
                hull() {
                    translate([0, 0, -(7-fan_height)]) cube([wall, 40, -(40+(7-fan_height))*sin(-angle)]);
                    translate([-40*cos(-angle), 0, 0]) cube([40*cos(-angle), 40, 0.01]);
                }
            }
            translate([-wall-0.01, 0, height-5]) {
                translate([0, -12, 0]) rotate([0, 90, 0]) drill(h=wall, d=3-drill_tolerance*2);
                translate([0, 12, 0]) rotate([0, 90, 0]) drill(h=wall, d=3-drill_tolerance*2);
            }
        }
        else
        {
            translate([-wall-0.01, 0, height-5]) {
                translate([0, -12, 0]) rotate([0, 90, 0]) drill(h=wall, d=3-drill_tolerance*2);
                translate([0, 12, 0]) rotate([0, 90, 0]) drill(h=wall, d=3-drill_tolerance*2);
            }
            
            translate([-wall-40*cos(-angle), -20, 0]) rotate([0, -angle, 0])
            {
                translate([0, 0, -11]) fan_40mm_drill(h=22);
                translate([0, 0, -wall*2-m3_nut_height]) fan_40mm_drill(h=m3_nut_height, d=m3_nut_flat/sqrt(3)*2, fn=6);
            }
            
            hull()
            {
                translate([-wall-40*cos(-angle), -20, 0]) rotate([0, -angle, 0])
                {
                    translate([20, 20, 0]) cylinder(d=37.5, h=0.1);
                }
                translate([0, -20+2, -(7-fan_height)+1.5]) cube([0.1, 40-4, fan_gap]);
            }
        }
    
        if (hardware && !cut)
        {
            % translate([-wall-40*cos(-angle), -20, 0]) rotate([0, -angle, 0]) difference()
            {
                fan_40mm_of(false);
                fan_40mm_of(true);
            }
        }
    }
}    

module wilbur_fan_e3d_v6(volcano=false)
{
    difference()
    {
        fan_e3d_v6_of(cut=false, volcano=volcano);
        fan_e3d_v6_of(cut=true, volcano=volcano);
    }
}

wilbur_hotend_e3d_v6(volcano=true);
rotate([0, 0, -90]) wilbur_sensor_e3d_v6(volcano=true);
rotate([0, 0, -90]) wilbur_fan_e3d_v6(volcano=true);
if (hardware) %e3d_v6_lite(volcano=true);
// vim: set shiftwidth=4 expandtab: //
