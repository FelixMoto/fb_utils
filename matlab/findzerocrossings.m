function v = findzerocrossings(x)
%
% v = findzerocrossings(x)
%
% returns indices of zero crossings in vector x
%

v = find(diff(sign(x)));

end

