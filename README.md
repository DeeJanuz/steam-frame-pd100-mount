# Steam Frame PD100 Mount

3D-printable mounts that hold a BoboVR PD100 (the PD100 dock with a B100 battery) on the rear battery pod of a Valve Steam Frame. Both mounts slide onto one clip that wraps around the pod:

- **Under mount:** hangs the PD100 below and behind the pod. It suits fast-paced games, since there is less movement low on the head.
- **Over mount:** lays the PD100 over the top of the pod at a flat angle. Very little sticks out behind your head, so you can lean back against a headrest.

| Under mount | Over mount |
|---|---|
| ![Under mount, section through the middle of the pod with the head to the right](images/under_side.png) | ![Over mount, section through the middle of the pod with the head to the right](images/over_side.png) |

Sections through the middle of the pod, with the head to the right. The pod is gray, the clip is blue, the mount is orange, and the PD100 is shown as a yellow block.

## How the clip works

The clip wraps the whole pod. A 2 mm spine lies flat against the side of the pod that faces your head. Bars cross the pod's top and bottom edges, and a short lip on each bar reaches over the pod's outer shell. Only the 1.6 mm lips sit on the back of the pod, and the mount rides on a dovetail rail along the pod's top or bottom edge.

The clip is printed with its spine bowed slightly toward the pod, which spreads the bars apart so the lips can pass over the pod's edges. Once the clip is on, the pod presses the spine flat. That pulls the bars closed and holds the lips against the outer shell, so the clip stays tight without rattling.

## What you need

- A Valve Steam Frame.
- A [BoboVR PD100 charging dock](https://www.amazon.com/dp/B0FLXQMPCS). This listing is the dock only, without a battery.
- A B100-style battery for the dock, such as this [DMMNS 10000 mAh two-pack](https://www.amazon.com/dp/B0FHK169RV), which is sold as a replacement for the BoboVR B100.
- 3M Command strips to hold the PD100 on the mount.

## Parts

![The clip and both mounts, as they sit on the print bed](images/parts.png)

| File | Quantity | Notes |
|---|---|---|
| `stl/clip.stl` | 1 | Wraps the pod and carries the dovetail rail |
| `stl/under_mount.stl` | 1 | For the under setup |
| `stl/over_mount.stl` | 1 | For the over setup |
| `stl/clip_test.stl` | optional | A 10 mm slice of the clip, without the rail, to check the fit first |

Print the clip and whichever mounts you want. The same clip works with either mount.

## Printing

- The STL files are already oriented. Every part prints on its side with no supports, so the layers run in the direction that carries the battery's weight and the clip's flex.
- PETG is recommended. PLA can soften over time from body heat and a warm battery, and the clip's spine stays slightly bent while it is on the pod.
- The clip prints 50 mm tall and the mounts print 55 mm tall.
- As solid plastic, the clip is about 18 cm³, the under mount about 24 cm³, and the over mount about 14 cm³. Your slicer will report the actual weight for your infill.
- Consider printing `clip_test.stl` first. It takes only about 3 cm³ and shows whether the clip will fit your pod.

## Assembly

### Fitting the clip

1. Turn the clip so its rail is on the edge you want: the bottom for the under setup, the top for the over setup.
2. With the spine against the side of the pod that faces your head, hook the clip's upper bar over the pod's top edge so its lip sits on the outer shell.
3. Press the lower half of the clip toward the pod until the lower lip snaps over the pod's bottom edge. The spine flattens against the pod as it goes on.
4. Slide the clip left or right until it is centered on the pod.

To take the clip off, pull the lower lip away from the outer shell and swing the lower half of the clip away from the pod.

### Under setup

1. Fit the clip with its rail along the pod's bottom edge.
2. Slide the under mount onto the rail from one side until it is centered. Its upper part sits just behind the pod's outer shell.
3. Stick the PD100 to the mount's angled face with 3M Command strips. The PD100's flat bottom goes against the mount, with the display edge toward the pod.

### Over setup

1. Fit the clip with its rail along the pod's top edge.
2. Slide the over mount onto the rail from one side until it is centered.
3. Stick the PD100 to the platform with Command strips, with its display edge at the back of the platform.

The dovetail fit is tight on purpose so the mount stays put by friction. If a mount will not slide on, lightly sand the sides of the rail, or increase `dt_gap` in `cad/common.scad` and reprint the mount.

## Fit and customizing

The pod measurements come from calipers on one Steam Frame and were checked with test prints of an earlier clip design. The wrap-around clip uses the same measurements, but its fit on the side of the pod that faces your head, the spine's bow, and the lips have not been checked with a print yet. The main numbers:

- The pod's outer shell is 87.0 mm tall at the seam, and the part that faces your head is 84.5 mm tall.
- The pod is 12.0 mm thick at the middle of its top and bottom edges, and the outer shell is about 6.5 mm of that.
- The outer shell bulges about 1.6 mm at mid-height. The clip's lips lean out slightly to follow it.
- Seen from above, the pod curves with a radius of about 117.5 mm.

The design is written in OpenSCAD. Settings you are most likely to change:

| File | Setting | What it does |
|---|---|---|
| `cad/pod_dims.scad` | all values | Pod measurements |
| `cad/common.scad` | `curve_radius` | Curve of the pod seen from above |
| `cad/common.scad` | `rim_clearance` | Extra room between the clip's bars and the pod's edges |
| `cad/common.scad` | `dt_gap` | Dovetail clearance per face |
| `cad/common.scad` | `clip_width`, `mount_width` | Clip and mount width across the pod (50 and 55 mm by default) |
| `cad/clip_profile.scad` | `spine_bow` | How far the spine bows toward the pod as printed (3 mm by default). More bow makes the clip easier to fit and grip harder. |
| `cad/clip_profile.scad` | `lip_len` | How far each lip reaches over the outer shell (4 mm by default) |
| `cad/clip_profile.scad` | `spine_thick`, `spine_gap` | Spine thickness, and its clearance to the pod once flat |
| `cad/under.scad` | `under_tilt` | Angle of the under mount's face, from vertical (30 by default) |
| `cad/under.scad` | `corner_below` | How far below the pod the PD100's front corner may reach. This is the part that can touch your neck when you look up. |
| `cad/over.scad` | `over_tilt` | Angle of the over mount's platform, from vertical (60 by default) |
| `cad/over.scad` | `platform_len` | Platform length from its back end to the tip (40 mm by default) |
| `cad/over.scad` | `back_reach` | Moves the PD100 back and down along the platform, away from your head (0 by default) |

## Building the STL files

Use a recent OpenSCAD development snapshot. From the repository folder:

```sh
openscad -D 'part="clip"'        -D print=true -o stl/clip.stl        cad/clip.scad
openscad -D 'part="clip_test"'   -D print=true -o stl/clip_test.stl   cad/clip.scad
openscad -D 'part="under_mount"' -D print=true -o stl/under_mount.stl cad/under.scad
openscad -D 'part="over_mount"'  -D print=true -o stl/over_mount.stl  cad/over.scad
```

Opening `cad/under.scad` or `cad/over.scad` in OpenSCAD without any settings shows the assembly with the pod and a block the size of the PD100. Opening `cad/clip.scad` shows the clip on the pod next to the clip as printed.

## Disclaimer

This project is not affiliated with Valve or BoboVR. It holds a lithium battery on your head, so check the fit and the Command strips before each session, and stop using it if anything cracks or loosens.

## License

MIT. See [LICENSE](LICENSE).
