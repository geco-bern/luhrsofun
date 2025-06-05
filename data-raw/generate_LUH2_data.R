state_file <- file.path(tempdir(), "multiple-states_input4MIPs_landState_ScenarioMIP_UofMD-IMAGE-ssp126-2-1-e_gn_2100-2300.nc")
utils::download.file(
  "https://luh.umd.edu/LUH2/LUH2_v2f/extensions/LUH2_SSP1_RCP26_extension/multiple-states_input4MIPs_landState_ScenarioMIP_UofMD-IMAGE-ssp126-2-1-e_gn_2100-2300.nc",
  destfile = state_file, method = "wget", extra = "--no-check-certificate"
)

trans_file <- file.path(tempdir(), "multiple-transitions_input4MIPs_landState_ScenarioMIP_UofMD-IMAGE-ssp126-2-1-e_gn_2100-2300.nc")
utils::download.file(
  "https://luh.umd.edu/LUH2/LUH2_v2f/extensions/LUH2_SSP1_RCP26_extension/multiple-transitions_input4MIPs_landState_ScenarioMIP_UofMD-IMAGE-ssp126-2-1-e_gn_2100-2300.nc",
  destfile = trans_file,
  method = "wget", extra = "--no-check-certificate"
)
