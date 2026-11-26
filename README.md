# 3D Printing

A personal collection of [OpenSCAD](https://openscad.org) scripts and exported STL files for 3D-printed objects: clips, cases, plant hangers, measuring cups, Fitbit bands, printer parts, and similar household or workshop items.

Use this repo if you want to print one of these models as-is, or open a `.scad` file and change the parameters before you export a new STL.

## What you need

- [OpenSCAD](https://openscad.org/downloads.html) (any recent release)
- A 3D printer, or a slicing program such as PrusaSlicer or Cura, to turn an STL into g-code

## Get started

```bash
git clone https://github.com/laird/3DPrinting.git
cd 3DPrinting
```

1. Open a `.scad` file in OpenSCAD (for example `AirPlantHoop.scad` or `CableLockdown.scad`).
2. Adjust any parameters at the top of the file.
3. Choose **Design → Render** (F6), then **File → Export → Export as STL**.
4. Open the STL in your slicer and print it.

Ready-made `.stl` files in the repo can go straight into a slicer. Prefer regenerating them from the matching `.scad` file when one exists, so your print matches the current script.

## License

This repository currently has an empty `LICENSE` file. Add a real license (for example [MIT](https://choosealicense.com/licenses/mit/) or [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/) for the models) before treating the designs as reusable by others.

## Notes

- Some filenames contain typos (`AirPlandHoop.stl`, `FirbitBandSolid-200m.stl`). They are the same models as the correctly spelled neighbors.
- A file named `Comcast payment Jan 2014.pdf` is in the repo root. It does not belong with the models and should be removed from the public tree.
