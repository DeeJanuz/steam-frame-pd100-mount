// The clip that holds either mount on the Steam Frame's battery pod. It is
// SpanishPotato's Steam Frame back clip
// (https://www.patreon.com/SpanishPotato/posts/steam-frame-back-171534740)
// with its two slots filled and our dovetail key added in place of one of
// them: on top of the cap for the over mount, or under the bottom block for
// the under mount. Everything else is the original: the cap and its long lip
// over the pod's top edge, the slit under the cap that lets the spine flex,
// the spine on the head side with its two windows, the pegs, and the bottom
// block and short lip, which leave the head side of the pod's bottom edge
// free for the cushion. ref/SteamFrameBackClip.stl is that file merged into
// one solid. Not covered by this project's MIT license. Axes as in
// pod_dims.scad.
include <common.scad>

part = "clip_assembly";  // clip_assembly, clip_over, clip_under

// clip_over has only the key on top, for the over mount; clip_under has only
// the key underneath, for the under mount. Both print upright like the
// original, standing on the bottom block or the bottom key.
// key_bot[1] is the height of the bottom block's underside.
if (part == "clip_over") translate([0, 0, print ? -key_bot[1] : 0]) clip(bottom = false);
if (part == "clip_under") translate([0, 0, print ? dt_height - key_bot[1] : 0]) clip(top = false);
if (part == "clip_assembly") {
    color("dimgray") pod();
    color("steelblue") clip();
}
