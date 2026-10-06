// Shared settings and helpers for the Steam Frame PD100 mounts.
// Every part prints on its side, so the layers lie in the plane that carries
// the PD100's weight and the arms' flex. Axes as in pod_dims.scad.
include <arm_profile.scad>

part     = "none";
explode  = 0;          // assembly views: slide the mount out along X
print    = false;      // true: lay the chosen part on its side for printing
pod_view = pod_width;  // assembly views: how much of the pod's width to draw

curve_radius  = 117.5;  // pod's curve seen from above (between the R110 and R125 test gauges)

// BoboVR PD100 combo (dock + B100 battery), from the Amazon listing.
pd_across = 113;  // left to right, same direction as the pod
pd_up     = 75;   // along the mount's face
pd_thick  = 35;

mount_width = 55;
arm_width   = 15;
arm_offset  = mount_width / 2 - arm_width / 2 - 2;  // arms sit just inside the mount's ends
mount_wall  = 3;      // material around the groove in a mount
plate_thick = 3;      // platform thickness at its tip

dt_root    = 10;      // dovetail rail width at its base
dt_tip     = 14;      // rail width at its top
dt_height  = 5;
dt_gap     = 0.05;    // clearance per face in a mount's groove; starts tight, open up if needed
dt_lead_in = 2;       // groove flares open over this length at each end of a mount

c     = rim_clearance;
z_top = z_bar(c) + bar_thick;   // top of the arms' top bars, where the rails start

function arm_x_lo(side) = side * arm_offset - arm_width / 2;

// Each rail runs straight along the pod's width while its arm's bar curves away
// from it. Both rails share one line, centered on the flat top of the bars,
// between their rear edge at the arms' outer ends and their front edge at the
// inner ends.
function swept_y(y, x) = curve_radius - sqrt((curve_radius - y) ^ 2 - x ^ 2);
bar_rear  = swept_y(-lip_root[0] + edge_chamfer, arm_offset + arm_width / 2);
bar_front = swept_y(y_spine_out - edge_chamfer, arm_offset - arm_width / 2);
rail_y    = (bar_rear + bar_front) / 2;
assert(bar_front - bar_rear >= dt_root, "rail base overhangs the curved bars; narrow the arms");

// The groove's outer wall leans with the dovetail's flank.
flank_dy = (dt_tip - dt_root) / 2;
// Front of a mount (toward the head) at the rail's base and at its tip.
y_front_base = rail_y + dt_root / 2 + dt_gap + mount_wall * sqrt(1 + (flank_dy / dt_height) ^ 2);
y_front_tip  = y_front_base + flank_dy;
// Rear of a mount, level with the rail's tip.
y_rear_tip   = rail_y - dt_tip / 2 - dt_gap - mount_wall;

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

// Male dovetail with its base on the X axis, pointing +Y. The base runs 1 mm
// below the axis so it stays buried in an arm's bar when the bar turns.
module rail_2d() {
    polygon([[-dt_root / 2, -1], [dt_root / 2, -1],
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

// One arm, worn rail up: wraps the pod and carries a dovetail rail along its
// top bar. side = -1 is the left arm, 1 the right. Worn upside down, an arm
// moves to the other side and its rail runs under the pod. bow = spine_bow
// gives the shape as printed; bow = 0 gives the shape on the pod.
module arm(side, bow = 0) {
    x_lo = arm_x_lo(side);
    swept(x_lo, x_lo + arm_width) arm_2d(c, bow);
    // The rail turns with the top bar, about the pivot at the arm's middle.
    p = [swept_y(pivot[0], side * arm_offset), pivot[1]];
    translate([side * arm_offset, p[0], p[1]]) rotate([-bow_angle(bow), 0, 0]) translate([0, -p[0], -p[1]])
        extrude_x(arm_width) at([rail_y, z_top], [0, 1]) rail_2d();
}

// Both arms, worn rail up.
module arms(bow = 0) { for (side = [-1, 1]) arm(side, bow); }

// Extrude a mount's (Y, Z) profile along X and cut the groove for the arms'
// rails, whose base is at height zb and which point up (s = 1) or down (s = -1).
// The groove flares at both ends so the tight fit starts onto the rail easily.
module mount_body(zb, s) {
    difference() {
        extrude_x(mount_width) difference() {
            children();
            at([rail_y, zb], [0, s]) groove_2d(dt_gap);
        }
        for (m = [0, 1]) mirror([m, 0, 0])
            translate([mount_width / 2 - dt_lead_in, rail_y, zb]) rotate([90, 0, 90])
                linear_extrude(dt_lead_in + 0.01, scale = 1.06)
                    rotate(s > 0 ? 0 : 180) groove_2d(dt_gap - 0.02);
    }
}

// Pod outline for the assembly views: outer shell and head-side part, swept.
module pod() {
    swept(-pod_view / 2, pod_view / 2) {
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
