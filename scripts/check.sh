#!/usr/bin/env bash
set -euo pipefail

project_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$project_dir"

qt_bin_dir="${QT6_BIN_DIR:-/usr/lib/qt6/bin}"
node tests/tasks.test.cjs
node tests/strings.test.cjs
"$qt_bin_dir/qmllint" package/contents/ui/*.qml package/contents/config/config.qml preview.qml
QT_QPA_PLATFORM=offscreen QT_QUICK_BACKEND=software \
    "$qt_bin_dir/qmltestrunner" -input tests -import package/contents/ui
