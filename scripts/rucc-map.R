# -----------------------------------------------------------------------------
# RUCC-change county map for cwimpy.com
#
# Joins USDA ERS Rural-Urban Continuum Codes for 2013 and 2023 to county
# geometries, then renders a choropleth shaded by 2023 RUCC with arrows at
# county centroids pointing up where a county became more rural and down
# where it became less rural (arrow length scaled by magnitude of change).
#
# Output: images/rucc-map.png (2000x1460) for retina embed. The image carries
#         no title or subtitle: the homepage prints those as HTML above it.
#         scripts/rucc-map-stats.csv holds the counts the homepage quotes.
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
CACHE     <- here::here("scripts", "rucc-cache")
OUT_WIDE  <- here::here("images", "rucc-map.png")
OUT_STATS <- here::here("scripts", "rucc-map-stats.csv")
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
  filter(!is.na(rucc_2013), nchar(fips) == 5) %>%
  # Two counties were renamed and given new FIPS codes between the two
  # releases. Recode the 2013 rows so they match their 2023 selves.
  mutate(fips = recode(fips,
                       "46113" = "46102",   # Shannon County, SD -> Oglala Lakota
                       "02270" = "02158"))  # Wade Hampton, AK   -> Kusilvak

# Keep every 2023 county and attach its 2013 code where one exists.
# (This used to be an inner join, which dropped any county without a 2013
# match and left it blank on the map. Connecticut is the main case: it
# replaced its eight counties with nine planning regions in 2022, so its
# 2023 codes have no 2013 counterpart. Those areas are now shaded by their
# 2023 code and simply get no change arrow.)
rucc <- rucc_2023 %>%
  left_join(rucc_2013, by = "fips") %>%
  mutate(delta = rucc_2023 - rucc_2013)  # + = more rural, - = less rural; NA = not comparable

message(sprintf("%d counties in the 2023 file, %d comparable with 2013.  Distribution of change:",
                nrow(rucc), sum(!is.na(rucc$delta))))
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
    # Magnitude: 18 km base, + 14 km per step of change (capped at 5 steps)
    len = pmin(abs(delta), 5) * 14000 + 18000,
    yend = y + ifelse(delta > 0, len, -len)
  )

n_more <- sum(arrows_df$direction == "more rural")
n_less <- sum(arrows_df$direction == "less rural")

# Counts for the homepage sentence. All three use the same set of counties:
# the lower-48 counties drawn on the map that have a code in both years.
# (The homepage used to quote a total that included Alaska, Hawaii and
# Puerto Rico next to change counts for the lower 48 only.)
map_stats <- tibble::tibble(
  n_comparable = sum(!is.na(centroids$delta)),
  n_more_rural = n_more,
  n_less_rural = n_less,
  n_unchanged  = sum(centroids$delta == 0, na.rm = TRUE),
  n_not_comparable = sum(is.na(centroids$delta))
)
readr::write_csv(map_stats, OUT_STATS)
message(sprintf("Lower 48: %d comparable counties; %d more rural, %d less rural, %d unchanged; %d not comparable",
                map_stats$n_comparable, n_more, n_less, map_stats$n_unchanged, map_stats$n_not_comparable))

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
      na.value = "#e3e1da", na.translate = FALSE,   # no "NA" key in the legend
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
      plot.margin = margin(14, 22, 22, 22),
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
    # No title or subtitle here: the homepage prints both as text above the
    # figure, and repeating them inside the image made the map itself small.
    labs(
      caption = "Data: USDA Economic Research Service, Rural–Urban Continuum Codes (2013, 2023). cwimpy.com"
    )

  agg_png(path, width = width_px, height = height_px,
          units = "px", res = 150, background = COL_BG)
  print(p)
  invisible(dev.off())
  message("wrote ", path)
}

render_map(OUT_WIDE, width_px = 2000, height_px = 1460,
           title_size = 22, subtitle_size = 12, caption_size = 8,
           legend_size = 9, arrow_width = 0.38)

# --- WebP copy for the web page ------------------------------------------
# The PNG is about 1.1 MB; a WebP at quality 88 is about a third of that and
# looks the same at page size. The homepage embeds the .webp. cwebp is a small
# command-line tool from Google (macOS: `brew install webp`). If it is not
# installed the PNG is still written, but the page keeps showing the previous
# .webp, so the script says so loudly.
OUT_WEBP <- sub("\\.png$", ".webp", OUT_WIDE)
if (nzchar(Sys.which("cwebp"))) {
  system2("cwebp", c("-quiet", "-q", "88", shQuote(OUT_WIDE), "-o", shQuote(OUT_WEBP)))
  message("wrote ", OUT_WEBP)
} else {
  warning("cwebp not found: images/rucc-map.webp was NOT refreshed. ",
          "Install it (brew install webp) and rerun.", call. = FALSE)
}

message("\nDone.")
