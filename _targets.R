# Created by use_targets().
# Follow the comments below to fill in this target script.
# Then follow the manual to check and run the pipeline:
#   https://books.ropensci.org/targets/walkthrough.html#inspect-the-pipeline

# Load packages required to define the pipeline:
library(targets)
library(tarchetypes) # Load other packages as needed.
library(here)
library(tibble)

# Set target options:
tar_option_set(
  # Packages that your targets need for their tasks.
  packages = c(
    "here",
    "tibble",
    "dplyr",
    "lubridate",
    "purrr",
    "rdhs",
    "stringr",
    "DHSHarmonization"
  ) 
  # format = "qs", # Optionally set the default storage format. qs is fast.
  #
  # Pipelines that take a long time to run may benefit from
  # optional distributed computing. To use this capability
  # in tar_make(), supply a {crew} controller
  # as discussed at https://books.ropensci.org/targets/crew.html.
  # Choose a controller that suits your needs. For example, the following
  # sets a controller that scales up to a maximum of two workers
  # which run as local R processes. Each worker launches when there is work
  # to do and exits if 60 seconds pass with no tasks to run.
  #
  #   controller = crew::crew_controller_local(workers = 2, seconds_idle = 60)
  #
  # Alternatively, if you want workers to run on a high-performance computing
  # cluster, select a controller from the {crew.cluster} package.
  # For the cloud, see plugin packages like {crew.aws.batch}.
  # The following example is a controller for Sun Grid Engine (SGE).
  #
  #   controller = crew.cluster::crew_controller_sge(
  #     # Number of workers that the pipeline can scale up to:
  #     workers = 10,
  #     # It is recommended to set an idle time so workers can shut themselves
  #     # down if they are not running tasks.
  #     seconds_idle = 120,
  #     # Many clusters install R as an environment module, and you can load it
  #     # with the script_lines argument. To select a specific verison of R,
  #     # you may need to include a version string, e.g. "module load R/4.3.2".
  #     # Check with your system administrator if you are unsure.
  #     script_lines = "module load R"
  #   )
  #
  # Set other options as needed.
)

# Run the R scripts in the R/ folder with your custom functions:
tar_source()
# tar_source("other_functions.R") # Source other scripts as needed.

# Replace the target list below with your own:
list(
    tar_file(
    name = cfg,
    command = "config.yml"
  ),
  # link input data from google drive to local data folder
  tar_target(
    name = raw_data_ready,
    command = link_inputs(cfg_path = cfg),
    error = "stop"
    # format = "qs" # Efficient storage for general data objects.
  ),
  # list raw data files
  tar_target(
    name = raw_gps_dhs_files,
    command = {
      if(!raw_data_ready) stop("raw_data_ready is FALSE, cannot proceed")
      list_raw_gps_dhs()
    },
    format = "file"
  ),
  tar_target(
    name = raw_flat_dhs_files,
    command = {
      if(!raw_data_ready) stop("raw_data_ready is FALSE, cannot proceed")
      list_raw_flat_dhs()
    },
    format = "file"
  ),
  # 2) For each recode type, create its own pair of targets
  tar_map(
    values = tibble(type = c("BR", "HW", "CR", "HR", "IR", "KR", "PR", "WI", "SQ", "MR", "FW")),
    names  = type,  # suffix targets with the recode type, e.g. _BR

    # Pick only the files for this type (explicit dep on raw_flat_dhs_files)
    tar_target(
      files_for_type,
      {
        if(!raw_data_ready) stop("raw_data_ready is FALSE, cannot proceed")
        raw_flat_dhs_files
        stringr::str_subset(raw_flat_dhs_files, paste0("MD", type))
      }
    ),

    # Read/merge all files for this type in one target
    tar_target(
      dhs_data,
      load_flat_dhs_data(files_for_type),
      pattern = map(files_for_type),
      iteration = "list"   # files_for_type is a character vector; pass as list
    )
  ),
  # tar_target(
  #   name = raw_flat_dhs_files_BR, # birth recode
  #   command = {
  #       if(!raw_data_ready) stop("raw_data_ready is FALSE, cannot proceed")
  #       raw_flat_dhs_files %>%
  #         str_subset("BR")
  #     }
  # ),
  # tar_target(
  #   name = raw_flat_dhs_files_CR, # child recode
  #   command = {
  #       if(!raw_data_ready) stop("raw_data_ready is FALSE, cannot proceed")
  #       raw_flat_dhs_files %>%
  #         str_subset("CR")
  #     }
  # ),
  # read into a branch for each survey type
  # tar_target(
  #   dhs_data_BR,
  #   command = {
  #     load_flat_dhs_data(raw_flat_dhs_files_BR)
  #   },
  #   pattern = map(raw_flat_dhs_files_BR),
  #   iteration = "list"
  # ),
  # tar_target(
  #   dhs_data_CR,
  #   command = {
  #     load_flat_dhs_data(raw_flat_dhs_files_CR)
  #   },
  #   pattern = map(raw_flat_dhs_files_CR),
  #   iteration = "list"
  # ),
  tar_target(
    name = raw_gps_covar_files,
    command = {
      raw_data_ready
      list_raw_gps_covars()
    },
    format = "file"
  ),
  tar_target(
    name = raw_flat_mis_files,
    command = {
      raw_data_ready
      list_raw_flat_mis()
    },
    format = "file"
  )

)
