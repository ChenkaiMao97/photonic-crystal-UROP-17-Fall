% This file analyzes the frequency bands from MEEP simulations
%close all
%% Import data
%filename = 'bands_fcen0d6/freq_inittest_ey.csv';
filename = 'freq_inittest_ey.csv';
datatable = importfreqsfile(filename);
kx = datatable(:,1);
freq = datatable(:,4);
figure
plot(kx,freq,'o')
