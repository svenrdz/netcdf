import std/sugar
import ./[
  bindings,
  common,
  variable,
  dimension,
  attribute,
]


proc open*(_: type Dataset,
           path: string,
           mode = omRead): Dataset =
  handleError:
    ncOpenProc(path.cstring, mode.cint, result.id.addr)
  var
    ndim: cint
    nvar: cint
    natt: cint
    unlimdimidp: cint
  handleError:
    ncinq(result.id, ndim.addr, nvar.addr,
          natt.addr, unlimdimidp.addr)
  # sleep 1
  result.dims = collect:
    for dimId in 0..<ndim:
      result.getDim(dimId)
  result.vars = collect:
    for varId in 0..<nvar:
      result.getVar(varId)
  result.atts = collect:
    for attId in 0..<natt:
      getAtt(result.id, Ncglobal, attId)
  result.unlimdimidp = unlimdimidp

proc create*(_: type Dataset,
           path: string,
           mode = cmClobber): Dataset =
  handleError:
    ncCreateProc(path.cstring, mode.cint, result.id.addr)

proc endDef*(ds: Dataset) =
  handleError:
    ncenddefproc(ds.id)

template define*(ds: Dataset, body: untyped): untyped =
  body
  ds.endDef()

proc close*(ds: Dataset) =
  handleError:
    ncClose(ds.id)

