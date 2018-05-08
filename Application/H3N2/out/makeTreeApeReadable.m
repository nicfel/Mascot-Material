% converts the mcc.trees to ape readable
clear
input_tree = dir('*mcc*');
    g = fopen('ape.trees','w');

for it = 1 : length(input_tree)
    f = fopen(input_tree(it).name);
    locations = {'Australia','Hong_Kong','Japan','New_Zealand','New_York'};
    while ~feof(f)
        line = fgets(f);    
        if ~isempty(strfind(line,'TREE'))        
            tmp = strsplit(strtrim(line));
            tmp = tmp{end};        
            tmp = strrep(tmp,'%','');
            nodes_tmp = regexp(tmp, '\[\&(.*?)\]', 'match');
            nr_nodes = (length(nodes_tmp)-1)/2;
            tmp = sprintf(strrep(tmp,')',')n%d'),[1:nr_nodes]);
            disp(tmp)
            for i = 1 : length(nodes_tmp)
                p = regexp(nodes_tmp{i}, 'Australia=(.*?)\,','tokens');
                prob(1) = str2double(p{1});
                p = regexp(nodes_tmp{i}, 'Hong_Kong=(.*?)\,','tokens');
                prob(2) = str2double(p{1});
                p = regexp(nodes_tmp{i}, 'Japan=(.*?)\,','tokens');
                prob(3) = str2double(p{1});
                p = regexp(nodes_tmp{i}, 'New_Zealand=(.*?)\,','tokens');
                prob(4) = str2double(p{1});
                p = regexp(nodes_tmp{i}, 'USA=(.*?)\,','tokens');
                prob(5) = str2double(p{1});
                
                                                
                [~, ind_max] = max(prob);
                tmp = strrep(tmp, nodes_tmp{i},...
                    sprintf('_%s',...
                    [sprintf('%.3f_',prob(1:end-1)) sprintf('%.3f',prob(end))]));            
            end
            tree{it,1} = tmp;
            fprintf(g, '%s\n', tmp);                        
        end
    end
    fclose(f);

end
fclose(g);

%%
length(strfind(tmp,'('))
