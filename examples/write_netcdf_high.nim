# this is just:
# https://www.unidata.ucar.edu/software/netcdf/docs/simple__xy__wr_8c_source.html

import netcdf
import std/sequtils

const
  ## This is the name of the data file we will create.
  filename = "simple_xy.nc"
  ## We are writing 2D data, a 6 x 12 grid.
  nx = 3
  ny = 17

proc main() =
  # # This is the data array we will write. It will be filled with a
  # # progression of numbers for this example.
  # var data_out: array[nx, array[ny, cint]]
  # # Create some pretend data. If this wasn't an example program, we
  # # would have some real data to write, for example, model
  # # output.
  # for x in 0..<nx:
  #   for y in 0..<ny:
  #     data_out[x][y] = x.cint * ny + y.cint

  # Same with seq
  var data_out: seq[seq[cint]]
  for x in 0 ..< nx:
    data_out.add @[]
    for y in 0 ..< ny:
      data_out[x].add x.cint * ny + y.cint

  # Create the file. The cmClobber (NcClobber) parameter tells netCDF to
  # overwrite this file, if it already exists.
  var ds = Dataset.create(filename)
  # var ds = Dataset.create(filename, mode = cmClobber)

  # Enter define mode. This tells netCDF we are defining metadata.
  ds.define:
    # Define the dimensions.
    ds.add Dimension(name: "x", size: nx)
    ds.add Dimension(name: "y", size: ny)

    # The dims array is used to pass the dimensions of the variable.
    let dims = @[ds.dim("x"), ds.dim("y")]

    # Define the variable. The type of the variable in this case is
    # NcInt (4-byte integer).
    ds.add Variable(name: "data", xtype: NcInt, dims: dims)

  # Write the pretend data to the file. Although netCDF supports
  # reading and writing subsets of data, in this case we write all
  # the data in one operation.
  echo "BEFORE ", ds["data"][cint, 0 ..< nx, 0 ..< ny]
  ds["data"] = data_out
  echo "ds[\"data\"] = data_out"
  echo "AFTER ", ds["data"][cint, 0 ..< nx, 0 ..< ny]

  # Close the file. This frees up any internal netCDF resources
  # associated with the file, and flushes any buffers.
  close ds

  echo "*** SUCCESS writing example file " & filename

main()
