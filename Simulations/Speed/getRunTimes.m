%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% get all the out files
out = dir('out/*.out');

for i = 1 : length(out)
    f = fopen(['out/' out(i).name]);
    while ~feof(f)
        line = strsplit(strtrim(fgets(f)));
        if length(line)==5
            CPUruntime = str2double(line{4});
            break;
        end
    end
    fclose(f);
    tmp = strsplit(out(i).name, '_');
    CPUtime(i) = CPUruntime;
    States(i) = str2double(tmp{2});
    Lineages(i) = str2double(tmp{3});
end
uni_states = unique(States);
uni_lineages = unique(Lineages);

g = fopen('CPUtimes.txt', 'w');
fprintf(g, 'median\tstates\tlineages\n');
for a = 1 : length(uni_lineages)
    for b = 1 : length(uni_states)
        indices = intersect(find(States==uni_states(b)),find(Lineages==uni_lineages(a)));
        all_indices = intersect(indices, find(~isnan(CPUtime)));
        CPUmedian = median(CPUtime(all_indices));
        fprintf(g, '%.2f\t%d\t%d\n', CPUmedian, uni_states(b), uni_lineages(a));
    end
end
fclose(g);