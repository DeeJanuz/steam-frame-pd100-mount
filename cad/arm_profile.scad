// Cross-section of the arms, in the (Y, Z) plane; see pod_dims.scad.
// Each arm wraps the whole pod: a thin spine lies on the head-side face, bars
// cross the top and bottom edges, and lips reach over the outer face. The bar
// that carries the rail has a long lip, hooked on first; the other bar has a
// short lip that snaps on last. Each bar steps down behind the outer shell's
// rim to fill the ledge at the seam.
//
// As printed, the spine bows toward the pod, which splays the bars open so
// the lips pass over the pod's edges. On the pod, the head-side face presses
// the spine flat. That closes the bars and keeps the lips pressed on the
// outer face, so the arm does not rattle.
include <pod_dims.scad>

rim_clearance = -2.2;   // room between each bar and the pod's edge; negative squeezes the pod
                        // (test prints: -2.2 fits well, -1.2 was loose)
fit_offset    = 0;      // test arms: changes the height between the bars by this much, split
                        // between the two bars; negative is tighter. Engraved on the rail.
spine_gap    = 0.2;    // spine to the head-side face, once pressed flat
spine_thick   = 1.65;
spine_bow     = 3.6;    // as printed, how far the spine bows toward the pod at mid-height
bar_thick     = 3.0;    // over the outer shell's rim
// Lips: [long lip on the rail's bar, short lip on the other bar].
lip_len       = [7.5, 5.0];   // how far each lip reaches down the outer face
lip_root      = [1.4, 1.1];   // thickness where each lip meets its bar
lip_tip       = [0.7, 1.1];   // thickness at each lip's tip
lip_lean      = [1.0, 0];     // how far each tip leans out from the outer face
step_gap_y    = 0.35;   // a bar's step to the back of the outer shell
step_gap_z    = 0.25;   // a bar to the top of the head-side part
inner_chamfer = 1.0;    // inside corner where the spine meets a bar
edge_chamfer  = 1.0;    // outside corners

// Clearance used for each bar, with a test arm's offset split between them.
bar_clearance = rim_clearance + fit_offset / 2;

// Underside of a bar over the outer shell, for a given rim clearance.
function z_bar(clearance) = shell_height / 2 + clearance;

y_spine_in  = total_thick_edge + spine_gap;
y_spine_out = y_spine_in + spine_thick;
y_step      = max(shell_thick_top, shell_thick_bottom) + step_gap_y;
z_head      = head_part_height / 2 + step_gap_z + bar_clearance;

// Where the spine meets a bar. With the spine bowed, each bar turns about this
// point by bow_angle, the slope at the end of the bowed spine.
pivot = [y_spine_in + spine_thick / 2, z_head - inner_chamfer];
function bow_angle(bow) = atan(2 * bow / pivot[1]);

// Rearmost point of an arm, with the spine flat: the back of a lip at its root
// or its leaning tip.
lip_back_y = min([for (i = [0, 1]) min(-lip_root[i], -lip_lean[i] - lip_tip[i])]);

// Upper bar and lip with the spine flat, from the pivot's height up. i = 0
// gives the long lip, i = 1 the short one.
module bar_2d(clearance, i) {
    zr = z_bar(clearance);
    zt = zr + bar_thick;
    z_tip = zr - lip_len[i];
    polygon([[y_spine_in, pivot[1] - 0.3],
             [y_spine_in, z_head - inner_chamfer],
             [y_spine_in - inner_chamfer, z_head],
             [y_step, z_head],
             [y_step, zr],
             [0, zr],
             [-lip_lean[i], z_tip],
             [-lip_lean[i] - lip_tip[i], z_tip],
             [-lip_root[i], zt - edge_chamfer],
             [-lip_root[i] + edge_chamfer, zt],
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

// Upper half, with lip i. The lower half is the same shape mirrored.
module arm_half_2d(clearance, bow, i) {
    spine_half_2d(bow);
    turn_bar(bow) bar_2d(clearance, i);
}

// An arm's cross-section with the long lip on top: bowed as printed
// (bow = spine_bow), or pressed flat on the pod (bow = 0).
module arm_2d(clearance, bow) {
    arm_half_2d(clearance, bow, 0);
    mirror([0, 1]) arm_half_2d(clearance, bow, 1);
}
