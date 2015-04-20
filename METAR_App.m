function varargout = METAR_App(varargin)
% METAR_APP MATLAB code for METAR_App.fig
%      METAR_APP, by itself, creates a new METAR_APP or raises the existing
%      singleton*.
%
%      H = METAR_APP returns the handle to a new METAR_APP or the handle to
%      the existing sing0leton*.
%
%      METAR_APP('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in METAR_APP.M with the given input arguments.
%
%      METAR_APP('Property','Value',...) creates a new METAR_APP or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before METAR_App_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to METAR_App_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help METAR_App

% Last Modified by GUIDE v2.5 01-Oct-2014 16:01:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @METAR_App_OpeningFcn, ...
                   'gui_OutputFcn',  @METAR_App_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before METAR_App is made visible.
function METAR_App_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to METAR_App (see VARARGIN)

% Choose default command line output for METAR_App
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes METAR_App wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = METAR_App_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double

handles.aerodrome = get(hObject,'String');
guidata(hObject,handles);


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%% Pulling data
Aerodrome = handles.aerodrome;
url_1 = 'http://weather.noaa.gov/pub/data/observations/metar/stations/';
% url_2 = 'http://weather.noaa.gov/pub/data/forecasts/shorttaf/stations/';
url_metar = char(strcat(url_1, Aerodrome, '.TXT'));
% url_metar = [url_1,Aerodrome,'.TXT'];
% url_taf = [url_2,Aerodrome,'.TXT'];

% clear url_1 url_2;

metar_raw = webread(url_metar);
% taf = webread(url_taf);


%% Analyzing data
 run analyze_METAR.m

set(handles.text5, 'String', num2date(handles.metar.Date));
set(handles.text11, 'String', num2str(handles.metar.Temperature));
