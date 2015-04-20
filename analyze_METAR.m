%% Decoding METAR data
% DESCRIPTION - actually a nice one
%
% This script reads in data from a text-file containing METAR information
% (Meteorological Aerodrome Report) obtained using the script
% pull_METAR_data.m. After decoding it is stored in readable format 
% in the structure 'metar'.
% 
% Quite some lines in the code are dedicated to catch errors that result
% from slight differences in the format of the published notifications
% all over the world.
%
% Known Issues
% - #NO#
% 
% Improvements
% - Remarks only with 'RMK' are treated -> use all digits after QNH as remark

% author: Christoph Hahn

clear; close all; clc;

%% Reading in data
metar_code = readtable('METAR.txt');
size_metar = size(metar_code,1);
metar_code = metar_code(2:2:size_metar,1);

%% Catch bugs from various notations - on string level
metar_raw = table2cell(metar_code(12,1));
metar_raw  = strrep(metar_raw, ' RMK ', ';');
[metar_raw, remarks] = strtok(metar_raw,';');
metar_raw  = strrep(metar_raw, 'AUTO ', '');
remarks = strrep(remarks, ';','');


%% Split the 'metar'-textstring into pieces
metar_raw = regexp(metar_raw,' ','split');
metar_raw = metar_raw{1,1};
% metar_raw = cell2table(metar_raw);

%% Catch bugs from various notations - on cell level

% Check whether weather message is included
% str = '-SHRA';
str = metar_raw{1,5};
intensity = '-|+| |VC|RE';
descriptor = 'MI|PR|BC|DR|BL|SH|TS|FZ';
precip = 'DZ|RA|SN|SG|IC|PL|GR|GS|UP';
obscur = 'BR|FG|FU|VA|DU|SA|HZ|PY';
other = 'PO|SQ|FC|SS|DS';

idx.int = regexp(str,intensity);
idx.desc = regexp(str,descriptor);
idx.prec = regexp(str,precip);
idx.obsc = regexp(str,obscur);
idx.oth = regexp(str,other);

s1 = ~isempty(idx.int);
s2 = ~isempty(idx.desc);
s3 = ~isempty(idx.prec);
s4 = ~isempty(idx.obsc);
s5 = ~isempty(idx.oth);

weather = s1+s2+s3+s4+s5;

% Unify wind information when spread over more than 1 cell (e.g. wind direction variability)
if length(metar_raw{1,4})>6
    metar_raw{1,3} = [metar_raw{1,3},' ', metar_raw{1,4}];
    size_mr = size(metar_raw,2);
    metar_raw(1,4:size_mr-1)= metar_raw(1,5:size_mr);
    metar_raw = metar_raw(1:size_mr-1);
end

% Unify cloud information when spread over ore than 1 cell
if weather > 0
    runvar1 = 2;
    runvar2 = 6;
else 
    runvar1 = 1;
    runvar2 = 5;
end

for t=runvar1:1:4
    check_cloud=zeros(5,1);
    check_cloud(1,1) = strcmp(metar_raw{1,runvar2+1}(1:3),'NSC');
    check_cloud(2,1) = strcmp(metar_raw{1,runvar2+1}(1:3),'FEW');
    check_cloud(3,1) = strcmp(metar_raw{1,runvar2+1}(1:3),'SCT');
    check_cloud(4,1) = strcmp(metar_raw{1,runvar2+1}(1:3),'BKN');
    check_cloud(5,1) = strcmp(metar_raw{1,runvar2+1}(1:3),'OVC');
    check_cloud = max(check_cloud);

    if check_cloud == 1
        metar_raw{1,runvar2} = [metar_raw{1,runvar2},' ', metar_raw{1,runvar2+1}];
        size_mr = size(metar_raw,2);
        metar_raw(1,runvar2+1:size_mr-1)= metar_raw(1,runvar2+2:size_mr);
        metar_raw = metar_raw(1:size_mr-1);
    end
end

% CAVOK information for clouds and visbility
cavok = strcmp(metar_raw(1,4),'CAVOK');
if  cavok == 1
    metar.Visibility = '>10km';
    metar.CloudsQuantity = 'No clouds at any level';
    metar_raw{1,8} = [];
    size_mr = size(metar_raw,2);
    metar_raw(1,6:size_mr)= metar_raw(1,5:size_mr-1);
    metar_raw{1,5} = [];
end

%% Decode METARs

% LOCATION - Real name not working, in development
load('airport_data.mat');
airport_names = table2cell(airport_data(:,2));
[~, idx_airport_data] = max(strcmp(airport_names,metar_raw{1,1}));

% metar.Location = metar_raw{1,1};
metar.Location = airport_data.Var4{idx_airport_data};

% url_location = 'http://www.airlinecodes.co.uk/aptcodesearch.asp'
% A = webread(url_location);

% TIME
% metar.Date = datenum(metar_raw(1,1),'yyyy/mm/dd');
% metar.Time = datenum(metar_raw(1,2),'hh:mm');
metar.time = datenum(metar_raw{1,2}(3:6),'hhmm');
% test = datetime(time,'TimeZone','UTC','Format','hh:mm');


% WIND
metar_raw_wind = regexp(metar_raw{1,3},' ','split');

if strcmp(metar_raw_wind{1,1}(1:3),'VRB') == 1
    metar.WindDirection = 'Variable';
else
    wind_vector = str2double(metar_raw_wind{1,1}(1:3));
    Compass = table({'N';'NE';'E';'SE';'S';'SW';'W';'NW';'N'},'VariableNames',{'Compass'});
    Deg = [0;45;90;135;180;225;270;315;360];
    [~, idx] = min(abs(Deg - wind_vector));
    metar.WindDirection = Compass{idx,1}{1,1};
end

metar.WindSpeed = str2double(metar_raw{1,3}(4:5));

% WEATHER
% metar_weather_cloud = regexp(metar_raw{1,5},' ','split');
if weather > 0
   metar.Weather = metar_raw{1,5};
end

% VISIBILITY
if cavok == 0
    skc = strcmp(metar_raw{1,4},'SKC');
    clr = strcmp(metar_raw{1,4},'CLR');

    if  skc == 1
        metar.visibility = 'No cloud/Sky clear';
    end

    if  clr == 1
        metar.visibility = 'No clouds below 12,000 ft (3,700 m)';
    end
    
    if sum(isstrprop(metar_raw{1,4}(1:4), 'digit')) == 4
        metar.Visibility = str2double(metar_raw{1,4}(1:4));
    else
        sm = strcmp(metar_raw{1,4}(3:4),'SM');
        km = strcmp(metar_raw{1,4}(3:4),'KM');
        if sm == 1
           metar.Visibility = 1852*str2double(metar_raw{1,4}(1:2)); 
        end
        if km == 1
            metar.Visibility = 1000*str2double(metar_raw{1,4}(1:2));
        end
%         if
%         metar.Visibility = '>10km';
    end
end

% CLOUDS
if weather > 0
    h=6;
else
    h=5;
end
    
if cavok == 0
    

    metar_cloud = regexp(metar_raw{1,h},' ','split');
    size_metar_cloud = size(metar_cloud,2);
      
     for k = 1:1:size_metar_cloud
         nsc = strcmp(metar_cloud{1,k}(1:3),'NSC');
         few = strcmp(metar_cloud{1,k}(1:3),'FEW');
         sct = strcmp(metar_cloud{1,k}(1:3),'SCT');
         bkn = strcmp(metar_cloud{1,k}(1:3),'BKN');
         ovc = strcmp(metar_cloud{1,k}(1:3),'OVC');
         
         metar.CloudsLevel{k,1} = 100*str2double(metar_cloud{1,k}(4:6));

         
         if nsc ==1
                metar.CloudsQuantity{k,1} = 'No significant clouds';
         elseif few == 1 
                metar.CloudsQuantity{k,1} = 'Few clouds (1-2 oktas)';
         elseif sct == 1
            metar.CloudsQuantity{k,1} = 'Scatterd clouds (3-4 oktas)';
         elseif bkn == 1
            metar.CloudsQuantity{k,1} = 'Broken clouds (5-7 oktas)';
         elseif ovc ==1
             metar.CloudsQuantity{k,1} = 'Overcast - full cloud coverage';
         else
             metar.CloudsQuantity{k,1} = 'No cloud information';
         end
     end
end

% TEMPERATURE
metar.Temperature = str2double(metar_raw{1,h+1}(1:2));
% DEW POINT
metar.Dewpoint  = str2double(metar_raw{1,h+1}(4:5));
% RELATIVE HUMIDITY
% Reference: http://www.gorhamschaffler.com/humidity_formulas.htm
Es=6.11*10.0^(7.5*metar.Temperature/(237.7+metar.Temperature));
E=6.11*10.0^(7.5*metar.Dewpoint/(237.7+metar.Dewpoint));
metar.RelHumidity =round((E/Es)*100);
% QNH
a = strcmp(metar_raw{1,h+2}(1),'A');
if a == 1
    metar.QNH = round((str2double(metar_raw{1,h+2}(2:5))*33.863753/100));
else
    metar.QNH = str2double(metar_raw{1,h+2}(2:5));
end
% REMARKS
metar.remarks = remarks{1,1};
