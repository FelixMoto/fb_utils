function B = fb_circshift(A,shift)
%
% slower than built in function.
%

% handle input
if ~ismatrix(A)
    error('input must be 2D');
end

Npoints = length(A);

if Npoints ~= shift
    B = A([[shift:Npoints],[1:shift-1]],:);
else
    B = A;
end

end
