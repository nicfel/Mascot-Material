clear

tree_files = dir('trees/*.trees');

parfor i = 1420 : length(tree_files)
    disp(i)
%     if ~exist(['trees2/' tree_files(i).name])
        f = fopen(['trees/' tree_files(i).name]);
        g = fopen(['trees2/' tree_files(i).name], 'w');
        while ~feof(f)
            line = regexprep(fgets(f), '(\d)=','state$1=');        
            fprintf(g, '%s', regexprep(line, 'max=(\d)','max=state$1'));
        end
        fclose(f);fclose(g);
%     else
%         disp(['trees2/' tree_files(i).name])
%     end
end