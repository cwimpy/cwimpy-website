# -----------------------------------------------------------------------------
# RUCC-change county map for cwimpy.com
#
# Joins USDA ERS Rural-Urban Continuum Codes for 2013 and 2023 to county
# geometries, then renders a choropleth shaded by 2023 RUCC with arrows at
# county centroids pointing up where a county became more rural and down
# where it became less rural (arrow length scaled by magnitude of change).
#
# Output: images/rucc-map.png (wide, 2000x1200) for retina embed
#
# Re-render:  Rscript scripts/rucc-map.R
# -----------------------------------------------------------------------------

options(timeout = 120)

suppressPackageStartupMessages({
  library(sf)
  library(tigris)
  library(dplyr)
  library(readxl)
  library(ggplot2)
  library(showtext)
  library(sysfonts)
  library(ragg)
  library(here)
  library(stringr)
})

options(tigris_use_cache = TRUE)
sf::sf_use_s2(FALSE)

# Fonts — same stack as the site
font_add_google("Fraunces", "fraunces", regular.wt = 500, bold.wt = 600)
font_add_google("Inter", "inter", regular.wt = 500, bold.wt = 700)
font_add_google("JetBrains Mono", "jbmono", regular.wt = 500)
showtext_auto()
showtext_opts(dpi = 150)

# Paths
CACHE    <- here::here("scripts", "rucc-cache")
OUT_WIDE <- here::here("images", "rucc-map.png")
dir.create(CACHE, recursive = TRUE, showWarnings = FALSE)

# Brand
COL_BG        <- "#fdfcf8"
COL_TEXT      <- "#1a2520"
COL_MUTED     <- "#4a6b56"
COL_SUBTLE    <- "#7a9b87"
COL_PRIMARY   <- "#1e5f3e"
COL_ACCENT    <- "#2d8a47"
COL_AMBER     <- "#b07a1f"
COL_AMBER_LT  <- "#d9a44a"

# --- Load data -----------------------------------------------------------

rucc_url <- list(
  y2023 = "https://www.ers.usda.gov/sites/default/files/_laserfiche/DataFiles/53251/Ruralurbancontinuumcodes2023.xlsx",
  y2013 = "https://www.ers.usda.gov/sites/default/files/_laserfiche/DataFiles/53251/ruralurbancodes2013.xls"
)

local_path <- function(year) file.path(CACHE, paste0("rucc_", year, switch(year, y2023 = ".xlsx", y2013 = ".xls")))

for(y in names(rucc_url)) {
  lp <- local_path(y)
  if(!file.exists(lp)) {
    message("Downloading ", y, " RUCC file ...")
    download.file(rucc_url[[y]], lp, mode = "wb", quiet = TRUE)
  }
}

rucc_2023_raw <- read_excel(local_path("y2023"))
rucc_2013_raw <- read_excel(local_path("y2013"))

# Normalize column names (ERS sometimes uses different cases / suffixes)
names(rucc_2023_raw) <- tolower(names(rucc_2023_raw))
names(rucc_2013_raw) <- tolower(names(rucc_2013_raw))

fips_col <- function(df) {
  cand <- intersect(c("fips", "fips_code", "fips2013", "fipscode"), names(df))
  if(!length(cand)) stop("No FIPS column in ", toString(names(df)))
  cand[1]
}
rucc_col <- function(df, year) {
  pat <- paste0("^rucc[_-]?", year, "$|^rucc$|^rucc_code$")
  cand <- grep(pat, names(df), value = TRUE)
  if(!length(cand)) cand <- grep("^rucc", names(df), value = TRUE)
  if(!length(cand)) stop("No RUCC column in ", toString(names(df)))
  cand[1]
}

rucc_2023 <- rucc_2023_raw %>%
  transmute(
    fips = str_pad(as.character(.data[[fips_col(rucc_2023_raw)]]), 5, pad = "0"),
    rucc_2023 = as.integer(.data[[rucc_col(rucc_2023_raw, 2023)]])
  ) %>%
  filter(!is.na(rucc_2023), nchar(fips) == 5)

rucc_2013 <- rucc_2013_raw %>%
  transmute(
    fips = str_pad(as.character(.data[[fips_col(rucc_2013_raw)]]), 5, pad = "0"),
    rucc_2013 = as.integer(.data[[rucc_col(rucc_2013_raw, 2013)]])
  ) %>%
  filter(!is.na(rucc_2013), nchar(fips) == 5)

rucc <- inner_join(rucc_2023, rucc_2013, by = "fips") %>%
  mutate(delta = rucc_2023 - rucc_2013)  # + = more rural, - = less rural

message(sprintf("Joined %d counties.  Distribution of change:", nrow(rucc)))
print(table(delta = rucc$delta, useNA = "ifany"))

# --- Geometries ----------------------------------------------------------

counties_sf <- tigris::counties(cb = TRUE, resolution = "20m", year = 2022, progress_bar = FALSE) %>%
  filter(!STATEFP %in% c("02", "15", "60", "66", "69", "72", "78")) %>%   # drop AK, HI, territories
  transmute(fips = GEOID, geometry)

counties_sf <- counties_sf %>%
  left_join(rucc, by = "fips")

# Albers Equal Area for a clean CONUS map
counties_sf <- sf::st_transform(counties_sf, 5070)

# Centroids for arrows (safe for projected CRS, dropping warnings)
centroids <- suppressWarnings(sf::st_centroid(counties_sf)) %>%
  sf::st_coordinates() %>%
  as.data.frame() %>%
  bind_cols(sf::st_drop_geometry(counties_sf)) %>%
  rename(x = X, y = Y)

# State outlines for a quiet reference layer
states_sf <- tigris::states(cb = TRUE, resolution = "20m", year = 2022, progress_bar = FALSE) %>%
  filter(!STATEFP %in% c("02", "15", "60", "66", "69", "72", "78")) %>%
  sf::st_transform(5070)

# --- Arrow placement -----------------------------------------------------

# Only draw arrows where delta != 0, scale by magnitude.
arrows_df <- centroids %>%
  filter(!is.na(delta), delta != 0) %>%
  mutate(
    direction = ifelse(delta > 0, "more rural", "less rural"),
    # Arrow endpoint: move up or down from centroid
    # Magnitude: 18 km base, + 10 km per step of change (capped)
    len = pmin(abs(delta), 5) * 14000 + 18000,
    yend = y + ifelse(delta > 0, len, -len)
  )

n_more <- sum(arrows_df$direction == "more rural")
n_less <- sum(arrows_df$direction == "less rural")
message(sprintf("Arrows: %d counties more rural, %d counties less rural, %d unchanged",
                n_more, n_less, sum(rucc$delta == 0, na.rm = TRUE)))

# --- Plot ----------------------------------------------------------------

# Fill scale: 1–3 = metro; 4–9 = nonmetro. Use a reversed green sequence with
# a desaturated "metro" color at the low end so rural counties read dark/green.
rucc_fill <- c(
  "1"  = "#f4efe6",  # most urban
  "2"  = "#e8dfce",
  "3"  = "#d6cdaa",
  "4"  = "#bcd1b2",
  "5"  = "#95b594",
  "6"  = "#6a9876",
  "7"  = "#487f5d",
  "8"  = "#2f6644",
  "9"  = "#1a4d32"   # most rural
)

rucc_labels <- c(
  "1" = "1 · Metro 1M+",
  "2" = "2 · Metro 250k–1M",
  "3" = "3 · Metro <250k",
  "4" = "4 · Nonmetro urban near metro",
  "5" = "5 · Nonmetro urban, not near metro",
  "6" = "6 · Nonmetro 2.5–20k near metro",
  "7" = "7 · Nonmetro 2.5–20k, not near metro",
  "8" = "8 · Completely rural near metro",
  "9" = "9 · Completely rural, not near metro"
)

render_map <- function(path, width_px, height_px, title_size, subtitle_size,
                       caption_size, legend_size, arrow_width = 0.42) {

  p <- ggplot() +
    # Base fill
    geom_sf(
      data = counties_sf,
      aes(fill = factor(rucc_2023, levels = 1:9)),
      color = alpha("#ffffff", 0.35),
      linewidth = 0.08
    ) +
    # State outlines — whisper
    geom_sf(
      data = states_sf,
      fill = NA, color = alpha(COL_TEXT, 0.55), linewidth = 0.35
    ) +
    # Arrows: white halo first so they pop on dark-green counties, then color
    geom_segment(
      data = arrows_df,
      aes(x = x, y = y, xend = x, yend = yend),
      arrow = arrow(length = unit(1.9, "mm"), type = "closed"),
      linewidth = arrow_width * 3.2,
      color = "#ffffff",
      alpha = 0.85,
      lineend = "round", linejoin = "mitre"
    ) +
    geom_segment(
      data = arrows_df,
      aes(x = x, y = y, xend = x, yend = yend, color = direction),
      arrow = arrow(length = unit(1.5, "mm"), type = "closed"),
      linewidth = arrow_width * 1.5,
      lineend = "round", linejoin = "mitre"
    ) +
    scale_fill_manual(
      values = rucc_fill, labels = rucc_labels,
      name = "2023 RUCC", drop = FALSE,
      guide = guide_legend(nrow = 3, byrow = TRUE,
                           title.position = "top",
                           override.aes = list(color = NA))
    ) +
    scale_color_manual(
      values = c("more rural" = COL_ACCENT, "less rural" = COL_AMBER),
      name = "Change 2013 → 2023",
      labels = c("more rural" = "↑ became more rural",
                 "less rural" = "↓ became less rural"),
      guide = guide_legend(nrow = 2,
                           override.aes = list(linewidth = 1.1, alpha = 1))
    ) +
    coord_sf(crs = 5070, expand = FALSE) +
    theme_void(base_family = "inter") +
    theme(
      plot.background = element_rect(fill = COL_BG, color = NA),
      panel.background = element_rect(fill = COL_BG, color = NA),
      plot.margin = margin(28, 22, 22, 22),
      plot.title = element_text(
        family = "fraunces", face = "bold",
        size = title_size, color = COL_TEXT,
        hjust = 0, margin = margin(b = 6)
      ),
      plot.subtitle = element_text(
        family = "inter", color = COL_MUTED,
        size = subtitle_size, hjust = 0,
        margin = margin(b = 14), lineheight = 1.15
      ),
      plot.caption = element_text(
        family = "jbmono", color = COL_SUBTLE,
        size = caption_size, hjust = 0, margin = margin(t = 10)
      ),
      plot.caption.position = "plot",
      plot.title.position = "plot",
      legend.position = "bottom",
      legend.box = "vertical",
      legend.box.just = "left",
      legend.title = element_text(family = "inter", face = "bold",
                                  size = legend_size, color = COL_TEXT),
      legend.text = element_text(family = "inter", size = legend_size - 1,
                                 color = COL_TEXT),
      legend.key.size = unit(10, "pt"),
      legend.spacing.y = unit(2, "pt")
    ) +
    labs(
      title = "How rural America shifted between 2013 and 2023",
      subtitle = "Counties shaded by their 2023 Rural–Urban Continuum Code (darker = more rural).\nArrows mark counties whose code changed since 2013: up for more rural, down for less.",
      caption = "Data: USDA Economic Research Service, Rural–Urban Continuum Codes (2013, 2023). cwimpy.com"
    )

  agg_png(path, width = width_px, height = height_px,
          units = "px", res = 150, background = COL_BG)
  print(p)
  invisible(dev.off())
  message("wrote ", path)
}

render_map(OUT_WIDE, width_px = 2000, height_px = 1200,
           title_size = 22, subtitle_size = 12, caption_size = 8,
           legend_size = 9, arrow_width = 0.38)

message("\nDone.")
