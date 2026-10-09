# Changes the clip's outline as seen from the head side. SpanishPotato's clip
# is a trapezoid whose half-width at height z is A - B*z, about 15.5 mm at the
# cap and 30 mm at the bottom. This stretches or squeezes every height across
# the pod (X) to a new half-width, and slides each point along the pod's curve
# so whatever touches the pod stays on it. The cross-section at each height is
# unchanged, so the cap, slit, spine, lips, and bottom block keep their shape.
#
#   wide_top - upside down: half-width A + B*z, wide at the cap and narrow at
#              the bottom.
#   straight - the bottom's width all the way up. Below the end bars, where the
#              original is wider still, it is left as it is.
#
# Input is the clip with both slots filled and no key, in pod axes:
#   openscad -D 'part="clip_filled"' -o /tmp/clip_filled.stl cad/clip.scad
#   python cad/ref/reshape.py wide_top /tmp/clip_filled.stl cad/ref/SteamFrameBackClip_wide_top.stl
#   python cad/ref/reshape.py straight /tmp/clip_filled.stl cad/ref/SteamFrameBackClip_straight.stl
# Needs numpy, trimesh, and manifold3d.
import sys

import manifold3d as mf
import numpy as np
import trimesh

A, B = 22.85, 0.1536   # the original's half-width at height z is A - B*z
Z_BARS = -43.0         # height of the end bars under the pod's bottom edge
R = 117.5              # curve_radius in common.scad


def half_width(z, shape):
    if shape == "wide_top":
        return A + B * z
    if shape == "straight":
        return np.maximum(A - B * z, A - B * Z_BARS)
    sys.exit(f"unknown shape {shape}")


def sag(x):
    """How far the pod's curve bends toward the head at X = x."""
    return R - np.sqrt(R * R - x * x)


shape, src, dst = sys.argv[1], sys.argv[2], sys.argv[3]


def remap(v):
    x, y, z = v[:, 0], v[:, 1], v[:, 2]
    x2 = x * half_width(z, shape) / (A - B * z)
    return np.c_[x2, y - sag(x) + sag(x2), z]


m = trimesh.load(src, force='mesh')
clip = mf.Manifold(mf.Mesh(vert_properties=np.asarray(m.vertices, dtype=np.float32),
                           tri_verts=np.asarray(m.faces, dtype=np.uint32)))
# Short edges so the stretch and the curve stay smooth.
clip = clip.refine_to_length(2.0).warp_batch(remap)
out = clip.to_mesh()
t = trimesh.Trimesh(vertices=out.vert_properties[:, :3], faces=out.tri_verts)
print("watertight", t.is_watertight, "bodies", len(t.split()), "volume", round(t.volume, 1),
      "bounds", np.round(t.bounds, 2).tolist())
t.export(dst)
