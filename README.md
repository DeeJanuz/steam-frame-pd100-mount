# Steam Frame PD100 Mount

3D-printable mounts that hold a BoboVR PD100 (the PD100 dock with a B100 battery) on the rear battery pod of a Valve Steam Frame. Each mount slides onto a dovetail key on a clip that wraps around the pod and leaves room for the rear cushion:

- **Under mount:** hangs the PD100 below and behind the pod. It suits fast-paced games, since there is less movement low on the head.
- **Over mount:** lays the PD100 over the top of the pod at a flat angle. Very little sticks out behind your head, so you can lean back against a headrest.

| Under mount | Over mount |
|---|---|
| ![Under mount, section through the middle of the pod with the head to the right](images/under_side.png) | ![Over mount, section through the middle of the pod with the head to the right](images/over_side.png) |

Sections through the middle of the pod, with the head to the right. The pod is gray, the clip is blue, the mount is orange, and the PD100 is shown as a yellow block. The clip is drawn as printed, so its spine overlaps the pod.

## How the clip works

The clip is a remix of [SpanishPotato's Steam Frame back clip](https://www.patreon.com/SpanishPotato/posts/steam-frame-back-171534740), whose file is in `cad/ref/SteamFrameBackClip.stl`. Only its attachment is changed: its two slots are filled in, and our 30 mm dovetail key takes the place of one of them. Everything else is as in that file:

- A cap with a long lip hooks over the pod's top edge.
- A thin spine runs down the side of the pod that faces your head. It has two windows, and a slit under the cap lets it flex.
- At the bottom, a block with a short lip hooks only the outer shell's bottom edge. Legs at the clip's ends join it to the spine. In the middle, the head side of the pod's bottom edge stays free, so the rear cushion can go back on.
- Three small pegs face the pod from the spine and legs.

There are two versions. `clip_over` has the key on top of the cap for the over mount, and `clip_under` has it under the bottom block for the under mount. Each mount slides onto its key from the side.

## What you need

- A Valve Steam Frame.
- A [BoboVR PD100 charging dock](https://www.amazon.com/dp/B0FLXQMPCS). This listing is the dock only, without a battery.
- A B100-style battery for the dock, such as this [DMMNS 10000 mAh two-pack](https://www.amazon.com/dp/B0FHK169RV), which is sold as a replacement for the BoboVR B100.
- 3M Command strips to hold the PD100 on the mount.

## Parts

![Both clips and both mounts, as they sit on the print bed](images/parts.png)

| File | Quantity | Notes |
|---|---|---|
| `stl/clip_under.stl` | 1 | Clip with the key underneath, for the under setup |
| `stl/clip_over.stl` | 1 | Clip with the key on top, for the over setup |
| `stl/under_mount.stl` | 1 | For the under setup |
| `stl/over_mount.stl` | 1 | For the over setup |

Print the clip and mount for the setup you want, or both pairs.

## Printing

- The STL files are already oriented.
- The clips print upright like the original file, 100 mm tall: `clip_over` stands on its bottom block and `clip_under` on its key. They need supports under the end bars at the bottom, under the tip of the long lip, and under the cap. If supports end up in the slit under the cap, clear them out completely, since the spine flexes there.
- The mounts print on their side with no supports, 55 mm tall, so the layers run in the direction that carries the battery's weight.
- PETG is recommended. PLA can soften over time from body heat and a warm battery.
- As solid plastic, each clip is about 11.5 cm³, the under mount about 26 cm³, and the over mount about 14 cm³. Your slicer will report the actual weight for your infill.

## Assembly

### Fitting the clip

1. With the spine against the side of the pod that faces your head, hook the cap's long lip over the pod's top edge.
2. Press the bottom of the clip toward the pod until the short lip snaps over the outer shell's bottom edge.
3. Center the clip on the pod.

### Under setup

1. Fit `clip_under`.
2. Slide the under mount onto the key under the clip from one side until it is centered. Its upper part sits just behind the pod's outer shell.
3. Stick the PD100 to the mount's angled face with 3M Command strips. The PD100's flat bottom goes against the mount, with the display edge toward the pod.

### Over setup

1. Fit `clip_over`.
2. Slide the over mount onto the key on top of the clip from one side until it is centered.
3. Stick the PD100 to the platform with Command strips, with its display edge at the back of the platform.

The dovetail fit is tight on purpose so the mount stays put by friction. If a mount will not slide on, lightly sand the sides of the key, or increase `dt_gap` in `cad/common.scad` and reprint the mount.

## Fit and customizing

The clip's fit is the original file's and has not been changed. The pod measurements come from calipers on one Steam Frame and place the mounts and the assembly views. The main numbers:

- The pod's outer shell is 87.0 mm tall at the seam, and the part that faces your head is 84.5 mm tall.
- The pod is 12.0 mm thick at the middle of its top and bottom edges, and the outer shell is about 6.5 mm of that.
- The outer shell bulges about 1.6 mm at mid-height.
- Seen from above, the pod curves with a radius of about 117.5 mm.

The design is written in OpenSCAD. Settings you are most likely to change:

| File | Setting | What it does |
|---|---|---|
| `cad/pod_dims.scad` | all values | Pod measurements |
| `cad/common.scad` | `curve_radius` | Curve of the pod seen from above |
| `cad/common.scad` | `dt_gap` | Dovetail clearance per face |
| `cad/common.scad` | `mount_width` | Mount width (55 mm by default) |
| `cad/common.scad` | `key_len` | Length of the key on the clip (30 mm by default) |
| `cad/under.scad` | `under_tilt` | Angle of the under mount's face, from vertical (30 by default) |
| `cad/under.scad` | `corner_below` | How far below the pod the PD100's front corner may reach. This is the part that can touch your neck when you look up. |
| `cad/over.scad` | `over_tilt` | Angle of the over mount's platform, from vertical (60 by default) |
| `cad/over.scad` | `platform_len` | Platform length from its back end to the tip (40 mm by default) |
| `cad/over.scad` | `back_reach` | Moves the PD100 back and down along the platform, away from your head (0 by default) |

## Building the STL files

Use a recent OpenSCAD development snapshot. From the repository folder:

```sh
openscad -D 'part="clip_under"'  -D print=true -o stl/clip_under.stl  cad/clip.scad
openscad -D 'part="clip_over"'   -D print=true -o stl/clip_over.stl   cad/clip.scad
openscad -D 'part="under_mount"' -D print=true -o stl/under_mount.stl cad/under.scad
openscad -D 'part="over_mount"'  -D print=true -o stl/over_mount.stl  cad/over.scad
```

Opening `cad/under.scad` or `cad/over.scad` in OpenSCAD without any settings shows the assembly with the pod and a block the size of the PD100. Opening `cad/clip.scad` shows the clip on the pod with both keys.

## Disclaimer

This project is not affiliated with Valve or BoboVR. It holds a lithium battery on your head, so check the fit and the Command strips before each session, and stop using it if anything cracks or loosens.

## License

MIT. See [LICENSE](LICENSE). The MIT license does not cover SpanishPotato's clip: `cad/ref/SteamFrameBackClip.stl` and the clip STLs built from it (`stl/clip_over.stl` and `stl/clip_under.stl`). See the [original post](https://www.patreon.com/SpanishPotato/posts/steam-frame-back-171534740) for its terms.
