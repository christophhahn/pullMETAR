%% Pulling METAR data
% DESCRIPTION
%
% This script reads gathers METAR information from the
% National Weather Service (weather.noaa.gov).
% Information for all airfields denoted in the Aerodromes.txt is pulled.
% The format of the file is.
%           Aerodromes
%           CWTA
%           EDJA
%           ...
% The information is stored in METAR.txt.

% author: Christoph Hahn

Aerodromes = readtable('Aerodromes.txt');
url_metar = 'http://weather.noaa.gov/pub/data/observations/metar/stations/';
url_taf = 'http://weather.noaa.gov/pub/data/forecasts/taf/stations/';

NrAerodromes = size(Aerodromes,1);

fileID = fopen('METAR.txt','w');
fprintf(fileID,'METAR codes \n');
tic;
for i=1:NrAerodromes
    url_metar_loc = char(strcat(url_metar, Aerodromes{i,1}, '.TXT'));
    metar_raw = webread(url_metar_loc);
    fprintf(fileID,metar_raw);
end
toc;
fclose(fileID);