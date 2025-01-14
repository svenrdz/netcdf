# this is just:
# https://www.unidata.ucar.edu/software/netcdf/docs/simple__xy__wr_8c_source.html

import netcdf/bindings

const
  ## This is the name of the data file we will create.
  filename = "simple_xy.nc"
  ## We are writing 2D data, a 6 x 12 grid.
  ndims = 2
  nx = 6
  ny = 12

# Handle errors by printing an error message and exiting with a
# non-zero status.
const errcode = 2
template err(e: untyped): untyped =
  echo "Error: ", ncstrerror(e)
  quit(errcode)

proc main() =
  # When we create netCDF variables and dimensions, we get back an
  # ID for each one.
  var
    ncid, x_dimid, y_dimid, varid: cint
    dimids: array[ndims, cint]

  # This is the data array we will write. It will be filled with a
  # progression of numbers for this example.
  # var data_out: array[nx * ny, cint]
  var data_out: array[nx, array[ny, cint]]

  # Loop indexes, and error handling.
  var x, y, retval: cint

  # Create some pretend data. If this wasn't an example program, we
  # would have some real data to write, for example, model
  # output.
  for x in 0 ..< nx:
    for y in 0 ..< ny:
      data_out[x][y] = x.cint * ny + y.cint

  # Always check the return code of every netCDF function call. In
  # this example program, any retval which is not equal to NC_NOERR
  # (0) will cause the program to print an error message and exit
  # with a non-zero return code.

  # Create the file. The NcClobber parameter tells netCDF to
  # overwrite this file, if it already exists.*/
  retVal = nccreateproc(filename, NcClobber, ncid.unsafeaddr)
  if retval != 0:
    err(retval)

  # Define the dimensions. NetCDF will hand back an ID for each.
  retVal = ncdefdim(ncid, "x", nx, x_dimid.unsafeAddr)
  if retVal != 0:
    err(retval)
  retval = ncdefdim(ncid, "y", ny, y_dimid.unsafeAddr)
  if retVal != 0:
    err(retval)

  # The dimids array is used to pass the IDs of the dimensions of
  # the variable.
  dimids[0] = x_dimid
  dimids[1] = y_dimid

  # Define the variable. The type of the variable in this case is
  # NcInt (4-byte integer).
  retval = ncdefvar(ncid, "data", NcInt, ndims, dimids[0].unsafeAddr, varid.unsafeAddr)
  if retVal != 0:
    err(retval)

  # End define mode. This tells netCDF we are done defining
  # metadata.
  retval = ncenddefproc(ncid)
  if retVal != 0:
    err(retval)

  # Write the pretend data to the file. Although netCDF supports
  # reading and writing subsets of data, in this case we write all
  # the data in one operation.
  retval = ncputvarint(ncid, varid, data_out[0][0].unsafeAddr)
  if retVal != 0:
    err(retval)

  # Close the file. This frees up any internal netCDF resources
  # associated with the file, and flushes any buffers.
  retval = ncclose(ncid)
  if retVal != 0:
    err(retval)

  echo "*** SUCCESS writing example file " & filename

main()
