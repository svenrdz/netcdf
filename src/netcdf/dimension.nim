import ./[
  bindings,
  common,
]

func getDim*(ds: Dataset, dimId: int): Dimension =
  result.id = dimId
  result.name.setLen(Ncmaxname)
  handleError:
    ncinqdim(ds.id, dimId.NcId,
             result.name.cstring,
             result.size.addr)
  result.name.setLen(result.name.cstring.len)

func dim*(ds: Dataset, name: string): Dimension =
  for d in ds.dims:
    if d.name == name:
      result = d
      break
  if result.id == -1:
    raise ValueError.newException($result)

func add*(ds: var Dataset, dim: Dimension) =
  var
    dimId: cint
    dim = dim
  handleError:
    ncdefdim(ds.id, dim.name.cstring, dim.size, dimId.addr)
  dim.id = dimId
  ds.dims.add dim

func addDim*(ds: var Dataset, name: string, size: uint) =
  let dim = Dimension(name: name, size: size)
  ds.add dim
