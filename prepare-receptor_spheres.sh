#!/usr/bin/env bash
# Select a sphere for pocket $1, then compute its bounding box.
# Usage: prepare-receptor_spheres.sh <pdb_file> <output_dir> <pocket> <sphere_number_1based>

if [ $# -lt 4 ]; then
  echo "Usage: $0 <pdb_file> <output_dir> <pocket> <sphere_number_1based>"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Pocket is 0-indexed in pocket-spheres.tsv; allow 1-based input like prepare-receptor.sh.
POCKET=$3
SPHERE=$4

# Support 1-based sphere input: if decrementing still matches a row, prefer that value.
if awk -F'\t' 'NR>1 && $2 == '$((SPHERE - 1))' { found=1; exit } END { exit !found }' "$SCRIPT_DIR/pocket-spheres.tsv"; then
  SPHERE=$((SPHERE - 1))
fi

# Look up pocket and sphere to confirm they exist
if ! grep -qP "^${POCKET}\t${SPHERE}\t" "$SCRIPT_DIR/pocket-spheres.tsv"; then
  echo "Error: no entry with pocket=$POCKET, sphere=$SPHERE in pocket-spheres.tsv"
  exit 1
fi

# Compute the bounding box (center_x center_y center_z side_x side_y side_z)
read -r BOX_CENTER_X BOX_CENTER_Y BOX_CENTER_Z BOX_SIDE_X BOX_SIDE_Y BOX_SIDE_Z \
  < <(python3 "$SCRIPT_DIR/sphere-box.py" "$POCKET" "$SPHERE")

mk_prepare_receptor.py --read_pdb "$1" -o "$2" \
  -p -v --box_size "$BOX_SIDE_X" "$BOX_SIDE_Y" "$BOX_SIDE_Z" --box_center "$BOX_CENTER_X" "$BOX_CENTER_Y" "$BOX_CENTER_Z"
