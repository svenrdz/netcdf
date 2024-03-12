import ./[bindings, common]

func getAtt*(id: NcId, vid, attId: int): Attribute =
  var
    name = newString(Ncmaxname)
    xtype: NcType
    size: uint
  handleError:
    ncinqattname(id, vid.NcId, attId.NcId, name.cstring)
  handleError:
    ncinqatt(id, vid.NcId, name.cstring, xtype.addr, size.addr)
  name.setLen(name.cstring.len)
  result =
    Attribute(vid: vid, name: name[0 ..< name.cstring.len], size: size, xtype: xtype)
  case result.xtype
  of NcChar:
    result.strVal.setLen(result.size)
    handleError:
      ncgetatttext(id, vid.NcId, name.cstring, result.strVal.cstring)
    result.strVal.setLen(result.strVal.cstring.len)
  of NcByte:
    handleError:
      ncgetattubyte(id, vid.NcId, name.cstring, result.byteVal.addr)
  of NcShort:
    handleError:
      ncgetattshort(id, vid.NcId, name.cstring, result.shortVal.addr)
  of NcInt:
    handleError:
      ncgetattint(id, vid.NcId, name.cstring, result.intVal.addr)
  of NcFloat:
    handleError:
      ncgetattfloat(id, vid.NcId, name.cstring, result.floatVal.addr)
  of NcDouble:
    handleError:
      ncgetattdouble(id, vid.NcId, name.cstring, result.doubleVal.addr)
  else:
    discard
