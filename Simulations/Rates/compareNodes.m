%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% compares mcc and master trees for their node states
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear

% get the master tree files
mcc = dir('mcc/*nud.trees');

r = fopen('root_probs.txt','w');
g = fopen('node_probs.txt','w');


for i = 1 : length(mcc)
    disp(mcc(i).name)
    
    %% get the master tree string
    f = fopen(['master/' strrep(mcc(i).name,'1mascot.nud.trees', 'master.tree')]);
    line = fgets(f);
    while length(line)<100
        line = fgets(f);
    end
    tmp = strsplit(line);
    mt = tmp{4};clear tmp;fclose(f);
    
    %% get the up down tree string
    tmp_name = strrep(mcc(i).name, '.nud.trees', '.trees');
    f = fopen(['mcc/' tmp_name]);
    line = fgets(f);
    while length(line)<100
        line = fgets(f);
    end
    tmp = strsplit(line);
    ut = strrep(tmp{4},'%','');clear tmp;fclose(f);
    
    %% get the w/o up down tree string
    tmp_name = mcc(i).name;
    f = fopen(['mcc/' tmp_name]);
    line = fgets(f);
    while length(line)<100
        line = fgets(f);
    end
    tmp = strsplit(line);
    nt = strrep(tmp{4},'%','');clear tmp;fclose(f);
    
    %% make the tree strings matlab readable
    nr_nodes = length(strfind(mt,')'));
    mt = sprintf(strrep(mt,')',')node%d'),1:nr_nodes);
    nt = sprintf(strrep(nt,')',')node%d'),1:nr_nodes);
    ut = sprintf(strrep(ut,')',')node%d'),1:nr_nodes);
    
    mt = regexprep(mt, '\[\&type="L",location="', '_');
    mt = regexprep(mt, '",reaction="Coalescence",time=(\d*)\.(\d*)\]', '');
    mt = regexprep(mt, '",time=(\d*)\.(\d*)\]', '');
    mt = regexprep(mt, '",time=(\d*)\.(\d*)E-(\d*)\]', '');
    
    % leafs
    ut = regexprep(ut, '\&(.*?)max.set.prob','');
    ut = regexprep(ut, '\[=\{(.*?)\}','[');
    ut = regexprep(ut, 'posterior=(\d*)\.(\d*),','');
    ut = regexprep(ut, 'state(\d)_95_HPD=\{(\d*)\.(\d*),(\d*)\.(\d*)\},state(\d)_median=(\d*)\.(\d*),state(\d)_range=\{(\d*)\.(\d*),(\d*)\.(\d*)\},','');
    ut = regexprep(ut, 'state(\d)_95_HPD=\{(\d*)\.(\d*),(\d*)\.(\d*)\},state(\d)_median=(\d*)\.(\d*)E-(\d),state(\d)_range=\{(\d*)\.(\d*),(\d*)\.(\d*)\},','');
    ut = regexprep(ut, ',state(\d)_95_HPD=\{(\d*)\.(\d*),(\d*)\.(\d*)\},state(\d)_median=(\d*)\.(\d*),state(\d)_range=\{(\d*)\.(\d*),(\d*)\.(\d*)\}','');
    ut = regexprep(ut, ',state(\d)_95_HPD=\{(\d*)\.(\d*),(\d*)\.(\d*)\},state(\d)_median=(\d*)\.(\d*)E-(\d),state(\d)_range=\{(\d*)\.(\d*),(\d*)\.(\d*)\}','');
    ut = regexprep(ut, ',state(\d)=','_');
    ut = regexprep(ut, '\[','');
    ut = regexprep(ut, '\]','');

    
%     nt = regexprep(nt, '\[(.*?)\]','');
    
    nt = regexprep(nt, '\&(.*?)max.set.prob','');
    nt = regexprep(nt, '\[=\{(.*?)\}','[');
    nt = regexprep(nt, 'posterior=(\d*)\.(\d*),','');
    nt = regexprep(nt, 'state(\d)_95_HPD=\{(\d*)\.(\d*),(\d*)\.(\d*)\},state(\d)_median=(\d*)\.(\d*),state(\d)_range=\{(\d*)\.(\d*),(\d*)\.(\d*)\},','');
    nt = regexprep(nt, 'state(\d)_95_HPD=\{(\d*)\.(\d*),(\d*)\.(\d*)\},state(\d)_median=(\d*)\.(\d*)E-(\d),state(\d)_range=\{(\d*)\.(\d*),(\d*)\.(\d*)\},','');
    nt = regexprep(nt, ',state(\d)_95_HPD=\{(\d*)\.(\d*),(\d*)\.(\d*)\},state(\d)_median=(\d*)\.(\d*),state(\d)_range=\{(\d*)\.(\d*),(\d*)\.(\d*)\}','');
    nt = regexprep(nt, ',state(\d)_95_HPD=\{(\d*)\.(\d*),(\d*)\.(\d*)\},state(\d)_median=(\d*)\.(\d*)E-(\d),state(\d)_range=\{(\d*)\.(\d*),(\d*)\.(\d*)\}','');
    nt = regexprep(nt, ',state(\d)=','_');
    nt = regexprep(nt, '\[','');
    nt = regexprep(nt, '\]','');

    
    %% read the trees into matlab
    pt_mt = phytreeread(mt);
    pt_ut = phytreeread(ut);
    pt_nt = phytreeread(nt);
    
    [c_mt, nodes_mt, dist_mt] = getmatrix(pt_mt);
    [c_ut, nodes_ut, dist_ut] = getmatrix(pt_ut);
    [c_nt, nodes_nt, dist_nt] = getmatrix(pt_nt);
    
    node_heights_mt = ones(size(dist_mt))*100000000;
    node_heights_ut = ones(size(dist_ut))*100000000;
    node_heights_nt = ones(size(dist_nt))*100000000;
    
    node_heights_mt(end) = 0;
    node_heights_ut(end) = 0;
    node_heights_nt(end) = 0;
    
    for j = (length(node_heights_mt)-1) : -1 : (length(node_heights_mt)/2+1)
        node_heights_mt(j) = node_heights_mt(find(c_mt(:,j))) + dist_mt(j);        
        node_heights_ut(j) = node_heights_ut(find(c_ut(:,j))) + dist_ut(j);
        node_heights_nt(j) = node_heights_nt(find(c_nt(:,j))) + dist_nt(j);
    end
    
    [~,i_mt] = sort(node_heights_mt);
    [~,i_ut] = sort(node_heights_ut);
    [~,i_nt] = sort(node_heights_nt);
    
    ordered_names_mt = nodes_mt(i_mt(1:(length(node_heights_mt)/2)-0.5));
    ordered_names_ut = nodes_ut(i_ut(1:(length(node_heights_mt)/2)-0.5));
    ordered_names_nt = nodes_nt(i_nt(1:(length(node_heights_mt)/2)-0.5));
    
    % now check the performance
    for j = 1 : length(ordered_names_mt)
        tmp_1 = strsplit(ordered_names_mt{j},'_');
        index = str2double(tmp_1{2});
        tmp_2 = strsplit(ordered_names_ut{j},'_');
        tmp_3 = strsplit(ordered_names_nt{j},'_');
        if j==1
            fprintf(r, '%s\t%s\n', tmp_2{2+index},tmp_3{2+index});
        else
            fprintf(g, '%s\t%s\n', tmp_2{2+index},tmp_3{2+index});
        end
    end    
end
fclose(r);
fclose(g);



