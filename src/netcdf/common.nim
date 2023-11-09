import std/strutils
import ./bindings

type
  NcId* = cint
  NetcdfError* = object of CatchableError
  OpenMode* = enum
    omRead = NC_NOWRITE # read-only
    omWrite = NC_WRITE
    omShare = NC_SHARE
    omWriteShare = NC_WRITE or NC_SHARE

  Dataset* = object
    id*: NcId
    vars*: seq[Variable]
    dims*: seq[Dimension]
    atts*: seq[Attribute]
    unlimdimidp*: int
  Variable* = object
    dsid*: NcId
    id*: int
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
    id*: int
    name*: string
    size*: uint
  Attribute* = object
    vid*: int
    name*: string
    size*: uint
    case xtype*: NcType
    of NcByte:
      byteVal*: byte
    of NcChar:
      strVal*: string
    of NcShort:
      shortVal*: cshort
    of NcInt:
      intVal*: cint
    of NcFloat:
      floatVal*: cfloat
    of NcDouble:
      doubleVal*: cdouble
    else: discard

template handleError*(body: untyped) =
  let retval: cint = body
  if retval != 0:
    {.line: instantiationInfo().}:
      raise NetcdfError.newException:
        dedent"""

        $1 [$2]
        $3
        """ % [$retval.ncstrerror, $retval, body.astToStr]

# proc id*(ds: Dataset): lent NcId = ds.id
# proc `id=`*(ds: var Dataset, id: NcId) = ds.id = id

# macro handleError*(body: untyped): untyped =
#   let
#     info = body.lineInfo
#     bodyCopy = body.copyNimTree
#     bodyStr = bodyCopy.repr
#   genAst(bodyCopy, bodyStr, info):
#     let retval: cint = bodyCopy
#     if retval != 0:
#       raise NetcdfError.newException:
#         dedent"""


# proc handleError*(retval: cint) =
#   # let retval: cint = body
#   if retval != 0:
#     raise newException(NetcdfError, "Error " & $retval & ": " &
#         $retval.ncstrerror)
