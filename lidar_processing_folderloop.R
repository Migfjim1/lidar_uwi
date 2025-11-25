source("setup.R")

# set filepath for hard drive - I suggest running off a drive (inputs=7TB, outputs=107GB)
data_dir <-"/Volumes/LaCie/uwi/lidar" # change folder path for drive
cook_fold <- "cook-las5" # CHANGE FOR NEW FOLDER - could set to loop, but like to check after each

# set folder paths
las_parent <- paste0(data_dir, '/input/', cook_fold) 
rast_folder <- paste0(data_dir, '/output/', cook_fold, "/raster_processed")
dir.create(rast_folder, showWarnings = FALSE, recursive = TRUE)

# if for some reason want to save rds files, uncomment this chunk and the writing lines 110-115
# rds_folder <- paste0(data_dir, '/output/', cook_fold, "/rds_processed")
# dir.create(rds_folder, showWarnings = FALSE)

# set resolution of output raster
res <- 1  # raster resolution

# get folder_num from parent directory name
folder_num <- basename(las_parent)

# get list of subfolders (1–10)
subfolders <- list.dirs(las_parent, recursive = FALSE, full.names = TRUE)

# loop through each subfolder
for (sub in subfolders) {
  
  subsection <- basename(sub)  # use subfolder name (1–10)
  cat("processing subsection:", subsection, "in", folder_num, "\n")
  
  # list all las files in this subfolder
  las_files <- list.files(sub, "\\.las$", full.names = TRUE)
  
  # initialize lists to store CHMs for stitching
  tree_chms_list  <- list()
  build_chms_list <- list()
  tree_tiles <- character(0)   # file paths for tile rasters (tree)
  build_tiles <- character(0)  # file paths for tile rasters (buildings)
  
  # run forloop
  for (f in las_files) {
    cat("processing:", f, "\n")
    
    # read las file and capture warnings
    read_warnings <- character()
    las <- withCallingHandlers(
      tryCatch(readLAS(f), error = function(e) NULL),
      warning = function(w) {
        read_warnings <<- c(read_warnings, conditionMessage(w))
        invokeRestart("muffleWarning")
      }
    )
    
    # skip if any warning mentions "Invalid data"
    if (any(grepl("Invalid data", read_warnings))) {
      warning("skipping (invalid data): ", f)
      next
    }
    
    # filter points - THIS IS WHERE YOU ADD/CHANGE FOR DIFFERENT LANDCOV CATEGORIES
    las_trees  <- filter_poi(las, Classification == 5)
    las_builds <- filter_poi(las, Classification == 6)
    
    # skip if no ground points
    if (sum(las$Classification == 2) == 0) {
      warning("no ground points, skipping: ", f)
      next
    }
    
    # calculate dtm
    dtm <- tryCatch(
      rasterize_terrain(las, res = res, algorithm = tin()),
      error = function(e) {warning("dtm failed, skipping: ", f); return(NULL)}
    )
    if (is.null(dtm)) next
    
    # tree dsm
    tree_dsm <- if (npoints(las_trees) > 0) {
      tryCatch(rasterize_canopy(las_trees, res = res, algorithm = p2r(), template = dtm),
               error = function(e) NULL)
    } else NULL
    
    # building dsm
    build_dsm <- if (npoints(las_builds) > 0) {
      tryCatch(rasterize_canopy(las_builds, res = res, algorithm = p2r(), template = dtm),
               error = function(e) NULL)
    } else NULL
    
    # align and compute chms only if DSM exists
    if (!is.null(tree_dsm)) {
      tree_chm <- tryCatch({
        resample(extend(tree_dsm, dtm), dtm, method = "max") - dtm
      }, error = function(e) NULL)
      if (!is.null(tree_chm)) tree_chms_list[[f]] <- tree_chm
    }
    
    if (!is.null(build_dsm)) {
      build_chm <- tryCatch({
        resample(extend(build_dsm, dtm), dtm, method = "max") - dtm
      }, error = function(e) NULL)
      if (!is.null(build_chm)) build_chms_list[[f]] <- build_chm
    }
  }
  
  cat("subfolder processing complete:", subsection, "\n")
  
  ################ steps we only want to do once per subfolder ################
  
  # save to rds (with folder/subsection in name)
  # saveRDS(tree_chms_list,
  #         file = file.path(rds_folder,
  #                          paste0("tree_chms_list_", folder_num, "_s", subsection, ".rds")))
  # saveRDS(build_chms_list,
  #         file = file.path(rds_folder,
  #                          paste0("build_chms_list_", folder_num, "_s", subsection, ".rds")))
  
  # remove names from the list
  tree_chms_list <- unname(tree_chms_list)
  build_chms_list <- unname(build_chms_list)
  
  # stitch / mosaic
  if (length(tree_chms_list) > 0) {
    tree_chm_all <- do.call(terra::merge, tree_chms_list)
    writeRaster(tree_chm_all,
                file.path(rast_folder,
                          paste0("cook_tree_chm_", folder_num, "_s", subsection, ".tif")),
                overwrite = TRUE)
  }
  
  if (length(build_chms_list) > 0) {
    build_chm_all <- do.call(terra::merge, build_chms_list)
    writeRaster(build_chm_all,
                file.path(rast_folder,
                          paste0("cook_build_chm_", folder_num, "_s", subsection, ".tif")),
                overwrite = TRUE)
  }
}

cat("all subfolders processed.\n")
