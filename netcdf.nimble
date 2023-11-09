# Package

version       = "0.1.0"
author        = "Vindaar"
description   = "NetCDF bindings for Nim"
license       = "MIT"
srcDir        = "src"
skipDirs      = @["c_headers", "examples"]

# Dependencies

requires "nim >= 2.1.1"

requires "futhark >= 0.12.0"
requires "https://github.com/treeform/jsony#head"
