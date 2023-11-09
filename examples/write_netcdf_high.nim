# this is just:
# https://www.unidata.ucar.edu/software/netcdf/docs/simple__xy__wr_8c_source.html

import netcdf

const
  ## This is the name of the data file we will create.
  FILE_NAME = "simple_xy.nc"
  ## We are writing 2D data, a 6 x 12 grid.
  NDIMS = 2
  NX = 6
  NY = 12

proc main() =
  # This is the data array we will write. It will be filled with a
  # progression of numbers for this example.
  var data_out: array[NX, array[NY, cint]]

  # Create some pretend data. If this wasn't an example program, we
  # would have some real data to write, for example, model
  # output.
  for x in 0..<NX:
    for y in 0..<NY:
      data_out[x][y] = x.cint * NY + y.cint

  # Create the file. The cmClobber (NC_CLOBBER) parameter tells netCDF to
  # overwrite this file, if it already exists.
  var ds = Dataset.create(FILE_NAME)
  # var ds = Dataset.create(FILE_NAME, mode = cmClobber)

  # Enter define mode. This tells netCDF we are defining metadata.
  ds.define:
    # Define the dimensions.
    ds.add Dimension(name: "x", size: NX)
    ds.add Dimension(name: "y", size: NY)

    # The dims array is used to pass the dimensions of the variable.
    let dims = @[ds.dim("x"), ds.dim("y")]

    # Define the variable. The type of the variable in this case is
    # NC_INT (4-byte integer).
    ds.add Variable(name: "data", xtype: NcInt, dims: dims)

  # Write the pretend data to the file. Although netCDF supports
  # reading and writing subsets of data, in this case we write all
  # the data in one operation.
  echo "BEFORE ", ds["data"][cint, 0..<NX, 0..<NY]
  ds["data"] = data_out
  echo "ds[\"data\"] = data_out"
  echo "AFTER ", ds["data"][cint, 0..<NX, 0..<NY]

  # Close the file. This frees up any internal netCDF resources
  # associated with the file, and flushes any buffers.
  close ds

  echo "*** SUCCESS writing example file " & FILE_NAME

main()
