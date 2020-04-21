How to Extract Objects and Data from OSM Database
================
Maximilian Nölscher,
16 April 2020

For the following code chunks we need to load all required libraries

``` r
library(tmap)
library(osmdata)
library(sf)
library(tidyverse)
```

Features to Search For
======================

Firstly, we need to define the features that should be searched for and extracted from the OSM database. In OSM, this works via key = value pairs.

This can be done for example like this:

``` r
key_value_pairs <- tribble(
  ~key,         ~value,               ~master,
  "man_made",   "water_tower",        "water tower",
  "man_made",   "storage_tank",       "water tower",
  "man_made",   "reservoir_covered",  "water tower",
  "building",   "water_tower",        "water tower",
  "man_made",   "wastewater_plant",   "wastewater plant",
  "amenity",    "fuel",               "gas station"
)
```

the column `master` just assigns each key = value pair to a unique feature.

From this table we can obtain vector with our keys

``` r
tag_keys <- key_value_pairs %>% 
  pull(key)
```

... and values

``` r
tag_values <- key_value_pairs %>% 
  pull(value)
```

We define a bounding box or an area to search in

``` r
bounding_box <- getbb('niamey, niger', format_out = 'polygon')
```

Pass this to the overpass API (no need to understand this in detail)

``` r
overpass_query <- bounding_box %>% 
  opq()
```

We create a function to download a single key = value pair

``` r
cus_fun_get_osm_data <- function(static_opq, x_key, y_value){
  static_opq %>% 
    add_osm_feature(key = x_key, 
                  value = y_value,
                  key_exact = FALSE,
                  value_exact = FALSE) %>%
    osmdata_sf () %>%
    trim_osmdata(bounding_box)
}
```

And apply this function for every key = value pair that we defined in our table initially

``` r
result_sf <- map2(tag_keys,
                  tag_values,
                  cus_fun_get_osm_data, 
                  static_opq = overpass_query)
```

Each download results in an osm object, that contains meta data and different geometry types for our feature. Here we are only interested in the polygons

``` r
result_sf <- result_sf %>% 
  map(function(x) x$osm_polygons)
```

We drop empty objects or requests that didn't lead to any result

``` r
result_sf <- result_sf %>% 
  discard(~nrow(.) == 0)
```

Now we create a function to harmonize each osm object as they come with inconsistent dimensions (different columns).

``` r
cus_fun_harmonize_osm_dataframe <- function(osm_dataframe, x_key){
  
  # osm_dataframe <- result_sf[[1]]
  # x_key <- keys_water_tower
  
  key <- osm_dataframe %>% 
    as_tibble() %>% 
    select(-geometry) %>% 
    select(one_of(x_key)) %>% 
    select_if(~mean(is.na(.)) <= 0) %>% 
    names()
  
  osm_dataframe %>% 
    rename(value = !!key) %>% 
    mutate(key = key) %>% 
    select(osm_id, key, value)
}
```

And again, we apply this function to all results

``` r
result_sf <- map(
  result_sf,
  cus_fun_harmonize_osm_dataframe,
  tag_keys
) %>%
  reduce(rbind)
```

We join all results into a single dataframe

``` r
result_sf <- result_sf %>% 
  left_join(key_value_pairs, by = c("key", "value"))
```

For custom colour values, we define `n` discrete colours

``` r
number_of_colours <- result_sf %>% 
  pull(master) %>% 
  n_distinct()

n_discrete_colours <- hues::iwanthue(number_of_colours)
```

Results
=======

Dataframe
---------

Show the downloaded features as dataframe

``` r
result_sf
```

    ## Simple feature collection with 31 features and 4 fields
    ## geometry type:  POLYGON
    ## dimension:      XY
    ## bbox:           xmin: 2.073305 ymin: 13.43088 xmax: 2.213021 ymax: 13.56623
    ## epsg (SRID):    4326
    ## proj4string:    +proj=longlat +datum=WGS84 +no_defs
    ## First 10 features:
    ##       osm_id      key       value      master                       geometry
    ## 1  189323106 man_made water_tower water tower POLYGON ((2.11754 13.51414,...
    ## 2  238297374 man_made water_tower water tower POLYGON ((2.098539 13.49173...
    ## 3  238297375 man_made water_tower water tower POLYGON ((2.098564 13.49141...
    ## 4  313557710 man_made water_tower water tower POLYGON ((2.095648 13.52189...
    ## 5  442171446 man_made water_tower water tower POLYGON ((2.140575 13.49464...
    ## 6  500091189 man_made water_tower water tower POLYGON ((2.129039 13.50664...
    ## 7  526926651 man_made water_tower water tower POLYGON ((2.212924 13.44856...
    ## 8  659675721 man_made water_tower water tower POLYGON ((2.094159 13.56541...
    ## 9  659701317 man_made water_tower water tower POLYGON ((2.115406 13.5658,...
    ## 10 659701318 man_made water_tower water tower POLYGON ((2.115374 13.56609...

Plot
----

We can now plot an interactive map, showing our download results

``` r
tmap::tmap_mode(mode = "view")

result_sf %>% 
  tmap::tm_shape() +
  tmap::tm_dots(col = "master",
                border.col = "white",
                # border.lwd = 100,
                scale = 2,
                alpha = .7,
                popup.vars = c("key", "value"),
                palette = n_discrete_colours) +
  # tm_borders(col = "red",
  #            lwd = 5) +
  # tmap::tm_markers(col = "master") +
  tmap::tm_basemap(leaflet::providers$Esri.WorldImagery)
```

or a static map

``` r
tmap::tmap_mode(mode = "plot")

result_sf %>% 
  tmap::tm_shape() +
  tmap::tm_dots(col = "master",
                border.col = "white",
                # border.lwd = 100,
                scale = 2,
                alpha = .7,
                popup.vars = c("key", "value"),
                palette = n_discrete_colours) +
  # tm_borders(col = "red",
  #            lwd = 5) +
  # tmap::tm_markers(col = "master") +
  tmap::tm_basemap(leaflet::providers$Esri.WorldImagery)
```

![](osm_data_retrieval_files/figure-markdown_github/unnamed-chunk-17-1.png)
