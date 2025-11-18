# Generating landscape elevation rasters from raw LiDAR data

## Table of contents

1. [Summary of repository](#summary-of-repository)
2. [How to download raw LiDAR data](#how-to-download-raw-lidar-data)
3. [Description of scripts](#description-of-scripts)
4. [Point classification table](#point-classification-table)

## Summary of repository
The tools within this repository allow users to go from a group of raw LiDAR files (las files) to an elevation raster for select point classifications. For example, we utilize LiDAR data from the Chicago Height Modernization project to generate canopy height and building rasters for all of Cook County, IL. These output rasters can be utilized in a slew of spatial analyses. 

[Back to top ⤒](#generating-landscape-elevation-rasters-from-raw-lidar-data)

## How to download raw LiDAR data
Raw LiDAR data is stored as las files. The las files used for this project can be found on the [Chicago Height Modernization Webiste](https://clearinghouse.isgs.illinois.edu/data/elevation/illinois-height-modernization-ilhmp). For this analysis all files relevant to Cook County for the year 2022 were used. 

Raw las files can be downloaded under the data tab. You can also download DSM and DTM rasters in this tab if you wish to forego the LiDAR processing stage. If you are unsure of what files you need but know the area you want to analyze, use the viewer tab to select only the neccesary files. 

BEWARE! LiDAR data is infamous for its aggregious filesizes. Make sure you have proper storage and processing power before considering LiDAR analysis.

[Back to top ⤒](#generating-landscape-elevation-rasters-from-raw-lidar-data)

## Description of scripts

### setup.R

### lidar_processing_folderloop.R
include that they have to change filenames

### stitch_rast.R
include that they have to change filenames

[Back to top ⤒](#generating-landscape-elevation-rasters-from-raw-lidar-data)

## Point classification table
These classifcations are relevant to the Chicago Height Modernization dataset. Do not assume that other datasets are using these exact classifications.

| Class                 | Value |
|-----------------------|-------|
| Never Classified      | 0     |
| Unassigned            | 1     |
| Ground                | 2     |
| Low Vegetation        | 3     |
| Medium Vegetation     | 4     |
| High Vegetation       | 5     |
| Building              | 6     |
| Noise                 | 7     |
| Model Key/Reserved    | 8     |
| Water                 | 9     |
| Rail                  | 10    |
| Road Surface          | 11    |
| Overlap/Reserved      | 12    |
| Wire - Guard          | 13    |
| Wire - Conductor      | 14    |
| Transmission Tower    | 15    |
| Wire - Connector      | 16    |
| Bridge Deck           | 17    |
| High Noise            | 18    |
| Overhead Structure    | 19    |
| Ignored Ground        | 20    |
| Snow                  | 21    |
| Temporal Exclusion    | 22    |

[Back to top ⤒](#generating-landscape-elevation-rasters-from-raw-lidar-data)

