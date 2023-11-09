import std/[json, tables]
import ./common
import jsony

proc skipHook*(T: type Dataset, key: static string): bool =
  key in ["id", "unlimdimidp"]

proc skipHook*(T: type Variable, key: static string): bool =
  key in ["id", "dsid", "xtype"]

proc skipHook*(T: type Dimension, key: static string): bool =
  key in ["id", "size"]

proc skipHook*(T: type Attribute, key: static string): bool =
  key in ["vid", "size", "xtype"]

proc dumpHook*(s: var string, atts: seq[Attribute]) =
  var tab = initTable[string, JsonNode]()
  for att in atts:
    tab[att.name] = case att.xtype:
      of NcByte: %att.byteVal
      of NcChar: %att.strVal
      of NcShort: %att.shortVal
      of NcInt: %att.intVal
      of NcFloat: %att.floatVal
      of NcDouble: %att.doubleVal
      else: %nil
  s.add tab.toJson

proc dumpHook*(s: var string, dims: seq[Dimension]) =
  var tab = initTable[string, uint]()
  for dim in dims:
    tab[dim.name] = dim.size
  s.add tab.toJson

  # var strings: seq[string]
  # for dim in dims:
  #   strings.add dim.name
  # s.add strings.toJson
