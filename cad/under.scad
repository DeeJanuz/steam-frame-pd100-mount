// Under mount: the PD100 hangs below and behind the Steam Frame's battery pod.
// Best for fast-paced games, since there is less movement low on the head.
//   under_mount - slides onto the key under the clip's bottom block from one
//       side. Its angled face carries
//       the PD100 with the display edge facing up, and its upper part sits just
//       behind the pod's outer face.
// The face passes as close to the pod as the groove allows. Two numbers set
// the platform: its angle, and how far below the pod the PD100's front corner
// (the part that can reach the neck) is allowed to go. Axes as in pod_dims.scad.
include <common.scad>

part = "under_assembly";  // under_assembly, under_mount

under_tilt   = 30;   // PD100 lean from vertical, lower edge toward the neck
corner_below = 25;   // PD100's lowest front corner, mm below the pod's bottom edge
pod_gap      = 0.3;  // mount to the clip's lips and the pod's outer face

u_dir = [sin(under_tilt), -cos(under_tilt)];   // down the mount's face, toward the neck
u_out = [-cos(under_tilt), -sin(under_tilt)];  // out of the face, PD100 side

zb      = key_bot[1];                // key's base, under the clip's bottom block
z_tip   = zb - dt_height - dt_gap;   // groove's floor
z_floor = z_tip - mount_wall;        // bottom of the mount

// The face keeps mount_wall of material behind the groove's rear corner.
face_ref = [key_bot[0] - dt_tip / 2 - dt_gap, z_tip] + mount_wall * u_out;
function face_at(z) = face_ref + (face_ref[1] - z) / cos(under_tilt) * u_dir;

// The PD100 sits on the face as high as it can while its front corner stays
// corner_below under the pod.
pd_corner = face_at(-shell_height / 2 - corner_below) - pd_up * u_dir;   // its upper end
y_wedge   = min(clip_back_y, -outer_bulge) - pod_gap;                   // upper part's side facing the pod

// Side profile: the groove block under the pod, and a triangle above it that
// carries the face up behind the pod. The triangle is hollowed into a truss.
module under_mount_2d() {
    wedge = [pd_corner, [y_wedge, pd_corner[1]], [y_wedge, zb], face_at(zb)];
    difference() {
        polygon([[y_front_base(key_bot), zb],
                 [y_front_tip(key_bot), z_tip],
                 [y_front_tip(key_bot) - mount_wall, z_floor],
                 face_at(z_floor),
                 pd_corner,
                 [y_wedge, pd_corner[1]],
                 [y_wedge, zb]]);
        offset(delta = -mount_wall) polygon(wedge);
    }
}

module under_mount() { mount_body(key_bot, -1) under_mount_2d(); }

module under_pd100() {
    extrude_x(pd_across) polygon([pd_corner, pd_corner + pd_up * u_dir,
                                  pd_corner + pd_up * u_dir + pd_thick * u_out, pd_corner + pd_thick * u_out]);
}

if (part == "under_mount") on_side(-mount_width / 2) under_mount();
if (part == "under_assembly") {
    color("dimgray") pod();
    color("steelblue") clip();
    color("darkorange") translate([explode, 0, 0]) under_mount();
    color("gold", 0.35) translate([explode, 0, 0]) under_pd100();
}
