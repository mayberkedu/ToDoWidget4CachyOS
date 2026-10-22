#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
mkdir -p "$project_dir/dist"
python3 - "$project_dir" <<'PY'
from pathlib import Path
import sys
from zipfile import ZIP_DEFLATED, ZipFile

root = Path(sys.argv[1])
destination = root / "dist/cachy-todo.plasmoid"
with ZipFile(destination, "w", ZIP_DEFLATED) as archive:
    for item in sorted((root / "package").rglob("*")):
        if item.is_file():
            archive.write(item, item.relative_to(root / "package"))
    if not (root / "package/LICENSE").is_file():
        archive.write(root / "LICENSE", "LICENSE")
print(destination)
PY
