// The clip-on arms that hold either mount on the Steam Frame's battery pod.
//   arm_left, arm_right - each wraps the pod from the head side and carries a
//       dovetail rail. Worn rail up for the over mount, or upside down for the
//       under mount, which moves each arm to the other side.
// Both print with the spine bowed (see arm_profile.scad). Opening this file
// without settings shows the arms on the pod, next to the arms as printed.
// Axes as in pod_dims.scad.
include <common.scad>

part = "arms_assembly";  // arms_assembly, arm_left, arm_right

if (part == "arm_left")  on_side(arm_x_lo(-1)) arm(-1, spine_bow);
if (part == "arm_right") on_side(arm_x_lo(1)) arm(1, spine_bow);
if (part == "arms_assembly") {
    color("dimgray") pod();
    color("steelblue") arms();
    color("lightsteelblue") translate([pod_width + 20, 0, 0]) arms(spine_bow);
}
