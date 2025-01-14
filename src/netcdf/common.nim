import std/strutils
import ./bindings

type
  NcId* = cint
  NetcdfError* = object of CatchableError
  OpenMode* {.size: sizeof(cint).} = enum
    omRead = NC_NOWRITE # read-only
    omWrite = NC_WRITE
    omShare = NC_SHARE
    omWriteShare = NC_WRITE or NC_SHARE

  CreateMode* = enum
    cmClobber = NC_CLOBBER
    cmNoClobber = NC_NOCLOBBER
    cmClassicModel = NC_CLASSIC_MODEL
    cm64BitOffset = NC_64BIT_OFFSET
    cmShare = NC_SHARE
    cmNetcdf4 = NC_NETCDF4

  Dataset* = object
    id*: NcId = -1
    vars*: seq[Variable]
    dims*: seq[Dimension]
    atts*: seq[Attribute]
    unlimdimidp*: int

  Variable* = object
    dsid*: NcId = -1
    id*: int = -1
    name*: string
    dims*: seq[Dimension]
    atts*: seq[Attribute]
    xtype*: NcType
    # case xtype*: NcType
    # of NcDouble:
    #   doubleVal*: seq[cdouble]
    # of NcFloat:
    #   floatVal*: seq[cfloat]
    # else: discard

  Dimension* = object
    id*: int = -1
    name*: string
    size*: uint

  Attribute* = object
    vid*: int = -1
    name*: string
    size*: uint
    case xtype*: NcType
    of NcNat:
      discard
    of NcByte:
      byteVal*: int8
    of NcChar:
      strVal*: string
    of NcShort:
      shortVal*: int16
    of NcInt:
      intVal*: int32
    of NcFloat:
      floatVal*: cfloat
    of NcDouble:
      doubleVal*: cdouble
    of NcUByte:
      ubyteVal*: uint8
    of NcUShort:
      ushortVal*: uint16
    of NcUInt:
      uintVal*: uint32
    of NcInt64:
      int64Val*: int64
    of NcUInt64:
      uint64Val*: uint64
    of NcString:
      stringsVal*: seq[string]

template handleError*(body: untyped) =
  let retval: cint = body
  if retval != 0:
    {.line: instantiationInfo().}:
      raise NetcdfError.newException do:
        dedent"""

        $1 [$2]
        $3
        """ %
          [$retval.ncstrerror, $retval, body.astToStr]
