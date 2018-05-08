% get the time the mtt analysis took
clear
mtt_out = dir('mttout/*.out');
g = fopen('runtime_mtt.csv','w');
for i = 1 : length(mtt_out)
    % check if the log files exists
    log_fname = strrep(mtt_out(i).name, '.out','.log');
    if exist(['mttout/' log_fname])
        f = fopen(['mttout/' mtt_out(i).name]);
        while ~feof(f)
            line = fgets(f);
            if ~isempty(strfind(line, 'CPU time'))
                tmp = strsplit(line);
                fprintf(g, '%s,%s\n', log_fname, tmp{end-2});
                break;
            elseif ~isempty(strfind(line, 'job killed after reaching LSF memory usage limit'))
            end
        end
        fclose(f);
    end
end
fclose(g);


% get the time the mascot analysis took
clear
mascot_out = dir('out/*.out');
g = fopen('runtime_mascot.csv','w');
for i = 1 : length(mascot_out)
    % check if the log files exists
    log_fname = strrep(mascot_out(i).name, '.out','.log');
    if exist(['out/' log_fname])
        f = fopen(['out/' mascot_out(i).name]);
        while ~feof(f)
            line = fgets(f);
            if ~isempty(strfind(line, 'CPU time'))
                tmp = strsplit(line);
                fprintf(g, '%s,%s\n', log_fname, tmp{end-2});
                break;
            elseif ~isempty(strfind(line, 'job killed after reaching LSF memory usage limit'))
            end
        end
        fclose(f);
    end
end
fclose(g);