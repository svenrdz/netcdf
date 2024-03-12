import jsony
import glob

import netcdf

type
  Ok = object
    filename: string
    headers: Dataset

  Err = object
    filename: string
    error: string

proc processOne(fname: string) =
  try:
    let ok = Ok(filename: fname, headers: Dataset.open(fname))
    stdout.writeLine ok.toJson
    close ok.headers
  except Exception as e:
    let err = Err(filename: fname, error: e[].msg)
    stderr.writeLine err.toJson

proc ncjson(paths: seq[string]) =
  ## ncjson - print NetCDF headers as JSON
  ##
  ## ncjson produces one JSON for each input path, formatted as
  ##   {filename: <path>,
  ##    headers: {atts: ...,
  ##              vars: ...,
  ##              dims: ...}}
  ##
  ##   dims = table of dimensions, formatted as
  ##          {<dimension name>: <dimensions size>}
  ##   atts = table of global attributes, formatted as
  ##          {<attribute name>: <attribute value>}
  ##   vars = list of variables, each variable formatted as
  ##          {name: <variable name>,
  ##           dims: <table of variable dimensions>,
  ##           atts: <table of variable attributes>}
  ##
  ## Errors are written to stderr, formatted as one JSON for each input path.
  for path in paths:
    for fname in walkglob(path):
      processOne(fname)

when isMainModule:
  import cligen

  dispatch(ncjson)
