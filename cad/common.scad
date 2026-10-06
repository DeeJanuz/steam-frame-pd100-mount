// Shared settings and helpers for the Steam Frame PD100 mounts.
// Every part prints on its side, so the layers lie in the plane that carries
// the PD100's weight and the clip's flex. Axes as in pod_dims.scad.
include <clip_profile.scad>

part     = "none";
explode  = 0;          // assembly views: slide the mount out along X
print    = false;      // true: lay the chosen part on its side for printing
pod_view = pod_width;  // assembly views: how much of the pod's width to draw

curve_radius  = 117.5;  // pod's curve seen from above (between the R110 and R125 test gauges)
rim_clearance = 0.0;    // fit clip A: no extra room over the outer shell's rim

// BoboVR PD100 combo (dock + B100 battery), from the Amazon listing.
pd_across = 113;  // left to right, same direction as the pod
pd_up     = 75;   // along the mount's face
pd_thick  = 35;

clip_width  = 50;     // across the pod, centered on it
mount_width = 55;
mount_wall  = 3;      // material around the groove in a mount
plate_thick = 3;      // platform thickness at its tip

dt_root    = 10;      // dovetail rail width at its base
dt_tip     = 14;      // rail width at its top
dt_height  = 5;
dt_gap     = 0.05;    // clearance per face in a mount's groove; starts tight, open up if needed
dt_lead_in = 2;       // groove flares open over this length at each end of a mount

c     = rim_clearance;
z_top = z_bar(c) + bar_thick;   // top of the clip's top bar, where the rail starts

// The rail runs straight along the pod's width while the bar curves away from
// it toward the clip's ends. Center the rail's base on the flat top of the bar,
// between its rear edge at the ends and its front edge in the middle.
function swept_y(y, x) = curve_radius - sqrt((curve_radius - y) ^ 2 - x ^ 2);
bar_rear  = swept_y(-lip_thick + edge_chamfer, clip_width / 2);
bar_front = y_spine_out - edge_chamfer;
rail_y    = (bar_rear + bar_front) / 2;
assert(bar_front - bar_rear >= dt_root, "rail base overhangs the curved bar; narrow the clip");

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
// below the axis so it stays buried in the clip's bar when the bar turns.
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

// The clip, worn rail up: wraps the pod and carries a dovetail rail along the
// top bar. Worn upside down, the rail runs under the pod. bow = spine_bow gives
// the shape as printed; bow = 0 gives the shape on the pod.
module clip(bow = 0) {
    swept(-clip_width / 2, clip_width / 2) clip_2d(c, bow);
    // The rail turns with the top bar, about the pivot at the clip's center.
    translate([0, pivot[0], pivot[1]]) rotate([-bow_angle(bow), 0, 0]) translate([0, -pivot[0], -pivot[1]])
        extrude_x(clip_width) at([rail_y, z_top], [0, 1]) rail_2d();
}

// Extrude a mount's (Y, Z) profile along X and cut the groove for the clip's
// rail, whose base is at height zb and which points up (s = 1) or down (s = -1).
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
