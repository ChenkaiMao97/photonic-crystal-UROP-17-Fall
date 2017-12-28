% This script takes COMSOL exported simulation results (in the form of a
% table saved as a .txt file) and filters out the bad modes, also giving
% information about whether the remaining modes are TE/TM etc. It then fits
% the x and y nodal line positions using a linear assumption

close all;
kyc = 0;  % value of ky that we choose to focus on
%
%% Import data;
foldername = './';
filename = 'h1d2_hz';
savefigures = 'false';
nref = 10;   % number of reference planes
datatable = MEEPloadTable(strcat(foldername,filename,'.csv'),nref);
%datatable = datatable(datatable(:,1)>=0&datatable(:,2)>=0,:);
% In the usual form of exporting values, the values of the table are, in
% order, kx, ky, ngrad, lambdanum, f, Q, |E|^2 integral over entire domain, |E|^2
% integral over central region, total area, central integral region area,
% integrals of |Ex|, |Ey|, |Ez| over the entire domain, line integrals of
% ux, uy, uz on the top and bottom, poynting flux on top and bottom, length of line

%% Import parameters of simulation
%[parnames,parvals] = importParam(strcat(filename,'par.csv'));

%% Filter modes
Qthres = 0;   % threshold value for mode filtering via quality factor
concthres = 1/100;   % minimum concentration factor of total electric
% field within the central region
pol = 0;    % 0 for all polarizations, 1 for TE, 2 for TM, 3 for not TE, 4 for not TM
% here I'm assuming that not TE could be different from TM due to weird modes
% in the case of MEEP simulations, polarization is already preselected
polthres = 1e-6;    % threshold for telling polarization
% we shall simply overwrite the matrix
goodind = datatable(:,7)./datatable(:,6);
datatable = datatable(goodind>concthres,:);
%datatable = datatable(datatable(:,5)>Qthres,:);
switch pol
    case 1
        datatable = datatable(datatable(:,10)<polthres,:);
    case 2
        datatable = datatable(datatable(:,12)<polthres,:);
    case 3
        datatable = datatable(datatable(:,10)>polthres,:);
    case 4
        datatable = datatable(datatable(:,12)>polthres,:);
end

%% Plot frequencies
kx = real(datatable(:,1));
ky = real(datatable(:,2));  % save into real form
f1 = figure;
hold on;
%
h1 = plot(kx(abs(ky-kyc)<1e-6),datatable(abs(ky-kyc)<1e-6,4),'o');
xlabel('kx')
ylabel('frequency')
f2 = figure;
h2 = semilogy(kx(abs(ky-kyc)<1e-6),datatable(abs(ky-kyc)<1e-6,5),'o');
hold on;
xlabel('kx')
ylabel('quality factor')

%% Select a particular mode based on a known or guessed mode appearance
a = [-0.16,0.1,0.3];
modefunc = @(x,y) a(1)*abs(x)+a(2)*abs(y)+a(3);
nummodes = 2;
% number of modes to select that are within freqdistthres from the
% reference value and are closest to the reference
freqdistthres = 0.5;   % threshold for frequency distance
% extract range of k vectors that have been scanned across
kxrange = unique(kx);
kyrange = unique(ky);
% we shall only save the indices and retrieve relevant information later
indtable = zeros(length(kxrange),length(kyrange),nummodes);
for i = 1:size(datatable,1)
    % if frequency distance is within threshold
    freqdist = abs(datatable(i,4)-modefunc(datatable(i,1),datatable(i,2)));
    if freqdist<freqdistthres
        % find index in indtable
        k1 = find(kxrange == datatable(i,1));
        k2 = find(kyrange == datatable(i,2));
        j = 1;
        % loop until find place to insert mode
        while j<=nummodes && indtable(k1,k2,j)~=0 &&...
                freqdist > abs(datatable(indtable(k1,k2,j),4)-modefunc(datatable(i,1),datatable(i,2)))
            j = j+1;
        end
        if j<=nummodes  % found mode correctly
            temp1 = i;
            while j<=nummodes && indtable(k1,k2,j)~=0
                temp2 = indtable(k1,k2,j);
                indtable(k1,k2,j) = temp1;
                temp1 = temp2;
                j = j+1;
            end
            if j<=nummodes
                indtable(k1,k2,j) = temp1;
            end
        end
    end
end
%
%% Pick out modes that are from the closest one only for analysis purposes
[~,~,ind1] = find(indtable(:,:,1));     % find closest modes
table1 = datatable(ind1,:);
figure(f1)
kx1 = real(table1(:,1));
ky1 = real(table1(:,2));  % save into real form
h1a = plot(kx1(abs(ky1-kyc)<1e-6,1),table1(abs(ky1-kyc)<1e-6,4),'or');
figure(f2)
h2a = semilogy(kx1(abs(ky1-kyc)<1e-6),table1(abs(ky1-kyc)<1e-6,5),'or');

%% Perform exponential fit to find evanescent tail length scale
% let us first look at the decay of cx
refst = 1;
refend = 4.25;  % in a future version this should be read from the file
distvals = linspace(refst,refend,nref+1);
lambda = zeros(size(kx1));
amp = zeros(size(kx1));
for i = 1:size(table1(:,1))
    cxvals = abs(table1(i,[16+4:8:16+4+8*nref]));
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
stem3(kx1,ky1,table1(:,4))
figure;
stem3(kx1,ky1,amp)
zlim([0,100])
figure
stem3(kx1,ky1,lambda)
zlim([0,10])
ind = abs(ky1-kyc)<1e-6;
kx2 = kx1(ind);
lambda2 = lambda(ind);
amp2 = amp(ind);
freq2 = table1(ind,4);
kz2 = sqrt(kx2.^2-freq2.^2);
%figure;
%plot(kx2,lambda(ind));
%figure
%plot(kx2,amp2,'o-')

%% Plotting of a particular exponential plot at a certain k point
kxp = 0.2;    % k vector for plotting
kyp = 0.2;
ind = abs(kx1-kxp)<1e-6 & abs(ky1-kyp)<1e-6;
x = distvals;
y = abs(table1(ind,[16+2:8:16+2+8*nref]));
[temp,~,~] = createFit(x,y,1);
%figure
%plot(x,cxvals)

%% Transform to cx, cy and plot
%{
%s1 = repmat([1,0,0],[length(kx1),1]);
s1 = [ky1./sqrt(kx1.^2+ky1.^2),-kx1./sqrt(kx1.^2+ky1.^2),zeros(length(kx1),1)];
freq1 = real(table1(:,4));
kz1 = sqrt(freq1.^2-kx1.^2-ky1.^2);
p1 = [kz1.*kx1./freq1.^2,kz1.*ky1./freq1.^2,-(kx1.^2+ky1.^2)./freq1.^2];
%p1 = repmat([0,1,0],[length(kx1),1]);
%cx1 = table1(:,13)./abs(table1(:,6));
cx1 = table1(:,13);
cy1 = table1(:,14);
cz1 = table1(:,15);
cs1 = zeros(length(kx1),1);
cp1 = zeros(length(kx1),1);
for i = 1:length(kx1)
    cs1(i) = dot(s1(i,:),[cx1(i),cy1(i),cz1(i)]);
    cp1(i) = dot(p1(i,:),[cx1(i),cy1(i),cz1(i)]);
end
anglestop = angle(cs1);
angleptop = angle(cp1);
anglediftop = (mod(anglestop-angleptop,2*pi));
figure;
%stem3(kx1,ky1,anglediftop)
plot(kx1(abs(ky1-0.04)<1e-6),anglediftop(abs(ky1-0.04)<1e-6),'o')
%}
%
%% Process c vector integrals for this mode
f3 = figure;
h3 = stem3(kx1,ky1,abs(table1(:,13))./abs(table1(:,6)));    % normalized cx
xlabel('kx')
ylabel('ky')
zlabel('cxtop')
f4 = figure;
h4 = stem3(kx1,ky1,abs(table1(:,14))./abs(table1(:,6)));    % normalized cy
xlabel('kx')
ylabel('ky')
zlabel('cytop')
anglextop = angle(table1(:,13));
angleztop = angle(table1(:,14));
anglediftop = anglextop-angleztop;  % phase difference
f5 = figure;
h5 = stem3(kx1,ky1,mod(anglediftop,pi));
xlabel('kx')
ylabel('ky')
zlabel('x-z phase difference top')
f6 = figure;
h6 = stem3(kx1,ky1,abs(table1(:,16))./abs(table1(:,6)));    % normalized cx
xlabel('kx')
ylabel('ky')
zlabel('cxbottom')
f7 = figure;
h7 = stem3(kx1,ky1,abs(table1(:,17))./abs(table1(:,6)));    % normalized cy
xlabel('kx')
ylabel('ky')
zlabel('cybottom')
anglexbot = angle(table1(:,16));
anglezbot = angle(table1(:,17));
angledifbot = anglexbot-anglezbot;  % phase difference
f8 = figure;
angledifbot = mod(angledifbot,pi);
uthres = 2.9;
lthres = 2.85;
ind = angledifbot>lthres & angledifbot<uthres;
h8 = stem3(kx1(ind),ky1(ind),angledifbot(ind));
%h8 = stem3(kx1,ky1,mod(angledifbot,pi));
xlabel('kx')
ylabel('ky')
zlabel('x-z phase difference bottom')
f9 = figure;
h9 = stem3(kx1,ky1,table1(:,4)-mean(table1(:,4)));
xlabel('kx')
ylabel('ky')
zlabel('frequency')
hold on;
%stem3(kx1,ky1,modefunc(kx1,ky1),'r')
f10 = figure;
h10 = stem3(kx1,ky1,log10(table1(:,5)));
xlabel('kx')
ylabel('ky')
zlabel('quality factor')


%}

%% Plotting asymmetry of cx values on x axis
%{
kxvals = unique(table1(:,1));
kyvals = unique(table1(:,2));
i = 1;
%pt = abs(table1(table1(:,2)==kyvals(i),13)).^2+abs(table1(table1(:,2)==kyvals(i),14)).^2;
%pb = abs(table1(table1(:,2)==kyvals(i),16)).^2+abs(table1(table1(:,2)==kyvals(i),17)).^2;
%x = table1(table1(:,2)==kyvals(i),1);
pt = abs(table1(table1(:,2)<1e-6,13)).^2+abs(table1(table1(:,2)<1e-6,14)).^2;
pb = abs(table1(table1(:,2)<1e-6,16)).^2+abs(table1(table1(:,2)<1e-6,17)).^2;
x = table1(table1(:,2)<1e-6,1);
%pt = abs(table1(table1(:,2)==kyvals(i),19));
%pb = abs(table1(table1(:,2)==kyvals(i),20));
y = pt./pb;
fa1 = figure;
ha1 = semilogy(x,y,'o-');
xlabel('kx')
ylabel('|c_t^2/c_b^2|')
y = pb./pt;
fa2 = figure;
ha2 = semilogy(x,y,'o-');
xlabel('kx')
ylabel('|c_b^2/c_t^2|')
y1 = pt./(pb+pt);
y2 = pb./(pb+pt);
fa3 = figure;
ha3 = plot(x,y1,'o-',x,y2,'o-');
xlabel('kx')
ylabel('portion of radiation')
legend('top','bottom')

if strcmp(savefigures,'true')
    figlist = findobj('type','figure');
    for i = 1:numel(figlist)
        saveas(figlist(i),strcat(filename,'_fig',num2str(i),'.fig'));
    end
end
%}

%% Perform fitting of x-direction cut to find location of nodal line
% fit of top for each x
% test with ky==0 first
%{
kxvals = unique(table1(:,1));
kyvals = unique(table1(:,2));
i = 3;
x = table1(table1(:,2)==kyvals(i),1);
%y = abs(table1(table1(:,2)==kyvals(i),13))./abs(table1(table1(:,2)==kyvals(i),16));
y = abs(table1(table1(:,2)==kyvals(i),13)./table1(table1(:,2)==kyvals(i),6));
sig = min(y)*ones(length(y),1);   % should update later on

% First assign x, y, sx, sy, sig
sgn=0;  % Ignore the following analytic derivatives and calculate them numerically instead (usual case)
dYda={@(x,a) 1,
    @(x,a) exp(-x/a(5)),
    @(x,a) exp(-x/a(6)),
    @(x,a) a(2)/a(5)^2*exp(-x/a(5)).*x,
    @(x,a) a(3)/a(6)^2*exp(-x/a(6)).*x};
algselect=1;

% first stage
function_xcut = @(x,a) a(1)*sqrt((x-a(2)).^2+a(3).^2);    % assuming there is a residue imaginary part as well
%function_xcut = @(x,a) a(1)*abs(x-a(2));
[~,I] = min(y);
[temp,~] = max(y);
y(I+1:end) = -y(I+1:end);
a0=[temp,x(I),1];
%a0 = [temp,x(I)];
% first stage fit
if algselect==0
    [a,aerr,chisq,yfit,corr] = levmar(x,y,sig,function_xcut,a0,dYda,sgn);
else
    [a,aerr,chisq,yfit] = gradsearch(x,y,sig,function_xcut,a0);
end
dof=length(x)-length(a);
prob=100*(1-chi2cdf(chisq,dof));

%close all;
figure;
plot(x,y,'-o');
xlabel('kx')
ylabel('|cx|')
%

%% Perform fitting of x-direction cut to find location of nodal line
% fit of top for each x
% test with ky==0 first
%
kxvals = unique(table1(:,1));
kyvals = unique(table1(:,2));
%i = 5;
x = table1(table1(:,2)==kyvals(i),1);
%y = abs(table1(table1(:,2)==kyvals(i),13))./abs(table1(table1(:,2)==kyvals(i),16));
y = abs(table1(table1(:,2)==kyvals(i),13)./table1(table1(:,2)==kyvals(i),6));
sig = min(y)*ones(length(y),1);   % should update later on

[~,I] = min(y);
[temp,~] = max(y);
y(I:end) = -y(I:end);

%close all;
figure;
plot(x,y,'-o');
xlabel('kx')
ylabel('|cx|')
%

%% Find maximum Q k point's asymmetry value
[C,I] = max(table1(:,5));
figure(fa2);
hold on;
plot(table1(I,1),pb(I)/pt(I),'or');

%}