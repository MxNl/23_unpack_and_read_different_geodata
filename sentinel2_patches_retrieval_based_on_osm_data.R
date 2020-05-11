library(sen2r)

# write_scihub_login('maxnoel', 'kakadusola1312')

set.seed(12)

products_to_download <- result_sf %>% 
  sample_n(1) %>% 
  s2_list(level = "L2A",
          max_cloud = 10,
          availability = "online") %>% 
  as_tibble() %>% 
  arrange(clouds)


cus_fun_convert_to_named_character <- function(row_with_s2_list_data){
  
  named_character <- row_with_s2_list_data %>% pull(url)

  names(named_character) <- row_with_s2_list_data %>% pull(name)
  
  named_character %>% 
    return()
}


ex_folder <- "s2_download_output_data"

dir.create(ex_folder)

products_to_download %>% 
  slice(2) %>% 
  cus_fun_convert_to_named_character() %>% 
  sen2r::s2_download(outdir = ex_folder)


str_c(ex_folder, "/S2B_MSIL2A_20200413T100549_N0214_R022_T31PDR_20200413T143142.SAFE") %>% 
sen2r::s2_translate()


sen2r::s2_gui()
