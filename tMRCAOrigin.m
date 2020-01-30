clear;
f = fopen('master/I_only.nexus');
height_difference = [];
while ~feof(f)
    line = fgets(f);
    if contains(line, 'tree TREE')
        clear times
        times_str = regexp(line, 'time=(\d*).(\d*)','match');
        for j = 1 :length(times_str)
            times(j) = str2double(strrep(times_str{j},'time=','')) ;
        end
        height_difference(end+1,1) = min(times);
    end
end

histogram(height_difference*365); hold on


f = fopen('master/I_superspreader.nexus');
height_difference = [];
while ~feof(f)
    line = fgets(f);
    if contains(line, 'tree TREE')
        clear times
        times_str = regexp(line, 'time=(\d*).(\d*)','match');
        for j = 1 :length(times_str)
            times(j) = str2double(strrep(times_str{j},'time=','')) ;
        end
        height_difference(end+1,1) = min(times);
    end
end

histogram(height_difference*365)
legend('w/o superspreaders', 'with superspreaders')
