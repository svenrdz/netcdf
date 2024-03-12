import nimpy
import nimpy/[py_types, nim_py_marshalling]
import netcdf
import std/[json, tables]

proc toDimsTab(dims: PyObject): PPyObject =
  var tab = initTable[string, int]()
  for d in dims:
    tab[d["name"].to(string)] = d["size"].to(int)
  tab.nimValueToPy

proc toAttsTab(atts: PyObject): PyObject =
  result = pyDict()
  for att in atts:
    result[att["name"].to(string)] = nimValueToPy:
      case att["xtype"].to(NcType)
      of NcByte:
        att["byteVal"]
      of NcChar:
        att["strVal"]
      of NcShort:
        att["shortVal"]
      of NcInt:
        att["intVal"]
      of NcFloat:
        att["floatVal"]
      of NcDouble:
        att["doubleVal"]
      else:
        nil

proc ncjson(filename: string, raw: bool = false): PyObject {.exportpy.} =
  ## proc ncjson(filename: string, raw = false): PyObject {.exportpy.} =
  ##   ...
  ##
  ## ncjson produces a python `dict`, formatted as
  ##   {"filename": <path>,
  ##    "headers": {"atts": ...,
  ##                "vars": ...,
  ##                "dims": ...}}
  ##
  ##   dims = table of dimensions, formatted as
  ##          {<dimension name>: <dimensions size>}
  ##   atts = table of global attributes, formatted as
  ##          {<attribute name>: <attribute value>}
  ##   vars = list of variables, each variable formatted as
  ##          {"name": <variable name>,
  ##           "dims": <table of variable dimensions>,
  ##           "atts": <table of variable attributes>}
  ##
  ## When `raw == True`, most dictionaries are instead represented as lists.
  ##
  ## Check out Nim:
  ##   https://nim-lang.org/
  ##
  let ds = Dataset.open(filename)
  defer:
    close ds
  result = pyDict()
  result["filename"] = filename
  result["headers"] = ds.toPyDict
  discard result["headers"].pop "id"
  discard result["headers"].pop "unlimdimidp"
  for v in result["headers"]["vars"]:
    discard v.pop "id"
    discard v.pop "dsid"
    discard v.pop "xtype"
    if not raw:
      v["dims"] = v["dims"].toDimsTab
      v["atts"] = v["atts"].toAttsTab
  if not raw:
    result["headers"]["dims"] = result["headers"]["dims"].toDimsTab
    result["headers"]["atts"] = result["headers"]["atts"].toAttsTab
