%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
function [ FList ] = get_file_names(root_folder_name) 
% Author: Thokare Nitin D. 
% 
% This function reads all file names contained in Datafolder and it's subfolders 
% with extension given in extList variable in this code... 
% Note: Keep each extension in extension list with length 3 
% i.e. last 3 characters of the filename with extension 
% if extension is 2 character length (e.g. MA for mathematica ascii file), use '.' 
% (i.e. '.MA' for given example) 
% Example: 
% extList={'jpg','peg','bmp','tif','iff','png','gif','ppm','pgm','pbm','pmn','xcf'}; 
% Gives the list of all image files in DataFolder and it's subfolder 
% 
if nargin < 1 
    root_folder_name = uigetdir; 
end

DirContents=dir(root_folder_name); 
FList=[];

if (~isunix) 
    NameSeperator='\'; 
else
    NameSeperator='/'; 
end

extList={'jpg'};
%extList={'jpg','peg','bmp','tif','iff','png','gif','ppm','pgm','pbm','pmn','xcf', 'nef', 'NEF'};
% Here 'peg' is written for .jpeg and 'iff' is written for .tiff 
for i=1:numel(DirContents) 
    if(~(strcmpi(DirContents(i).name,'.') || strcmpi(DirContents(i).name,'..'))) 
        if(~DirContents(i).isdir) 
            extension=DirContents(i).name(end-2:end); 
            if(numel(find(strcmpi(extension,extList)))~=0) 
                FList=cat(1,FList,{[root_folder_name NameSeperator DirContents(i).name]}); 
            end 
        else 
            getlist=get_file_names([root_folder_name NameSeperator DirContents(i).name]); 
            FList=cat(1,FList,getlist); 
        end 
    end 
end

end 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%