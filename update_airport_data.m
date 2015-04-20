%% Update aiport information
% DESCRIPTION
%
% This script creates a table called 'airport_data' using two ways.
% 1. The default way is reading in the file 'airport_data.mat'
% located in C:\Work\METAR_TAF. This is also the fastest option.
% 
% 2. As the file on the website http://ourairports.com/data/airports.csv is 
% updated regularly it may be good to pull current data from time to time.
% Just uncommnet the second section of the script.

% author: Christoph Hahn

clear; close all; clc;

% Way 1 - Actually pulling data from the web
load('airport_data.mat')

% Way 2 - Reading in offline information
% airport_data = webread('http://ourairports.com/data/airports.csv');
% save('airport_data.mat');

