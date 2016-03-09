
data_root = 'input/hmdb51';
use_gpu = 1;
dispstat('','init');

if exist('+caffe', 'dir')
  %addpath('+caffe');
else
  error('Please run this from caffe root');
end

% Set caffe mode
if exist('use_gpu', 'var') && use_gpu
  caffe.set_mode_gpu();
  gpu_id = 0;  % we will use the first gpu in this demo
  caffe.set_device(gpu_id);
else
  caffe.set_mode_cpu();
end

% Initialize the network using BVLC CaffeNet for image classification
% Weights (parameter) file needs to be downloaded from Model Zoo.
model_dir = '../models/bvlc_alexnet/';
net_model = [model_dir 'deploy_fc7.prototxt'];
net_weights = [model_dir 'bvlc_alexnet.caffemodel'];
phase = 'test'; % run with phase test (so that dropout isn't applied)
if ~exist(net_weights, 'file')
  error('Please download AlexNet from Model Zoo before you run this demo');
end

% Initialize a network
net = caffe.Net(net_model, net_weights, phase);

main_root_path = 'input/temp/';
catsContents=dir(main_root_path);

for cat_idx=1:numel(catsContents) 
    if(~(strcmpi(catsContents(cat_idx).name,'.') || strcmpi(catsContents(cat_idx).name,'..'))) 
        if(catsContents(cat_idx).isdir)
        cat_root_path = [main_root_path catsContents(cat_idx).name];
            DirContents=dir(cat_root_path); 
            all_feats = cell(numel(DirContents) -2, 1);
            FList=cell(numel(DirContents) -2, 1);
            video_index = 1;
            for dir_idx=1:numel(DirContents) 
                if(~(strcmpi(DirContents(dir_idx).name,'.') || strcmpi(DirContents(dir_idx).name,'..') || strcmpi(DirContents(dir_idx).name,'Thumbs.db:encryptable') || strcmpi(DirContents(dir_idx).name,'Thumbs.db') )) 
                    if(DirContents(dir_idx).isdir) 
                        root_path = DirContents(dir_idx).name;
                        FList{video_index} = root_path; 
                        fs_index =  get_file_names([cat_root_path '/' root_path]);
                        %fs = textread([root_path 'all_imgs.txt'], '%s');
                        N = length(fs_index)-1;
                        % mean BGR pixel
                        %mean_pix = [103.939, 116.779, 123.68];
                        feats = zeros(4096, N, 'single');
                        tic;
                        for i=1:N
                            % enter images, and dont go out of bounds
                            im = imread([cat_root_path '/' root_path '/' int2str(i) '.jpg']);
                            % prepare oversampled input
                            % input_data is Height x Width x Channel x Num
                            input_data = {prepare_image(im)};
                            
                            feat = net.forward(input_data);
                            feat = reshape(feat{1}, [4096 10]);
                            feat = mean(feat, 2);
                            
                            feats(:, i) = feat(:,1);
                            dispstat(sprintf('%d/%d frames done ', i, N));
                            % call caffe.reset_all() to reset caffe
                            %caffe.reset_all();
                        end
                        %matlabpool('close');
                        all_feats{video_index}= feats;
                        tt = toc;
                        dispstat(sprintf('%d/%d videos done in %.2fs', video_index, numel(DirContents)-2, tt),'keepthis');
                        video_index = video_index +1;
                    end 
                end
            end 
            save([main_root_path '/feats_' catsContents(cat_idx).name '.mat'  ], 'FList', 'all_feats', '-v7.3');
            dispstat(sprintf('-----category %s done-----\n', catsContents(cat_idx).name ), 'keepthis');
        end
    end
end


% im = imread('../examples/images/cat.jpg');
% % prepare oversampled input
% % input_data is Height x Width x Channel x Num
% tic;
% input_data = {prepare_image(im)};
% toc;
% 
% % do forward pass to get scores
% % scores are now Channels x Num, where Channels == 1000
% tic;
% % The net forward function. It takes in a cell array of N-D arrays
% % (where N == 4 here) containing data of input blob(s) and outputs a cell
% % array containing data from output blob(s)
% feats = net.forward(input_data);
% toc;
% 
% feats = feats{1};
% feats = mean(feats, 2);
% 
% % call caffe.reset_all() to reset caffe
% caffe.reset_all();
