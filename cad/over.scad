// Over mount: the PD100 lies over the top of the pod.
//   over_mount - slides onto the key on top of the clip's cap from one side
//       and carries a 40 mm platform that rises toward the face.
// Meant for relaxed use, so it sticks out behind the head as little as
// possible: a 60 degree platform lays the PD100 over the top so its thickness
// points up rather than back, and the platform starts right at the back of the
// key. Axes as in pod_dims.scad.
include <common.scad>

part = "over_assembly";  // over_assembly, over_mount

over_tilt    = 60;   // platform angle from vertical, upper end toward the face
platform_len = 40;   // flat platform, from its back end to the tip
back_reach   = 0;    // extends the platform back past the key, along the platform;
                     // raise it to move the PD100 back and down, away from the head
brace_drop   = 10;   // how far the brace under the platform reaches down the mount's front

o_dir = [sin(over_tilt), cos(over_tilt)];    // up the platform, toward the face
o_in  = [cos(over_tilt), -sin(over_tilt)];   // into the mount, toward the pod
o_out = -o_in;                               // out of the platform, PD100 side

zb    = key_top[1];                // key's base, on the clip's cap
z_tip = zb + dt_height + dt_gap;   // groove's ceiling

// The platform keeps mount_wall of material over the groove's rear corner and
// starts level with the mount's rear wall, or back_reach further back.
face_ref   = [key_top[0] - dt_tip / 2 - dt_gap, z_tip] - mount_wall * o_in;
face_rear  = face_ref + (y_rear_tip(key_top) - face_ref[0]) / sin(over_tilt) * o_dir;
pd_low     = face_rear - back_reach * o_dir;    // platform's back end and the PD100's lower edge
tip_top    = pd_low + (platform_len + back_reach) * o_dir;
tip_bottom = tip_top + plate_thick * o_in;
under_back = pd_low + plate_thick * o_in;       // underside at the back end, when it reaches back

z_under = tip_bottom[1] - (tip_bottom[0] - y_front_tip(key_top)) / tan(over_tilt);  // platform underside above the mount's front
z_brace = max(z_tip, z_under - brace_drop);

// Side profile: the groove block on the key, and the platform with a brace
// under it. The part above the groove is hollowed into a truss.
module over_mount_2d() {
    y_ft = y_front_tip(key_top);
    y_rt = y_rear_tip(key_top);
    front = z_brace > z_tip + 0.01 ? [[y_ft, z_tip], [y_ft, z_brace], tip_bottom]
                                    : [[y_ft, z_tip], tip_bottom];
    back = back_reach > 0 ? [pd_low, under_back, [y_rt, zb]] : [pd_low, [y_rt, zb]];
    difference() {
        polygon(concat([[y_front_base(key_top), zb]], front, [tip_top], back));
        offset(delta = -mount_wall) polygon(concat([[y_rt, z_tip]], front, [tip_top, face_rear]));
    }
}

module over_mount() { mount_body(key_top, 1) over_mount_2d(); }

module over_pd100() {
    extrude_x(pd_across) polygon([pd_low, pd_low + pd_up * o_dir,
                                  pd_low + pd_up * o_dir + pd_thick * o_out, pd_low + pd_thick * o_out]);
}

if (part == "over_mount") on_side(-mount_width / 2) over_mount();
if (part == "over_assembly") {
    color("dimgray") pod();
    color("steelblue") clip();
    color("darkorange") translate([explode, 0, 0]) over_mount();
    color("gold", 0.35) translate([explode, 0, 0]) over_pd100();
}
