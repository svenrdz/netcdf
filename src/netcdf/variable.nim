import
  std/[
    sugar,
  ],

  ./[
    bindings,
    common,
    attribute,
  ]

type
  ValueTypes = cfloat | cdouble

func size*(v: Variable): uint =
  result = 1
  for dim in v.dims:
    result *= dim.size

proc getVar*(ds: Dataset, varId: int): Variable =
  var
    name = newString(Ncmaxname)
    xtype: NcType
    ndim, natt: cint
    dimIds = newSeq[cint](Ncmaxdims)
  handleError:
    ncinqvar(ds.id, varId.NcId, name.cstring, xtype.addr,
             ndim.addr, dimIds[0].addr, natt.addr)
  name.setLen(name.cstring.len)
  dimIds.setLen(ndim)
  result = Variable(
    dsid: ds.id,
    id: varId,
    name: name,
    # name: name[0..name.cstring.len],
    xtype: xtype,
  )
  result.dims = collect:
    for i in 0..<ndim:
      ds.dims[dimIds[i]]
  result.atts = collect:
    for i in 0..<natt:
      getAtt(ds.id, varId, i)
  # debugecho varId

# func loadValues*(v: var Variable) =
#   case v.xtype
#   of NcDouble:
#     v.doubleVal.setLen(v.size)
#     handleError ncgetvardouble(v.dsid, v.id, v.doubleVal[0].addr)
#   of NcFloat:
#     v.floatVal.setLen(v.size)
#     handleError ncgetvarfloat(v.dsid, v.id, v.floatVal[0].addr)
#   else: discard

func `[]`*[T: ValueTypes](v: Variable,
                          typ: typedesc[T],
                          indices: varargs[uint]): T =
  assert indices.len == v.dims.len
  when T is cdouble:
    assert v.xtype == NcDouble
    handleError:
      ncgetvar1double(v.dsid, v.id.NcId,
                      indices[0].addr,
                      result.addr)
  elif T is cfloat:
    assert v.xtype == NcFloat
    handleError:
      ncgetvar1float(v.dsid, v.id.NcId,
                     indices[0].addr,
                     result.addr)
  # elif T is SomeInteger:
  #   assert v.xtype in {NcInt, NcShort}

# type ImapVariable = distinct Variable
# func imap*(v: Variable): ImapVariable = ImapVariable v
# func `[]`*(v: Variable, typ: typedesc[ValueTypes], i: int): int = i
# func `[]!`*(v: Variable, typ: typedesc[ValueTypes], i: int): int = i
# func `[]`*(v: ImapVariable, typ: typedesc[ValueTypes], i: int): int = i

func toSlice[T: SomeInteger](x: T): Slice[uint] =
  x.uint .. x.uint

func toSlice[U, V: SomeInteger](s: HSlice[U, V]): Slice[uint] =
  s.a.uint .. s.b.uint

func `[]`*[T: ValueTypes](v: Variable,
                          typ: typedesc[T],
                          slices: varargs[Slice[int]]): seq[T] =
  assert slices.len == v.dims.len
  var
    starts: seq[uint]
    ends: seq[uint]
    size = 1
  for s in slices:
    starts.add s.a.uint
    ends.add s.b.uint + 1
    size *= s.len
  result.setLen(size)
  when T is cdouble:
    assert v.xtype == NcDouble
    handleError:
      ncgetvaradouble(v.dsid, v.id.NcId,
                      starts[0].addr,
                      ends[0].addr,
                      result[0].addr)
  elif T is cfloat:
    assert v.xtype == NcFloat
    handleError:
      ncgetvarafloat(v.dsid, v.id.NcId,
                     starts[0].addr,
                     ends[0].addr,
                     result[0].addr)

  # elif T is SomeInteger:
  #   assert v.xtype in {NcInt, NcShort}

  # func ncgetvaradouble*(ncid: cint; varid: cint; startp: ptr csize_t;
  #                       countp: ptr csize_t; ip: ptr cdouble): cint
  # func ncgetvarafloat*(ncid: cint; varid: cint; startp: ptr csize_t;
  #                      countp: ptr csize_t; ip: ptr cfloat): cint

template `[]`*[T: ValueTypes](v: Variable,
                              typ: typedesc[T],
                              slices: varargs[typed, toSlice]): seq[T] =
  v[typ, slices]
