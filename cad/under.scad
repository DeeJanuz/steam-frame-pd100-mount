// Under mount: the PD100 hangs below and behind the Steam Frame's battery pod.
// Best for fast-paced games, since there is less movement low on the head.
//   under_arm_left, under_arm_right - clips that snap over the pod's outer shell,
//       curved to follow the pod, with a dovetail rail across the back. The same
//       pair of arms is used for the over mount, worn upside down.
//   under_mount - slides onto the back rails; its angled face carries the PD100
//       with the display edge facing up.
// The mount's face passes just under the arms' bottom corner, which puts the
// PD100 as close to the pod as the arms allow. Two numbers set the platform:
// its angle, and how far below the pod the PD100's front corner (the part that
// can reach the neck) is allowed to go. Axes as in pod_dims.scad.
include <common.scad>

part = "under_assembly";  // under_assembly, under_arm_left, under_arm_right, under_mount

under_tilt   = 30;   // PD100 lean from vertical, lower edge toward the neck
corner_below = 25;   // PD100's lowest front corner, mm below the pod's bottom edge
pod_clear    = 1;    // gap between the mount's face and the arms' bottom corner
under_wall   = 3;    // material above and below the groove
rail_z       = -20;  // back rail height on the arms; fits mounts from about 22 to 45 degrees

u_dir = [sin(under_tilt), -cos(under_tilt)];   // down the mount's face, toward the neck
u_out = [-cos(under_tilt), -sin(under_tilt)];  // out of the face, PD100 side

// The arms' curved backs; the mount's front face sits at the rearmost point.
function spine_back_y(x) = curve_radius - sqrt((curve_radius - y_back) ^ 2 - x ^ 2);
y_face = spine_back_y(arm_offset - arm_width / 2);
fill   = spine_back_y(arm_offset + arm_width / 2) - y_face + 0.3;

// The face passes just under the arms' bottom corner. The PD100 sits on it as
// high as it can while its front corner stays corner_below under the pod.
face_front = [y_face, -z_top - pod_clear];
up_face    = pd_up - (face_front[1] + shell_height / 2 + corner_below) / cos(under_tilt);
pd_corner  = face_front - up_face * u_dir;
top_z      = max(pd_corner[1], rail_z + dt_tip / 2 + dt_gap + under_wall);

module under_arm(side) {
    x_lo = arm_x_lo(side);
    swept(x_lo, x_lo + arm_width) clip_2d(c);
    // Back rail runs straight along the pod's width. The filler reaches forward
    // to where the curved back drifts away from the rail.
    translate([side * arm_offset, 0, 0]) extrude_x(arm_width) at([y_face, rail_z], [-1, 0]) {
        rail_2d();
        translate([-dt_root / 2, -fill]) square([dt_root, fill]);
    }
}

module under_mount_2d() {
    back_top = [pd_corner[0], top_z];
    pts = top_z > pd_corner[1] + 0.01
        ? [[y_face, top_z], face_front, pd_corner, back_top]
        : [[y_face, top_z], face_front, pd_corner];
    difference() {
        polygon(pts);
        at([y_face, rail_z], [-1, 0]) groove_2d(dt_gap);
    }
}

module under_mount() {
    difference() {
        extrude_x(mount_width) under_mount_2d();
        // Flare the groove at both ends so the tight fit starts onto the rail easily.
        for (m = [0, 1]) mirror([m, 0, 0])
            translate([mount_width / 2 - dt_lead_in, y_face, rail_z]) rotate([90, 0, 90])
                linear_extrude(dt_lead_in + 0.01, scale = 1.06) rotate(90) groove_2d(dt_gap - 0.02);
    }
}

module under_pd100() {
    extrude_x(pd_across) polygon([pd_corner, pd_corner + pd_up * u_dir,
                                  pd_corner + pd_up * u_dir + pd_thick * u_out, pd_corner + pd_thick * u_out]);
}

if (part == "under_arm_left")  on_side(arm_x_lo(-1)) under_arm(-1);
if (part == "under_arm_right") on_side(arm_x_lo(1)) under_arm(1);
if (part == "under_mount")     on_side(-mount_width / 2) under_mount();
if (part == "under_assembly") {
    color("dimgray") pod();
    color("steelblue") for (side = [-1, 1]) under_arm(side);
    color("darkorange") translate([explode, 0, 0]) under_mount();
    color("gold", 0.35) translate([explode, 0, 0]) under_pd100();
}
