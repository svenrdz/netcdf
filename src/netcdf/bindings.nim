when defined(windows):
  const
    libSuffix = ".dll"
    libPrefix = ""
elif defined(macosx):
  const
    libSuffix = ".dylib"
    libPrefix = "lib"
else:
  const
    libSuffix = ".so(||.15)"
    libPrefix = "lib"

const
  netcdf {.strdefine.} = "netcdf"
  ## TODO: allow more options
  libnetcdf = libPrefix & netcdf & libSuffix

const inf* = Inf

type
  NcType* {.size: sizeof(cint).} = enum
    NcNat = 0
    NcByte = 1
    NcChar = 2
    NcShort = 3
    NcInt = 4
    NcFloat = 5
    NcDouble = 6
    NcUByte = 7
    NcUShort = 8
    NcUInt = 9
    NcInt64 = 10
    NcUInt64 = 11
    NcString = 12
  nctype = NcType

const NcLong* = NcInt

{.push dynlib: libnetcdf.}

when defined(useFuthark):
  import std/os
  import futhark

  importc:
    outputPath currentSourcePath.parentDir / "generated.nim"
    path "../c_headers"
    "netcdf.h"
else:
  include "generated.nim"

# {.passL: "-lnetcdf".}
{.pop.}
