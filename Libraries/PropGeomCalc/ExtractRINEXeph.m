function       eph=ExtractRINEXeph(userInput)
% USAGE:  Extract RINEX ephemeris file from website 
% https://cddis.nasa.gov/archive/gnss/data/daily/
% ref:https://www.cnblogs.com/Gou-Hailong/p/14258492.html

% ftp://cddis.gsfc.nasa.gov/gnss/data/daily/YYYY/DDD/YYn/brdcDDD0.YYn.Z
% and store the parameters in the eph struct:

year = userInput.dateTime(1);
day_of_year = datenum(userInput.dateTime(1),...
    userInput.dateTime(2),userInput.dateTime(3))-datenum(year-1,12,31);
PRN = userInput.PRN;

datadir = 'https://cddis.nasa.gov/archive/gnss/data/daily/';
YYYY = num2str(year);
DDD = num2str(day_of_year);
if length(DDD)== 1
    DDD = ['0','0',DDD];
elseif length(DDD) == 2
    DDD = ['0',DDD];
end
YY = YYYY(3:4);
RinexFile = [datadir,YYYY,'/',DDD,'/',YY,'n/brdc',DDD,'0.',YY,'n.Z'];
disp(RinexFile);
[~,ephfile] = fileparts(RinexFile);
if ~exist(ephfile,'file')
    if ~exist([ephfile,'.Z'],'file') 
        gunzip(RinexFile,pwd)
    end
    fprintf('Unzipping ephemeris file %s \n',ephfile)
    fprintf(['Some Matlab versions do not recognize .zip compression.' ...
    ' If error occurred, please go to the folder and manually uncompress the .Z ephemeris file.']);
    system(['uncompress ',ephfile,'.Z']);
    fprintf('Using ephemeris file %s \n',ephfile)
    %Matlab R2015a does not recognize .zip compression => manual uncompress nessary!!
else
    fprintf('Using ephemeris file %s \n',ephfile)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[eph,~] =rinexe(ephfile); %Extract 21XN ephemeris files
%eph(21,:) is toe for each 21-element ephemeris
neph=find(eph(1,:)==PRN);
if isempty(neph)
    error('RINEX error ')
else
    eph=eph(:,neph);
end

% truncate the eph data to right after the user input time.
[GPStime_sec_start,GPSweek,GPSweek_z,leapsec]=UT2GPStime(userInput.dateTime);

ind = find(eph(end,:)>GPStime_sec_start,1,'first')-1;
if isempty(ind)
    ind = length(eph(end,:));
elseif ind==0
    ind = 1;
end
eph = eph(:,ind);

return