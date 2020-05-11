library(raster)
library(rasterVis)
library(RStoolbox)
library(googledrive)
library(sf)
library(tidyverse)

# User authetification
drive_auth("maxnoelscher@gmail.com")

dir.create("data/gee_download_data/chad_example")

# Download the files
drive_find(pattern = "chad_example_sentinel") %>% 

  pull(name) %>% 
  map(function(x) drive_download(x, 
                                 path = str_c("data/gee_download_data/chad_example/", x),
                                 overwrite = TRUE))


data_directory <- here::here("data/gee_download_data/chad_example/")

raster_list <- data_directory %>% 
  list.files() %>% 
  str_c(data_directory, "/", .) %>% 
  tibble(filepath = .) %>% 
  # slice(1:6) %>%
  pull(filepath) %>% 
  map(brick)

# raster_list[[1]] %>% 
#   cellStats(stat = range)
# 
# raster_list[[1]] %>% 
#   plotRGB(scale = 3219)

# raster_list$fun <- mean
# raster_mosaic <- do.call(mosaic, raster_list)

raster_mosaic_extent <- raster_list[[1]] %>% 
  extent() %>% 
  as("SpatialPolygons") %>% 
  st_as_sf() %>% 
  st_set_crs(crs(raster_list[[1]])) %>% 
  st_transform(crs(square_polygons_for_cropping_raster))

# Test if raster mosaic covers the squares for cropping
square_polygons_for_cropping_raster %>% 
  ggplot() +
  geom_sf() +
  geom_sf(data = raster_mosaic_extent,
          fill = NA)


test_square <- square_polygons_for_cropping_raster

test_raster <- raster_list[[1]]

# Core cropping
# test_square %>% 
#   st_transform(crs(test_raster)) %>% 
#   raster::crop(test_raster, .) %>% 
#   plotRGB(stretch = "lin")

# image_patches <- test_square %>% 
#   st_transform(crs(test_raster)) %>% 
#   group_by(osm_id) %>% 
#   group_split() %>% 
#   map(raster::crop, x = test_raster, y = .)

image_patches <- test_square %>% 
  st_transform(crs(test_raster)) %>% 
  group_by(osm_id) %>% 
  group_split() %>% 
  map(function(list_element) raster::crop(test_raster, list_element))

#Plot the patches
par(mfrow = c(6, 6))

image_patches %>% 
  map(plotRGB, stretch = "lin")
