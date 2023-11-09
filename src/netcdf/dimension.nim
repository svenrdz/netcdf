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

