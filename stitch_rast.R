source("setup.R")

# set filepath for hard drive - I suggest running off a drive (inputs=7TB, outputs=107GB)
data_dir <-"/Volumes/LaCie/uwi/lidar" # change folder path for drive

# set folder paths
tile_dir <- paste0(data_dir,"/output") # this is the folder with the individual .tifs
mosaic_dir <- paste0(tile_dir,"/mosaics") # this is the folder where you'll output stitched .tifs
dir.create(mosaic_dir, showWarnings = FALSE, recursive = TRUE)

# recursively find all .tif files containing "build" in their names
build_files <- list.files(
  path = tile_dir,
  pattern = "build.*\\.tif$",  # matches filenames containing 'build' and ending in .tif
  recursive = TRUE,            # look inside subfolders
  full.names = TRUE            # return full paths
)

tree_files <- list.files(
  path = tile_dir,
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
writeRaster(build_rast, file.path(mosaic_dir, "cook_build_chm.tif"), overwrite = TRUE)
writeRaster(tree_rast,  file.path(mosaic_dir, "cook_tree_chm.tif"),  overwrite = TRUE)

