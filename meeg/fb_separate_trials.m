function cell_data = fb_separate_trials(data, index, dim)
% function to separate trials from a 2D matrix into a cell array
%
% Parameters
% ----------
%       data : matrix 
%           data that should be separated into cell array
%       index : 1xN array 
%           indexing the last sample of each trial in data
%       dim : souble (optional)
%           dimension in which data is cut if not given, assumes dim == 2
%
% Returns
% -------
%       cell_data : cell array 
%           separated data 
%


% if nargin == 3
%     if dim == 2
%         data = data';
%     end
% end

ntrl = length(index);
new_trials = cell(1,ntrl);

for trl = 1:ntrl
    if trl < 2
        new_trials{trl} = data(:,1:index(1));
    else
        new_trials{trl} = data(:,index(trl-1):index(trl)-1);
    end
end

cell_data = new_trials;

end
