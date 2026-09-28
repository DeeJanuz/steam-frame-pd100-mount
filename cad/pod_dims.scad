// Steam Frame rear battery pod, caliper measurements in mm.
// Axes: Z = pod height (up when worn), Y = thickness (+Y toward the head),
// X = width. The outer face at the top/bottom edge centers sits at Y = 0.

pod_width          = 120.4; // left to right (an earlier reading gave 121.8)
shell_height       = 87.0;  // outer shell, top to bottom, at the seam
head_part_height   = 84.5;  // head-side part, top to bottom
shell_thick_top    = 6.5;   // outer face to seam, top edge center
shell_thick_bottom = 6.4;   // outer face to seam, bottom edge center
shell_thick_ends   = 6.1;   // outer face to seam, left/right ends
total_thick_edge   = 12.0;  // outer face to head-side face, edge centers
total_thick_middle = 13.6;  // same, middle of the pod

outer_bulge = total_thick_middle - total_thick_edge; // outer face bulge at mid-height
ledge       = (shell_height - head_part_height) / 2; // outer shell overhang, per edge
