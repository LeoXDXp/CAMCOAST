# CAMCOAST
Coastal video-monitoring system

startup.m calls: (only last was on git by that exact name)
- PostProcess_GPP_ligne_eau_20151126.m & ComputeGPPCharLongTerm_20150127_DayByDay.m (no info)
- GPP_WaveParameters.m (might be CAMS_N2_Parameters.m and/or CAMS_N3_Parameters.m in CAMS/CAMS_TOOLS/CAMS_Programs/ ????)
- GPP_Shoreline.m (might be CAMS_N2_Shoreline.m in CAMS/CAMS_TOOLS/CAMS_Programs/)
- GPP_Actualiser.m (renamed to CAMS_Actualize.m) in CAMS/CAMS_TOOLS/CAMS_Programs)


Functions called in GPP_Shoreline:
- DetectSeuil_V20130725_GPP	line 63
- PixtoCoordGPP	line 75
Both at CAMS/CAMS_TOOLS/CAMS_Toolbox/CAMS_Functions/

Functions called in GPP_Wave_parameters:
- functions called in CAMS_N2_Parameters:
slidefun 		line 222
RadonSeparation_filt	line 236
FiltreMean 		line 239
Wave_Char 		line 262
asym 			line 268
skew			line 269
All of them also at CAMS/CAMS_TOOLS/CAMS_Toolbox/CAMS_Functions/
