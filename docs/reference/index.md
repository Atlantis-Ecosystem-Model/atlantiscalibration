# Package index

## All functions

- [`calculate_abund()`](calculate_abund.md) : Total abundance of an age
  class per time step
- [`calculate_biomass()`](calculate_biomass.md) : Convert a spatial
  nitrogen array to a total biomass time series
- [`calculate_Nbiomass()`](calculate_Nbiomass.md) : Collapse a spatial
  nitrogen array to a time series
- [`compare_outputs()`](compare_outputs.md) : Compare initial and
  optimised Atlantis calibration outputs
- [`create_target_files_abund()`](create_target_files_abund.md) : Create
  abundance-at-age target files and calibration settings from initial
  conditions
- [`create_target_files_biomass()`](create_target_files_biomass.md) :
  Create biomass target files and calibration inputs
- [`create_target_files_catch()`](create_target_files_catch.md) : Create
  catch target files and calibration settings from observed catch
- [`create_target_files_waa()`](create_target_files_waa.md) : Create
  weight-at-age target files and calibration settings from initial
  conditions
- [`edit_param_BHalpha_sp()`](edit_param_BHalpha_sp.md) : Edit the
  BHalpha Beverton-Holt recruitment parameter for a species
- [`edit_param_BHbeta_sp()`](edit_param_BHbeta_sp.md) : Edit the BHbeta
  Beverton-Holt recruitment parameter for a species
- [`edit_param_factor()`](edit_param_factor.md) : Multiply a parameter
  in an Atlantis parameter file by a factor
- [`edit_param_KDENR_sp()`](edit_param_KDENR_sp.md) : Edit the KDENR
  half-saturation density parameter for a species
- [`edit_param_mfc()`](edit_param_mfc.md) : Edit the maximum fishing
  capacity (mFC) parameter for a species
- [`edit_param_mq_sp()`](edit_param_mq_sp.md) : Edit the catchability
  coefficient (mQ) for a species
- [`edit_param_mum_group_age()`](edit_param_mum_group_age.md) : Edit
  maximum growth rate (mum) for all age classes across functional groups
- [`edit_param_mum_sp()`](edit_param_mum_sp.md) : Edit natural mortality
  (mum) for a single species
- [`edit_param_sp()`](edit_param_sp.md) : Edit a biology parameter for a
  species by name
- [`extract_abundance_grp()`](extract_abundance_grp.md) : Extract
  abundance time series for all age-class groups
- [`extract_abundance_sp()`](extract_abundance_sp.md) : Extract and sum
  abundance for a single species across age classes
- [`extract_abund_main()`](extract_abund_main.md) : Extract abundance
  for all functional groups defined in a groups file
- [`extract_biomass_main()`](extract_biomass_main.md) : Extract total
  biomass of each functional group from Atlantis outputs
- [`extract_catch_main()`](extract_catch_main.md) : Extract catch
  (landings) time series from Atlantis outputs
- [`extract_Nbiomass_main()`](extract_Nbiomass_main.md) : Extract total
  nitrogen biomass from Atlantis output NetCDF
- [`extract_waa()`](extract_waa.md) : Extract mean weight-at-age from
  Atlantis outputs
- [`is.stopped()`](is.stopped.md) : Test whether an Atlantis simulation
  stopped prematurely
- [`keep_track_prm()`](keep_track_prm.md) : Save the parameter files
  used in a calibration run
- [`likelihood_function()`](likelihood_function.md) : User-defined
  likelihood function for calibration
- [`make_calsettings()`](make_calsettings.md) : Create Atlantis Model
  Calibration Settings
- [`make_objfn()`](make_objfn.md) : Build the Atlantis calibration
  objective function
- [`min_max_likelihood()`](min_max_likelihood.md) : Min-max likelihood
  penalty
- [`open_catch_nc()`](open_catch_nc.md) : Open the Atlantis catch NetCDF
  output file
- [`open_fg_file()`](open_fg_file.md) : Read and filter the functional
  groups CSV file
- [`open_main_nc()`](open_main_nc.md) : Open the main Atlantis NetCDF
  output file
- [`plot_calibration_targets()`](plot_calibration_targets.md) : Plot
  calibration results for all target types and iterations
- [`process_fg()`](process_fg.md) : Load and classify functional groups
  by biomass type
- [`read_atlantis()`](read_atlantis.md) : Read Atlantis model outputs
- [`read_calibration()`](read_calibration.md) : Read calibration inputs
  and save the optimiser control settings
- [`read_parameter_table()`](read_parameter_table.md) : Read the table
  of parameters to calibrate for each functional group
- [`read_settings()`](read_settings.md) : Read the calibration settings
  file
- [`read_sh_file()`](read_sh_file.md) : Find the Atlantis shell script
  and read the files it uses
- [`repro_option()`](repro_option.md) : Create the reproduction option
  file from the biology parameter file
- [`return_real_tstop()`](return_real_tstop.md) : Read the actual stop
  time reached during a simulation
- [`return_run_tstop()`](return_run_tstop.md) : Read the scheduled stop
  time from the run parameter file
- [`run_atlantis()`](run_atlantis.md) : Execute an Atlantis simulation
  via shell script
- [`run_calibration()`](run_calibration.md) : Run the Atlantis model
  calibration
- [`run_model()`](run_model.md) : Run one step of the Atlantis
  calibration model
