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
  of NcNat:
    discard
  of NcByte:
    handleError:
      nc_get_att_schar(id, vid.NcId, name.cstring, result.byteVal.addr)
  of NcChar:
    result.strVal.setLen(result.size)
    handleError:
      nc_get_att_text(id, vid.NcId, name.cstring, result.strVal.cstring)
    result.strVal.setLen(result.strVal.cstring.len)
  of NcShort:
    handleError:
      nc_get_att_short(id, vid.NcId, name.cstring, result.shortVal.addr)
  of NcInt:
    handleError:
      nc_get_att_int(id, vid.NcId, name.cstring, result.intVal.addr)
  of NcFloat:
    handleError:
      nc_get_att_float(id, vid.NcId, name.cstring, result.floatVal.addr)
  of NcDouble:
    handleError:
      nc_get_att_double(id, vid.NcId, name.cstring, result.doubleVal.addr)
  of NcUByte:
    handleError:
      nc_get_att_uchar(id, vid.NcId, name.cstring, result.ubyteVal.addr)
  of NcUShort:
    handleError:
      nc_get_att_ushort(id, vid.NcId, name.cstring, result.ushortVal.addr)
  of NcUInt:
    handleError:
      nc_get_att_uint(id, vid.NcId, name.cstring, result.uintVal.addr)
  of NcInt64:
    handleError:
      nc_get_att_longlong(id, vid.NcId, name.cstring, result.int64Val.addr)
  of NcUInt64:
    handleError:
      nc_get_att_ulonglong(id, vid.NcId, name.cstring, result.uint64Val.addr)
  of NcString:
    var tmp: seq[cstring]
    tmp.setLen(result.size)
    handleError:
      nc_get_att_string(id, vid.NcId, name.cstring, tmp[0].addr)
    for s in tmp:
      result.stringsVal.add $s
