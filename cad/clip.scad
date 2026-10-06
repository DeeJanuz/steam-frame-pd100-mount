// The clip that holds either mount on the Steam Frame's battery pod.
//   clip      - wraps the pod from the head side and carries one dovetail rail.
//               Worn rail up for the over mount, upside down for the under mount.
//   clip_test - a 10 mm slice of the clip without the rail, to check the fit
//               before printing the whole clip.
// Both print with the spine bowed (see clip_profile.scad). Opening this file
// without settings shows the clip as printed, next to the clip on the pod.
// Axes as in pod_dims.scad.
include <common.scad>

part = "clip_assembly";  // clip_assembly, clip, clip_test

test_width = 10;

if (part == "clip")      on_side(-clip_width / 2) clip(spine_bow);
if (part == "clip_test") on_side(-test_width / 2) extrude_x(test_width) clip_2d(c, spine_bow);
if (part == "clip_assembly") {
    color("dimgray") pod();
    color("steelblue") clip();
    color("lightsteelblue") translate([pod_width / 2 + clip_width / 2 + 20, 0, 0]) clip(spine_bow);
}
