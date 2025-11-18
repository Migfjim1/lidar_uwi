source("setup.R")
library(gdalUtilities)

# set base dir and output dir
base_dir <- "/Users/mjimenez/Desktop/data"
out_dir <- "/Users/mjimenez/Desktop/data/outputs"

# recursively find all .tif files containing "build" in their names
build_files <- list.files(
  path = base_dir,
  pattern = "build.*\\.tif$",  # matches filenames containing 'build' and ending in .tif
  recursive = TRUE,            # look inside subfolders
  full.names = TRUE            # return full paths
)

tree_files <- list.files(
  path = base_dir,
  pattern = "tree.*\\.tif$",  # matches filenames containing 'build' and ending in .tif
  recursive = TRUE,            # look inside subfolders
  full.names = TRUE            # return full paths
)

# write function to read and mosaic a list of raster tiles
mosaic_tiles <- function(file_list) {
  tiles <- lapply(file_list, rast)
  rast_out <- do.call(mosaic, tiles)
  return(rast_out)
}

# use it for build and tree rasters
build_rast <- mosaic_tiles(build_files)
tree_rast  <- mosaic_tiles(tree_files)

# write out stitched raster
writeRaster(build_rast, file.path(out_dir, "cook_build_chm.tif"), overwrite = TRUE)
writeRaster(tree_rast,  file.path(out_dir, "cook_tree_chm.tif"),  overwrite = TRUE)

