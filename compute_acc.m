% clear;
% clc;

addpath ('mexFunctions');
addpath('third_party/Tardif');

%% default parameters
ARGS = FACADE_ARGS_default();
const = FACADE_const();
ARGS.mKinv = [];

ARGS.plot = 0;
ARGS.savePlot = false;

% ARGS.manhattanVP = true;
ARGS.manhattanVP = false;
ARGS.REF_remNonManhantan = true;
ARGS.ALL_calibrated = false;
ARGS.ERROR = const.ERROR_DIST;

%% zihan's parameters
imgFolder     = '/data/vnet/baseline/vpdet_tmm17/neurvps/image';
result_folder = '/data/vnet/baseline/vpdet_tmm17/neurvps/neurvps_mat';
gt_folder     = '/data/vnet/baseline/vpdet_tmm17/neurvps/gt';

%% do the job
D = dir([imgFolder '/*.jpg']);
n = length(D);

acc = zeros(1,n);
for imgIdx = 1:n
    imgname = D(imgIdx).name;
    I = imread(fullfile(imgFolder, imgname));
    
    ARGS.imgW =size(I,2);
    ARGS.imgH =size(I,1);
    ARGS.imgS = max(size(I));
    
    % get the detection result
    filename = fullfile(result_folder, [imgname(1:end-4) '.mat']);
    if ~exist(filename,'file')
        acc(imgIdx) = inf;
        continue;
    end
    load(filename);
    
    % load and process ground truth files
    
    lines = { zeros(4), zeros(4) };
    gtName = fullfile(gt_folder,[imgname(1:end-4) '.txt']);
    %load(gtName);
    fileID = fopen(gtName,'r');
    A = fscanf(fileID, '%f');
    lines = { A(3:6), A(7:10) };
    fclose(fileID);
    
    % compute accuracy
    if ~isempty(vp_detected)
        % build edges
        ne = 2;
        edgelist = cell(1,ne);
        for k = 1:ne
            x1 = lines{k}(1);
            y1 = lines{k}(2);
            x2 = lines{k}(3);
            y2 = lines{k}(4);
            
            vnk = ceil(sqrt((x1-x2)^2+(y1-y2)^2));
            edgelist{k} = [linspace(x1,x2,vnk); linspace(y1,y2,vnk)];
        end
        vsEdges = build_vsEdges(edgelist, ARGS, false);
        
        % process the VP
        imW = ARGS.imgW;
        imH = ARGS.imgH;
        vsVP_VP = [vp_detected(1)/ARGS.imgS;-vp_detected(2)/ARGS.imgS;1];
        
        % error
        vErr = mxDistCtrToVP_RMS(vsEdges, vsVP_VP) * ARGS.imgS;
        acc(imgIdx) = mean(vErr);
    else
        acc(imgIdx) = inf;
    end
end

%% compute the statistics
x = linspace(0, 10, 30);
rate = zeros(1,30);
for k = 1:30
    rate(k) = sum(acc <= x(k));
end
figure(6);
plot(x, rate / n, 'LineWidth',2);
grid on;
hold on;

%% zihan's parameters
imgFolder     = '/data/vnet/baseline/vpdet_tmm17/neurvps/image';
result_folder = '/data/vnet/baseline/vpdet_tmm17/neurvps/tmm17';
gt_folder     = '/data/vnet/baseline/vpdet_tmm17/neurvps/gt';

%% do the job
D = dir([imgFolder '/*.jpg']);
n = length(D);

acc = zeros(1,n);
for imgIdx = 1:n
    imgname = D(imgIdx).name;
    I = imread(fullfile(imgFolder, imgname));
    
    ARGS.imgW =size(I,2);
    ARGS.imgH =size(I,1);
    ARGS.imgS = max(size(I));
    
    % get the detection result
    filename = fullfile(result_folder, [imgname(1:end-4) '.mat']);
    if ~exist(filename,'file')
        acc(imgIdx) = inf;
        continue;
    end
    load(filename);
    
    % load and process ground truth files
    
    lines = { zeros(4), zeros(4) };
    gtName = fullfile(gt_folder,[imgname(1:end-4) '.txt']);
    %load(gtName);
    fileID = fopen(gtName,'r');10
    A = fscanf(fileID, '%f');
    lines = { A(3:6), A(7:10) };
    fclose(fileID);
    
    % compute accuracy
    if ~isempty(vp_detected)
        % build edges
        ne = 2;
        edgelist = cell(1,ne);
        for k = 1:ne
            x1 = lines{k}(1);
            y1 = lines{k}(2);
            x2 = lines{k}(3);
            y2 = lines{k}(4);
            
            vnk = ceil(sqrt((x1-x2)^2+(y1-y2)^2));
            edgelist{k} = [linspace(x1,x2,vnk); linspace(y1,y2,vnk)];
        end
        vsEdges = build_vsEdges(edgelist, ARGS, false);
        
        % process the VP
        imW = ARGS.imgW;
        imH = ARGS.imgH;
        vsVP_VP = [vp_detected(1)/ARGS.imgS;-vp_detected(2)/ARGS.imgS;1];
        
        % error
        vErr = mxDistCtrToVP_RMS(vsEdges, vsVP_VP) * ARGS.imgS;
        acc(imgIdx) = mean(vErr);
    else
        acc(imgIdx) = inf;
    end
end

%% compute the statistics
x = linspace(0, 10, 30);
rate = zeros(1,30);
for k = 1:30
    rate(k) = sum(acc <= x(k));
end
figure(6);
plot(x, rate / n, 'LineWidth',2);
set(gca,'XTick',0:1:10,'YTick',0.0:0.1:1.0,'fontsize',18,'FontName','Times New Roman');
legend("Conic x 4", "vpdet [50]");
grid on;
saveas(gcf,'result.pdf')

