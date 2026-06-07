#!/usr/bin/env python3
"""Compute bounding box dimensions of a ligand from an SDF file."""

import sys
import numpy as np
from rdkit import Chem


def compute_bounding_box(sdf_path: str) -> dict[str, float]:
    mol = Chem.MolFromMolFile(sdf_path, removeHs=False)
    if mol is None:
        raise ValueError(f"Failed to parse SDF file: {sdf_path}")

    conf = mol.GetConformer()
    coords = np.array([conf.GetAtomPosition(i) for i in range(mol.GetNumAtoms())])

    extents = coords.max(axis=0) - coords.min(axis=0)
    center  = coords.mean(axis=0)

    dims = {
        "x": float(extents[0]),
        "y": float(extents[1]),
        "z": float(extents[2]),
    }
    return dims, center


if __name__ == "__main__":
    sdf_path = sys.argv[1] if len(sys.argv) > 1 else "imatinib-smiles.sdf"

    dims, center = compute_bounding_box(sdf_path)

    rows = [
        ("x_extent", dims["x"]),
        ("y_extent", dims["y"]),
        ("z_extent", dims["z"]),
        ("x_center", center[0]),
        ("y_center", center[1]),
        ("z_center", center[2]),
    ]

    print("\t".join(("Name", "Value")))
    for name, value in rows:
        print(f"{name}\t{value:.3f}")
