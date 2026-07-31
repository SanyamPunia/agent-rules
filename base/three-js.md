# Three.js and React Three Fiber rules

Opt-in. Import from a project's `CLAUDE.md`.

## Geometry and materials

- **Always `BufferGeometry` with `Float32BufferAttribute`** for custom meshes. Never hand-roll the legacy geometry class.
- **`MeshStandardMaterial` with `vertexColors: true`** is the default for colored meshes. Switch to a `map` texture for atlas mode.
- **Nearest-neighbour textures for pixel art and atlases:** set `magFilter` and `minFilter` to `NearestFilter` and disable mipmaps. Anything else blurs the source.

## Lifecycle

- **Always dispose** textures, geometries, materials, and renderers when a scene is temporary, such as an offscreen exporter scene. A leak here is memory creep the user feels as a slow tab.
- **The R3F canvas remounts on a camera type change.** Switch orthographic and perspective by passing the flag plus the matching camera props, never by swapping camera children.

## Export

- **One file per output format,** each exporting a single `exportXxx(...)` function.
- **Every exporter registers in one table** with its label, group, capability flags, and a note. The table is what the UI renders, so an unregistered exporter does not exist.
- **Exporters consume already-computed data.** Mesh exports take the shared mesh result, voxel exports take the shared voxel result. Never re-derive geometry inside an exporter.
- **Canvas to PNG goes through `canvas.toBlob(...)`,** not `toDataURL`, which builds a large string and wastes memory.
- **One download pattern:**
  ```ts
  const url = URL.createObjectURL(blob);
  const a = document.createElement('a');
  a.href = url; a.download = filename; a.click();
  URL.revokeObjectURL(url);
  ```
  Always revoke.
