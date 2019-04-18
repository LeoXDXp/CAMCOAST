%actualize
clear;
%This spcript is used to update the database of the video system
% For each new image saved in the LEVEL 1 folder of the datastore, the script detects these new images and launches the programs to obtain:

% LEVEL 2 of the databank
% - the coordinates of the water line via CAMS_N2_Shoreline.mat
% - the wave parameters via CAMS_N2_parameters.mat
% - the directions from strikes via CAMS_N2_direction.mat
%
% LEVEL 3 of the databank
% - the daily and monthly averages of HS, TP, Dir, Ligne_eau
% - the associated graphs

%% CONFIGURATION:

SITENAME = 'GRANDPOPO';
SITECODE= 'GPP';

%Folder location "CAMS_DATA":
dirdata = 'D:\Tout le stage\CAMS\CAMS_DATA\';

%Folder location "CAMS_TOOLS":
dirtools = 'D:\Tout le stage\CAMS\CAMS_TOOLS\';

%% IDENTIFICATION OF THE DATABASE PATHS OF THE DATABASE

% Adding CAMS_TOOLS Programs to the Matlab Path
addpath(genpath(dirtools));
%Folder path LEVEL 1 of the database: images folder
dirN1 = [dirdata '02 - DATA\' SITENAME '\' SITECODE '_NIVEAU 1\' ];
% LEVEL 2 folder path 
dirN2 = [dirdata '02 - DATA\' SITENAME '\' SITECODE '_NIVEAU 2\' ];
% LEVEL 3 folder path
dirN3 = [dirdata '02 - DATA\' SITENAME '\' SITECODE '_NIVEAU 3\' ];


%% UPDATE LEVEL 2
disp('UPDATE LEVEL 2')
%SHORELINE
% disp('CALCULATION OF THE POSITIONS OF THE RAILWAY')
  dirN2_s = [dirN2 SITECODE '_Shoreline_Data\'];

%Dates are inventoried for which the coastline has not been calculated
[ls_maj_s] = MAJBDD1(dirN1,dirN2_s);

% We start the calculation of the coastline for the days listed in ls_maj_s 
CAMS_N2_Shoreline(dirN1,dirN2_s,ls_maj_s)
disp('coastline up to date')

%PARAMETERS OF WAVE
disp('CALCULATION OF WAVE PARAMETERS')
 dirN2_p = [dirN2 SITECODE '_Parameters_Data\'];
[ls_maj_p] = MAJBDD1(dirN1,dirN2_p);
CAMS_N2_Parameters(dirN1,dirN2_p,ls_maj_p,0)
disp('Wave parameters up to date');


%THE WAVE DIRECTION
disp('CALCULATION OF THE DIRECTION OF THE WAVES')
 dirN2_d = [dirN2 SITECODE '_Direction_Data\'];
[ls_maj_d] = MAJBDD1(dirN1,dirN2_d);
CAMS_N2_Direction(dirN1,dirN2_d,ls_maj_d);
disp('Directions to date');

%% UPDATE LEVEL 3
disp('UPDATE LEVEL 3')
CAMS_N3_Parameters(dirN2_p,dirN2_d,dirN2_s,dirN3);
