// Shared settings and helpers for the Steam Frame PD100 mounts. Every mount
// prints on its side, so the layers lie in the plane that carries the PD100's
// weight. Axes as in pod_dims.scad.
include <pod_dims.scad>

part     = "none";
explode  = 0;          // assembly views: slide the mount out along X
print    = false;      // true: turn the chosen part to its print orientation
pod_view = pod_width;  // assembly views: how much of the pod's width to draw

curve_radius  = 117.5;  // pod's curve seen from above (between the R110 and R125 test gauges)

// BoboVR PD100 combo (dock + B100 battery), from the Amazon listing.
pd_across = 113;  // left to right, same direction as the pod
pd_up     = 75;   // along the mount's face
pd_thick  = 35;

mount_width = 55;
mount_wall  = 3;      // material around the groove in a mount
plate_thick = 3;      // platform thickness at its tip

dt_root    = 10;      // dovetail key width at its base
dt_tip     = 14;      // key width at its top
dt_height  = 5;
dt_gap     = 0.05;    // clearance per face in a mount's groove; starts tight, open up if needed
dt_lead_in = 2;       // groove flares open over this length at each end of a mount

// The clip is ref/SteamFrameBackClip.stl with its two slots replaced by our
// key. In that file X runs through the pod from the head side, Y across it,
// and Z up. These place it on the pod:
clip_file = "ref/SteamFrameBackClip.stl";
clip_mid  = 29.5;    // file Y at the clip's middle
clip_y0   = 17.4;    // file X of the top lip's inner face, which sits on the pod's outer face
clip_z0   = 47.3;    // file Z halfway between the cap and the bottom block, at the seam
clip_back_y = clip_y0 - 19.31;   // rearmost point of the clip: the lips at its middle

// Keys, as [Y of the centerline, Z of the base]: one on top of the cap for the
// over mount and one under the bottom block for the under mount, each where
// the file has its slot. Both run straight along X, key_len long.
key_len = 30;
key_top = [clip_y0 - 8.8,   95.0 - clip_z0];   // points up
key_bot = [clip_y0 - 14.42, 0 - clip_z0];      // points down

// The file's slots, in its (X, Z) plane with some overlap into the walls.
top_slot = [[4.0, 91.3], [10.0, 91.3], [10.0, 95.2], [4.0, 95.2]];
bot_slot = [[11.4, 0.01], [17.4, 0.01], [17.4, 3.7], [11.4, 3.7]];   // stops just above the block's underside, which a fill flush with it would leave non-manifold

// The groove's outer wall leans with the dovetail's flank.
flank_dy = (dt_tip - dt_root) / 2;
// Front of a mount (toward the head) at the key's base and at its tip.
function y_front_base(key) = key[0] + dt_root / 2 + dt_gap + mount_wall * sqrt(1 + (flank_dy / dt_height) ^ 2);
function y_front_tip(key)  = y_front_base(key) + flank_dy;
// Rear of a mount, level with the key's tip.
function y_rear_tip(key)   = key[0] - dt_tip / 2 - dt_gap - mount_wall;

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
// below the axis so it stays buried in the part it stands on.
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

// Move children from the clip file's axes onto the pod.
module clip_file_to_pod() {
    rotate([0, 0, -90]) translate([-clip_y0, -clip_mid, -clip_z0]) children();
}

// Fill a slot, given in the file's (X, Z) plane, over the length of the part
// around it: everything in the file inside box, closed up.
module fill_slot(slot, box) {
    intersection() {
        translate([0, 70, 0]) rotate([90, 0, 0]) linear_extrude(80) polygon(slot);
        hull() intersection() {
            import(clip_file);
            translate(box[0]) cube(box[1]);
        }
    }
}

// The clip on the pod, with both slots filled and a key on top of the cap
// (top), under the bottom block (bottom), or both.
module clip(top = true, bottom = true) {
    clip_file_to_pod() {
        import(clip_file);
        fill_slot(top_slot, [[0, 0, 91.3], [20, 60, 5]]);
        fill_slot(bot_slot, [[9, 0, -1], [11, 60, 4.7]]);
    }
    extrude_x(key_len) {
        if (top) at(key_top, [0, 1]) rail_2d();
        if (bottom) at(key_bot, [0, -1]) rail_2d();
    }
}

// The same clip with its outline changed by ref/reshape.py, as seen from the
// head side. wide_top is upside down: as wide at the cap as the original is at
// the bottom, and as narrow at the bottom as the original's cap. straight is
// as wide as the original's bottom all the way up. The files are in pod axes
// with both slots already filled. Their wide caps carry a key as long as the
// mount.
clip_wide_file     = "ref/SteamFrameBackClip_wide_top.stl";
clip_straight_file = "ref/SteamFrameBackClip_straight.stl";
key_len_wide       = mount_width;

module clip_reshaped(file) {
    import(file);
    extrude_x(key_len_wide) at(key_top, [0, 1]) rail_2d();
}

// Extrude a mount's (Y, Z) profile along X and cut the groove for a key at
// [Y, Z of its base] that points up (s = 1) or down (s = -1). The groove
// flares at both ends so the tight fit starts onto the key easily.
module mount_body(key, s) {
    difference() {
        extrude_x(mount_width) difference() {
            children();
            at(key, [0, s]) groove_2d(dt_gap);
        }
        for (m = [0, 1]) mirror([m, 0, 0])
            translate([mount_width / 2 - dt_lead_in, key[0], key[1]]) rotate([90, 0, 90])
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
