// Cross-section of the arms, in the (Y, Z) plane; see pod_dims.scad.
// Each arm wraps the whole pod: a thin spine lies on the head-side face, bars
// cross the top and bottom edges, and short lips reach over the outer face.
// Each bar steps down behind the outer shell's rim to fill the ledge at the seam.
//
// As printed, the spine bows toward the pod, which splays the bars open so
// the lips pass over the pod's edges. On the pod, the head-side face presses
// the spine flat. That closes the bars and keeps the lips pressed on the
// outer face, so the arm does not rattle.
include <pod_dims.scad>

spine_gap     = 0.2;    // spine to the head-side face, once pressed flat
spine_thick   = 2.0;
spine_bow     = 3.0;    // as printed, how far the spine bows toward the pod at mid-height
bar_thick     = 3.0;    // over the outer shell's rim
lip_thick     = 1.6;
lip_len       = 4.0;    // how far each lip reaches down the outer face
lip_ramp      = 1.0;    // lead-in at each lip's tip
step_gap_y    = 0.35;   // a bar's step to the back of the outer shell
step_gap_z    = 0.25;   // a bar to the top of the head-side part
inner_chamfer = 1.0;    // inside corner where the spine meets a bar
edge_chamfer  = 1.0;    // outside corners

// Underside of a bar over the outer shell, for a given rim clearance.
function z_bar(clearance) = shell_height / 2 + clearance;
// Outer face, modeled as a parabola from the edges (Y = 0) to the bulge at mid-height.
function outer_y(z) = -outer_bulge * (1 - pow(z / (shell_height / 2), 2));

y_spine_in  = total_thick_edge + spine_gap;
y_spine_out = y_spine_in + spine_thick;
y_step      = max(shell_thick_top, shell_thick_bottom) + step_gap_y;
z_head      = head_part_height / 2 + step_gap_z;

// Where the spine meets a bar. With the spine bowed, each bar turns about this
// point by bow_angle, the slope at the end of the bowed spine.
pivot = [y_spine_in + spine_thick / 2, z_head - inner_chamfer];
function bow_angle(bow) = atan(2 * bow / pivot[1]);

// Back of a lip at its tip, with the spine flat. The lips lean out to follow
// the bulge, so this is the rearmost point of an arm.
function lip_back_y(clearance) = outer_y(z_bar(clearance) - lip_len) - lip_thick;

// Top bar and lip with the spine flat, from the pivot's height up.
module bar_2d(clearance) {
    zr = z_bar(clearance);
    zt = zr + bar_thick;
    z_tip = zr - lip_len;
    y_tip = outer_y(z_tip);
    polygon([[y_spine_in, pivot[1] - 0.3],
             [y_spine_in, z_head - inner_chamfer],
             [y_spine_in - inner_chamfer, z_head],
             [y_step, z_head],
             [y_step, zr],
             [0, zr],
             [y_tip, z_tip + lip_ramp],
             [y_tip - lip_ramp, z_tip],
             [y_tip - lip_thick, z_tip],
             [-lip_thick, zt - edge_chamfer],
             [-lip_thick + edge_chamfer, zt],
             [y_spine_out - edge_chamfer, zt],
             [y_spine_out, zt - edge_chamfer],
             [y_spine_out, pivot[1] - 0.3]]);
}

// Upper half of the spine, bowed into a parabola that is flat at mid-height
// and reaches the pivot at bow_angle. Offsets are normal to the centerline, so
// the end matches the turned bar.
module spine_half_2d(bow) {
    n = 24;
    zp = pivot[1];
    function ctr(z) = pivot[0] - bow * (1 - pow(z / zp, 2));
    function nrm(z) = let(s = 2 * bow * z / (zp * zp)) [1, -s] / sqrt(1 + s * s);
    zs = [for (i = [0 : n]) -0.5 + (zp + 0.3 + 0.5) * i / n];
    polygon(concat([for (z = zs) [ctr(z), z] - spine_thick / 2 * nrm(z)],
                   [for (i = [n : -1 : 0]) [ctr(zs[i]), zs[i]] + spine_thick / 2 * nrm(zs[i])]));
}

// Turn 2D children about the pivot by the bow's angle, opening the bar.
module turn_bar(bow) {
    translate(pivot) rotate(-bow_angle(bow)) translate(-pivot) children();
}

// Top half. The bottom half is this mirrored.
module arm_half_2d(clearance, bow) {
    spine_half_2d(bow);
    turn_bar(bow) bar_2d(clearance);
}

// An arm's cross-section: bowed as printed (bow = spine_bow), or pressed flat
// on the pod (bow = 0).
module arm_2d(clearance, bow) {
    arm_half_2d(clearance, bow);
    mirror([0, 1]) arm_half_2d(clearance, bow);
}
