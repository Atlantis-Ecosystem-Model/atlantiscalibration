netcdf SETAS_FPS1_distrib {
dimensions:
	t = UNLIMITED ; // (4 currently)
	b = 11 ;
	z = 7 ;
variables:
	double t(t) ;
		t:units = "seconds since 1983-01-01 00:00:00 +10" ;
		t:dt = 864000. ;
	double FPS_stage_1(t, b) ;
		FPS_stage_1:units = " " ;
		FPS_stage_1:_FillValue = 0.0 ;
		FPS_stage_1:missing_value = 0.0;
		FPS_stage_1:valid_min = 0.0;
		FPS_stage_1:valid_max = 1.0;

// global attributes:
		:title = "trivial" ;
		:geometry = "VMPA_setas.bgm" ;
		:parameters = "" ;
data:

 t = 0, 864000, 1728000, 2592000;
 
 FPS_stage_1 =
    0, 0.34, 0.25, 0.25, 0.08, 0.08, 0, 0, 0, 0, 0,
    0, 0.6, 0.1, 0.1, 0.1, 0.1, 0, 0, 0, 0, 0,
    0, 0.3, 0.3, 0.2, 0.1, 0.1, 0, 0, 0, 0, 0,
    0, 0.8, 0.05, 0.05, 0.05, 0.05, 0, 0, 0, 0, 0;
   }
 
