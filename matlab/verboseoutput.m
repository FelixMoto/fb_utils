function v = verboseoutput(v,i,j)
% v = verbosemode(i,j)
% outputs command line message with how many of all files are already
% computed
%
% ----
% needs to be updated for more general purposes

if isempty(v)
    v.msg = ['%d/%d files'];
    v.count = 0;
    i = 0;
end

if i == 0
    fprintf('Segmenting Speech files: \n');
elseif i <= j
    fprintf(repmat('\b',1,v.count)); % \b is one backspace
    v.count = fprintf(v.msg,i,j);
end

if i == j
    fprintf('\n');
end

end
