// Hook cross-section of the arms: snaps over the pod's outer shell and catches
// behind the ledge at the seam. The profile lives in the (Y, Z) plane; see pod_dims.scad.
include <pod_dims.scad>

spine_gap   = outer_bulge + 1.0;   // spine clears the bulging outer face
spine_thick = 3.0;
bar_thick   = 3.0;
lip_thick   = 2.0;
lip_gap_y   = 0.35;                // lip to the back of the outer shell
lip_gap_z   = 0.25;                // lip tip to the head-side part
ramp_flat   = 0.5;                 // flat left at the lip tip before the lead-in ramp
gusset      = 1.5;                 // relief where the bars meet the spine

y_inner = -spine_gap;
y_back  = y_inner - spine_thick;
z_tip   = head_part_height / 2 + lip_gap_z;

// Inner face of the top bar for a given rim clearance.
function z_bar(clearance) = shell_height / 2 + clearance;
// Front face of a hook's lip.
function y_lip_out(shell_thick) = shell_thick + lip_gap_y + lip_thick;

// Top hook. The bottom hook is this mirrored.
module hook_2d(shell_thick, clearance) {
    zb = z_bar(clearance);
    y_lip_in = shell_thick + lip_gap_y;
    translate([y_back, zb]) square([y_lip_out(shell_thick) - y_back, bar_thick]);
    polygon([[y_lip_in, zb], [y_lip_out(shell_thick), zb],
             [y_lip_in + ramp_flat, z_tip], [y_lip_in, z_tip]]);
    polygon([[y_inner, zb], [y_inner + gusset, zb], [y_inner, zb - gusset]]);
}

// Spine plus top and bottom hooks.
module clip_2d(clearance) {
    zb = z_bar(clearance);
    translate([y_back, -zb - bar_thick]) square([spine_thick, 2 * (zb + bar_thick)]);
    hook_2d(shell_thick_top, clearance);
    mirror([0, 1]) hook_2d(shell_thick_bottom, clearance);
}
