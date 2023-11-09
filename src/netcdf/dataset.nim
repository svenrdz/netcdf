import std/[
  strformat,
  sugar,
  os,
]
import ./[
  bindings,
  common,
  variable,
  dimension,
  attribute,
]


proc open*[T: Dataset](_: type T,
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
  # echo "open ", result.id

proc close*(ds: Dataset) =
  handleError:
    ncClose(ds.id)
  # echo "close ", ds.id

func `[]`*(ds: Dataset, name: string): Variable =
  var found = false
  for v in ds.vars:
    if v.name == name:
      result = v
      found = true
      break
  if not found:
    raise KeyError.newException(fmt"{name} is not a variable.")
