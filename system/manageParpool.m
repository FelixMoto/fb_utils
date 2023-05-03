function out = manageParpool(varargin)
% function to manage parpools 
% checks whether parpool already exists
% if input is given, creates parpool with desired number of cores
%
% input varargin: scalar with number of cores

% check input
if length(varargin) > 1
    fprintf('too many input arguments \n');
elseif length(varargin) == 1
    if varargin{1} > 0
        numcore = varargin{1};
    elseif varargin{1} < 0
        ncoresmax = feature('numcores');
        numcore = ncoresmax + varargin{1};
    elseif varargin{1} == 0
        fprintf('creating no parpool... \n');
        return
    end
end

% get current parpool
pool = gcp('nocreate');

% create parpool if desired
if isempty(pool) && length(varargin) == 1
    poolobj = parpool(numcore);
    
elseif isempty(pool)
    fprintf('no parpool available \n');
    
elseif ~isempty(pool)
    poolobj = gcp('nocreate');
    
    if poolobj.NumWorkers == numcore
        fprintf('pool already available \n');
    else
        delete(pool)
        poolobj = parpool(numcore);
    end
end

out = poolobj;

end
