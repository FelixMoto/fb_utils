function bar = bar3_color(bar_object)

for i = 1:length(bar_object)
    zdata = get(bar_object(i), 'Zdata');
    set(bar_object(i), 'Cdata', zdata);
end

bar = bar_object;
