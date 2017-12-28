% chooseband.m
% This file loops through of kx, ky points and allows the user to choose
% the band of interest
% Author: hyzhou, 01/25/2016
% please run MEEPnodalLineExtract.m before running this script

%% Find bands
kxvals = unique(datatable(:,1));
kyvals = unique(datatable(:,2));
chosentab = [];
% we assume that the primary direction of examination is the x direction
for i = 1:length(kyvals)
    kyc = kyvals(i);
    ind = abs(datatable(:,2)-kyc)<1e-6;
    ind1 = abs(table1(:,2)-kyc)<1e-6;
    kxall = datatable(ind,1);
    tableall = datatable(ind,:);
    kx2 = kx1(ind1);
    table2 = table1(ind1,:);
    hold off;
    plot(kxall,tableall(:,4),'bo');
    hold on
    plot(kx2,table2(:,4),'ro');
    legend(sprintf('ky=%f',kyc))
    for j = 1:length(kx2)
        plot(kx2(j),table2(j,4),'go');
        c = '';
        while isempty(c)
            c = input('Green point good? y for yes, # for different band number, n for no\n','s');
        end
        % bands are counted with the lowest one as 1
        if c == 'y'
            chosentab = vertcat(chosentab,table2(j,:));
        elseif c == 'n'
            plot(kx2(j),table2(j,4),'bo');
        else
            c = str2double(c);
            ind2 = abs(kxall-kx2(j))<1e-6;  % points with the same kx
            tabletemp = tableall(ind2,:);
            [~,ind2] = sort(tabletemp(:,4));
            plot(kx2(j),table2(j,4),'bo');
            plot(kx2(j),tabletemp(ind2(c),4),'go');
            c1 = input('Substitution good? y for yes, n for no','s');
            % discard point if substitutino not good
            if c1 == 'y'
                chosentab = vertcat(chosentab,tabletemp(ind2(c),:));
            else
                plot(kx2(j),table2(j,4),'bo');
            end
        end
    end
end

%% Plot results on chosen table
% let us first look at the decay of cx
kx2 = chosentab(:,1);
ky2 =  chosentab(:,2);
refst = 1;
refend = 4.25;  % in a future version this should be read from the file
distvals = linspace(refst,refend,nref+1);
lambda = zeros(size(kx2));
amp = zeros(size(kx2));
for i = 1:size(chosentab(:,1))
    cxvals = abs(chosentab(i,[16+1:8:16+1+8*nref]));
    % change to 2 for cy and 3 for cz 
    %f3 = figure;
    %plot(distvals,log(cxvals),'o-')
    x = distvals;
    y = (cxvals);
    [temp,~,~] = createFit(x,y);
    lambda(i) = -1/temp(2);
    amp(i) = temp(1);
    %pause(1)
    %close(f3)
end
figure
stem3(kx2,ky2,chosentab(:,4))
figure;
stem3(kx2,ky2,amp)
zlim([0,100])
figure
stem3(kx2,ky2,lambda)
zlim([0,10])
ind = abs(ky2-kyc)<1e-6;

%% Process c vector integrals for this mode
f3 = figure;
start = 16+8*nref;
h3 = stem3(kx2,ky2,abs(chosentab(:,start+1))./abs(chosentab(:,6)));    % normalized cx
xlabel('kx')
ylabel('ky')
zlabel('cxtop')
f4 = figure;
h4 = stem3(kx2,ky2,abs(chosentab(:,start+2))./abs(chosentab(:,6)));    % normalized cy
xlabel('kx')
ylabel('ky')
zlabel('cytop')
anglextop = angle(chosentab(:,start+1));
angleztop = angle(chosentab(:,start+2));
anglediftop = anglextop-angleztop;  % phase difference
f5 = figure;
h5 = stem3(kx2,ky2,mod(anglediftop,pi));
xlabel('kx')
ylabel('ky')
zlabel('x-z phase difference top')
%{
f6 = figure;
h6 = stem3(kx2,ky2,abs(chosentab(:,start+4))./abs(chosentab(:,6)));    % normalized cx
xlabel('kx')
ylabel('ky')
zlabel('cxbottom')
f7 = figure;
h7 = stem3(kx2,ky2,abs(chosentab(:,start+5))./abs(chosentab(:,6)));    % normalized cy
xlabel('kx')
ylabel('ky')
zlabel('cybottom')
anglexbot = angle(chosentab(:,16));
anglezbot = angle(chosentab(:,17));
angledifbot = anglexbot-anglezbot;  % phase difference
f8 = figure;
angledifbot = mod(angledifbot,pi);
uthres = 2.9;
lthres = 2.85;
ind = angledifbot>lthres & angledifbot<uthres;
h8 = stem3(kx2(ind),ky2(ind),angledifbot(ind));
%h8 = stem3(kx2,ky2,mod(angledifbot,pi));
xlabel('kx')
ylabel('ky')
zlabel('x-z phase difference bottom')
%}
f9 = figure;
h9 = stem3(kx2,ky2,chosentab(:,4)-mean(chosentab(:,4)));
xlabel('kx')
ylabel('ky')
zlabel('frequency')
hold on;
%stem3(kx2,ky2,modefunc(kx2,ky2),'r')
f10 = figure;
h10 = stem3(kx2,ky2,log10(chosentab(:,5)));
xlabel('kx')
ylabel('ky')
zlabel('quality factor')