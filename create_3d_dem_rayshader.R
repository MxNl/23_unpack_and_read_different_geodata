library(raster)
library(sf)
library(rayshader)
library(spatialEco)
library(tidyverse)

dem_hesse <- raster("data/gee_download_data/dem_example/hesse_srtm_dem30.tif")

# dem_hesse %>%
#   plot()

shrink_factor <- 0.04

# 7567
set.seed(26221)
dem_hesse <- dem_hesse %>% 
  crop_random_rectangle(shrink_factor = shrink_factor)

dem_hesse %>% 
  plot()

dem_hesse <- dem_hesse %>% 
  projectRaster(crs = "+init=EPSG:25832")

# dem_hesse_extent <- dem_hesse %>% 
#   extent()
# 
# shrink_factor <- 1
# 
# dem_hesse_extent@xmax <- dem_hesse_extent@xmin + (dem_hesse_extent@xmax - dem_hesse_extent@xmin) * shrink_factor
# dem_hesse_extent@ymax <- dem_hesse_extent@ymin + (dem_hesse_extent@xmax - dem_hesse_extent@xmin) * shrink_factor
# 
# dem_hesse <- dem_hesse %>% 
#   crop(dem_hesse_extent)
# 
# dem_hesse %>% 
#   plot()

# sigma_selected <- 4
# n_selected <- 3

# dem_hesse %>% 
#   as.matrix() %>% 
#   spatstat::blur() %>% 
#   plot()


# dem_hesse %>% 
#   raster.gaussian.smooth(sigma = sigma_selected,
#                          n = n_selected) %>%
#   plot()
# 
# dem_hesse <- dem_hesse %>% 
#   raster.gaussian.smooth(sigma = sigma_selected,
#                          n = n_selected)


#And convert it to a matrix:
elmat = raster_to_matrix(dem_hesse)

#We use another one of rayshader's built-in textures:
# elmat %>%
#   sphere_shade(texture = "desert") %>%
#   plot_map()
# 
# elmat %>%
#   sphere_shade(texture = "desert") %>%
#   add_water(detect_water(elmat), color = "desert") %>%
#   plot_map()
# 
# #And we can add a raytraced layer from that sun direction as well:
# elmat %>%
#   sphere_shade(texture = "desert") %>%
#   add_water(detect_water(elmat), color = "desert") %>%
#   add_shadow(ray_shade(elmat), 0.5) %>%
#   plot_map()
# 
# #And here we add an ambient occlusion shadow layer, which models 
# #lighting from atmospheric scattering:
# elmat %>%
#   sphere_shade(texture = "desert") %>%
#   add_water(detect_water(elmat), color = "desert") %>%
#   add_shadow(ray_shade(elmat), 0.5) %>%
#   add_shadow(ambient_shade(elmat), 0) %>%
#   plot_map()
# 
# 
# elmat %>%
#   sphere_shade(texture = "desert") %>%
#   add_water(detect_water(elmat), color = "desert") %>%
#   add_shadow(ray_shade(elmat, zscale = 3), 0.5) %>%
#   add_shadow(ambient_shade(elmat), 0) %>%
#   plot_3d(elmat, zscale = 10, fov = 0, theta = 135, zoom = 0.75, phi = 45, windowsize = c(1000, 800))
# Sys.sleep(0.2)
# render_snapshot()
# 
# 
water_height <- elmat %>%
  min(na.rm = TRUE) + 50

# elmat %>%
#   sphere_shade(texture = "desert") %>%
#   add_water(detect_water(elmat, max_height = water_height), color = "desert") %>%
#   add_shadow(ray_shade(elmat), 0.5) %>%
#   add_shadow(ambient_shade(elmat), 0) %>%
#   plot_map()

elmat %>%
  sphere_shade(texture="desert") %>%
  add_shadow(ray_shade(elmat, zscale = 5), 0.5) %>%
  add_shadow(ambient_shade(elmat), 0) %>%
  plot_3d(elmat, 
          zscale=5, 
          water = TRUE, 
          waterdepth = water_height, 
          watercolor="desert", 
          theta=-45, 
          zoom=0.7,
          waterlinecolor="white", 
          waterlinealpha=0.5,
          baseshape="circl",
          linewidth = 0,
          lineantialias = TRUE,
          soliddepth = 30)



# render_depth(focus = 0.6, focallength = 200, clear = TRUE)

# render_snapshot(clear = TRUE)
# render_camera(fov = 0, theta = 60, zoom = 0.75, phi = 45)
# render_scalebar(limits=c(0, 5, 10),label_unit = "km",position = "W", y=50,
#                 scale_length = c(0.33,1))
# render_compass(position = "E")
# render_snapshot(clear=TRUE)

