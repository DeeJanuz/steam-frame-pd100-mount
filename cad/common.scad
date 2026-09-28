// Shared settings and helpers for the Steam Frame PD100 mounts.
// Every part prints on its side, so the layers lie in the plane that carries
// the PD100's weight and the hooks' flex. Axes as in pod_dims.scad.
include <hook_profile.scad>

part    = "none";
explode = 0;          // assembly views: slide the mount out along X
print   = false;      // true: lay the chosen part on its side for printing

curve_radius  = 117.5;  // pod's curve seen from above (between the R110 and R125 test gauges)
rim_clearance = 0.0;    // fit clip A: no extra room over the outer shell's rim

// BoboVR PD100 combo (dock + B100 battery), from the Amazon listing.
pd_across = 113;  // left to right, same direction as the pod
pd_up     = 75;   // along the mount's face
pd_thick  = 35;

mount_width = 55;
arm_width   = 15;
arm_offset  = mount_width / 2 - arm_width / 2 - 2;  // arms sit just inside the mount's ends
plate_thick = 3;      // platform thickness at its tip

dt_root    = 10;      // dovetail rail width at its base
dt_tip     = 14;      // rail width at its top
dt_height  = 5;
dt_gap     = 0.05;    // clearance per face in a mount's groove; starts tight, open up if needed
dt_lead_in = 2;       // groove flares open over this length at each end of a mount

c     = rim_clearance;
z_top = z_bar(c) + bar_thick;   // top of the arms' top bars

// Extrude a (Y, Z) profile along X, centered.
module extrude_x(len) {
    translate([-len / 2, 0, 0]) rotate([90, 0, 90]) linear_extrude(len) children();
}

// Sweep a (Y, Z) profile along the pod's curve, keeping x_lo <= X <= x_hi.
module swept(x_lo, x_hi) {
    reach = max(abs(x_lo), abs(x_hi)) + 2;
    ang = 2 * asin(min(0.99, reach / (curve_radius - 15)));
    intersection() {
        translate([0, curve_radius, 0]) rotate(-90 - ang / 2)
            rotate_extrude(angle = ang, $fn = 720)
                translate([curve_radius, 0]) mirror([1, 0]) children();
        translate([x_lo, -500, -500]) cube([x_hi - x_lo, 1000, 1000]);
    }
}

// Male dovetail with its base on the X axis, pointing +Y.
module rail_2d() {
    polygon([[-dt_root / 2, -0.2], [dt_root / 2, -0.2],
             [dt_tip / 2, dt_height], [-dt_tip / 2, dt_height]]);
}

// Matching groove with clearance g on every face, open below the X axis.
module groove_2d(g) {
    offset(delta = g) rail_2d();
    translate([-dt_root / 2 - g, -1]) square([dt_root + 2 * g, 1]);
}

// Place 2D children at point q, rotated so +Y points along dir.
module at(q, dir) {
    translate(q) rotate(atan2(dir[1], dir[0]) - 90) children();
}

function arm_x_lo(side) = side * arm_offset - arm_width / 2;

// Pod outline for the assembly views: outer shell and head-side part, swept.
module pod() {
    swept(-pod_width / 2, pod_width / 2) {
        translate([0, -shell_height / 2]) square([shell_thick_top, shell_height]);
        translate([shell_thick_top, -head_part_height / 2])
            square([total_thick_edge - shell_thick_top, head_part_height]);
    }
}

// Lay a part on its side, lowest X face (x_lo) on the bed.
module on_side(x_lo) {
    if (print) translate([0, 0, -x_lo]) rotate([0, -90, 0]) children();
    else children();
}
