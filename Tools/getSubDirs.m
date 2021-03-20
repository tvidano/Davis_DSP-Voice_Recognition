function [subDirs] = getSubDirs(files)
%GETSUBDIRS Returns the subdirectories in the vec of file structures.
% 
% Inputs        files       a long structure with 6 fields, including name
%
% Outputs       subDirs     a long structure containing only
%                           subdirectories

% Remove non-directory files
dirFlag = [files.isdir];
subDirs = files(dirFlag);
numDirs = length(subDirs);
% Remove '.' and '..' directories
isSubDir = zeros(numDirs,1);
for i = 1:numDirs
    fileName = files(i).name;
    if fileName ~= "." && fileName ~= ".."
        isSubDir(i) = 1;
    end
end
isSubDir = logical(isSubDir);
subDirs = subDirs(isSubDir);
end

