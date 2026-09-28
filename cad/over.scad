// Over mount: the PD100 sits over the top of the pod. The under arms are worn
// upside down, so their back rail sits on the upper half of the pod.
//   over_mount - slides onto the back rails like the under mount, wraps over
//       the arms' top corner, and carries a 40 mm platform over the top.
// Meant for relaxed use, so it sticks out behind the head as little as
// possible: a 60 degree platform lays the PD100 over the top so its thickness
// points up rather than back. Axes as in pod_dims.scad.
include <under.scad>

part = "over_assembly";  // over_assembly, over_mount

over_tilt    = 60;         // platform angle from vertical, upper end toward the face
platform_len = 40;         // flat platform, from the back of the mount to the tip
pd_offset    = 0;          // PD100's lower edge, mm up the platform from the mount's back
corner_mat   = 3.5;        // material between the platform face and the arms' top corner
cap_gap     = 0.3;         // clearance over the arms' top bars
cap_reach   = 12;          // how far forward the cap over the arms' top bars reaches
body_depth  = 10;          // mount depth behind the arms, around the groove
brace_drop  = 10;          // how far the brace under the platform reaches down the cap's front
over_rail_z = -rail_z;     // under arms worn upside down

o_dir = [sin(over_tilt), cos(over_tilt)];    // up the platform, toward the face
o_in  = [cos(over_tilt), -sin(over_tilt)];   // into the mount, toward the pod
o_out = -o_in;                               // out of the platform, PD100 side

b_over     = [y_face, z_top] - corner_mat * o_in;   // platform face point nearest the arms' corner
y_rear     = y_face - body_depth;                   // back of the mount, deep enough for the groove
face_low   = b_over + (y_rear - b_over[0]) / sin(over_tilt) * o_dir;   // platform's back end
tip_top    = face_low + platform_len * o_dir;
tip_bottom = tip_top + plate_thick * o_in;
pd_low     = face_low + pd_offset * o_dir;          // PD100's lower edge (display edge) on the platform
z_bot      = over_rail_z - dt_tip / 2 - dt_gap - under_wall;
z_cap      = z_top + cap_gap;

cap_front = min(cap_reach, tip_bottom[0]);
z_under   = tip_bottom[1] - (tip_bottom[0] - cap_front) / tan(over_tilt);  // platform underside above the cap front
z_brace   = max(z_cap, z_under - brace_drop);

// Under arms worn upside down: same parts, mirrored top to bottom.
module over_arm(side) { mirror([0, 0, 1]) under_arm(side); }

// Side profile: behind the arms with the groove, over the arms' top bars, and
// up the platform to its tip.
module over_mount_2d() {
    front = tip_bottom[0] > cap_front + 0.01
        ? [[cap_front, z_cap], [cap_front, z_brace], tip_bottom]
        : [[cap_front, z_cap], tip_bottom];
    difference() {
        polygon(concat([[y_face, z_bot], [y_face, z_cap]], front,
                       [tip_top, face_low, [y_rear, z_bot]]));
        at([y_face, over_rail_z], [-1, 0]) groove_2d(dt_gap);
    }
}

module over_mount() {
    difference() {
        extrude_x(mount_width) over_mount_2d();
        // Flare the groove at both ends so the tight fit starts onto the rail easily.
        for (m = [0, 1]) mirror([m, 0, 0])
            translate([mount_width / 2 - dt_lead_in, y_face, over_rail_z]) rotate([90, 0, 90])
                linear_extrude(dt_lead_in + 0.01, scale = 1.06) rotate(90) groove_2d(dt_gap - 0.02);
    }
}

module over_pd100() {
    extrude_x(pd_across) polygon([pd_low, pd_low + pd_up * o_dir,
                                  pd_low + pd_up * o_dir + pd_thick * o_out, pd_low + pd_thick * o_out]);
}

if (part == "over_mount") on_side(-mount_width / 2) over_mount();
if (part == "over_assembly") {
    color("dimgray") pod();
    color("steelblue") for (side = [-1, 1]) over_arm(side);
    color("darkorange") translate([explode, 0, 0]) over_mount();
    color("gold", 0.35) translate([explode, 0, 0]) over_pd100();
}
