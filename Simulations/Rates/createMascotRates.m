%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% creates structured coalescent xmls from the master trees. Always creates
% 3 xmls per tree with different initial values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
% create lisco files
tree_files = dir('master/*.tree');

system('rm -r xmls');
system('mkdir xmls');

for i = 1 : length(tree_files)
    disp(i)
    % read tree files
    g = fopen(['master/' tree_files(i).name],'r');
    t = textscan(g,'%s'); fclose(g);
    
   % coalescing
    tree_tmp2 = regexprep(t{1}(end-1),'&type="L",location="(\d)",reaction="Coalescence",time=(\d*).(\d*)','');

    %migrating
    tree_tmp1 = regexprep(tree_tmp2,'&type="L",location="(\d)",reaction="Migration",time=(\d*).(\d*)','');

    
    % make the MASTER tree compatible with BEAST2
    % sampling
    tree_tmp1 = regexprep(tree_tmp1,'E[-](\d)]',']');
    tip_locs = regexp(tree_tmp1,'[&type="L",location="(\d)",time=(\d*)\.(\d*)\]','match');
     
    for j = 1 : length(tip_locs{1})
        tree_tmp1 = strrep(tree_tmp1,tip_locs{1}{j},['loc_' tip_locs{1,1}{j}(22) 'kickout']);
        tree_tmp1 = strrep(tree_tmp1,'kickout','');
    end

    tree_tmp = regexprep(tree_tmp1,'(\d*)loc_','inv$1loc_');
    
    tree = strrep(tree_tmp{1},'[]','');
    if ~isempty(strfind(tree,']'))
        b = strfind(tree,']');
        c = tree((b-50):(b+50));
        disp(tree_files(i).name)
    end

    % get the leafnames
    ptree = phytreeread(tree);
    leafnames = get(ptree,'leafnames');
    
    print_tree = tree;
    
    % make tripletts of all runs with different random initial values
    for tr = 1 : 1    
        % make the xmls for the structcoal
        flog = strrep(tree_files(i).name,'master.tree',sprintf('%dmascot',tr));
        fname = sprintf('xmls/%s.xml',flog);
        f = fopen(fname,'w');


        fprintf(g,'<?xml version="1.0" encoding="UTF-8" standalone="no"?><beast beautitemplate=''Standard'' beautistatus='''' namespace="beast.core:beast.evolution.alignment:beast.evolution.tree.coalescent:beast.core.util:beast.evolution.nuc:beast.evolution.operators:beast.evolution.sitemodel:beast.evolution.substitutionmodel:beast.evolution.likelihood:beast.mascot.dynamics:beast.mascot.distribution:beast.mascot.logger" version="2.0">\n');

        fprintf(g,'\t<data id="sequences" name="alignment">\n');
        for j = 1 : length(leafnames)
            fprintf(g,'\t\t<sequence id="%s" taxon="%s" totalcount="4" value="??"/>\n',leafnames{j},leafnames{j});
        end
        fprintf(g,'\t</data>\n');

        fprintf(g,'\t<run id="mcmc" spec="MCMC" chainLength="500000">\n');
        fprintf(g,'\t\t<state id="state" storeEvery="5000">\n');
        fprintf(g,'\t\t\t<stateNode id="tree" spec="beast.app.mascot.beauti.TreeWithTrait">\n');
        fprintf(g,'\t\t\t\t<typeTrait id="typeTraitSet.t" spec="beast.evolution.tree.TraitSet" traitname="type" value="');
        for j = 1 : length(leafnames)-1
            tmp1 = strsplit(leafnames{j},'_');
            fprintf(g,'%s=state%s,',leafnames{j},tmp1{end});
        end
        tmp1 = strsplit(leafnames{end},'_');
        fprintf(g,'%s=state%s">\n',leafnames{end},tmp1{end});

        fprintf(g,'\t\t\t\t\t<taxa id="TaxonSet.0" spec="TaxonSet">\n');
        fprintf(g,'\t\t\t\t\t\t<alignment idref="sequences"/>\n');
        fprintf(g,'\t\t\t\t\t</taxa>\n');
        fprintf(g,'\t\t\t\t</typeTrait>\n');
        fprintf(g,'\t\t\t</stateNode>\n');        
        fprintf(g,'\t\t\t<parameter id="Ne" name="stateNode" dimension="6">1</parameter>\n');
        fprintf(g,'\t\t\t<parameter id="m" name="stateNode" dimension="30">1</parameter>\n');
        fprintf(g,'\t\t</state>\n');
        fprintf(g,'\t\t<init spec="beast.util.TreeParser" id="NewickTree.t:Species" adjustTipHeights="false"\n');
        fprintf(g,'\t\t\tinitial="@tree" taxa="@sequences"\n');
        fprintf(g,'\t\t\tIsLabelledNewick="true"\n');
        fprintf(g,'\t\t\tnewick="%s"/>\n',print_tree);
        fprintf(g,' \t\t<distribution id="posterior" spec="util.CompoundDistribution">\n');
        fprintf(g,'\t\t\t<distribution id="prior" spec="util.CompoundDistribution">\n');
        fprintf(g,'\t\t\t\t<distribution spec=''beast.math.distributions.Prior'' x="@Ne">\n');
        fprintf(g,'\t\t\t\t\t<distr spec="beast.math.distributions.OneOnX"/>\n');
        fprintf(g,'\t\t\t\t</distribution>\n');
        fprintf(g,'\t\t\t\t<distribution spec=''beast.math.distributions.Prior'' x="@m">\n');
        fprintf(g,'\t\t\t\t\t<distr spec="beast.math.distributions.Exponential"  mean="1"/>\n');
        fprintf(g,'\t\t\t\t</distribution>\n');
        fprintf(g,'\t\t\t</distribution>\n');
        fprintf(g,'\t\t\t<distribution id="likelihood" spec="util.CompoundDistribution">\n');
        fprintf(g,'\t\t\t\t<distribution id="coalescent" spec="Mascot">\n');
        fprintf(g,'\t\t\t\t\t<structuredTreeIntervals spec="StructuredTreeIntervals" id="TreeIntervals" tree="@tree"/>\n');
        fprintf(g,'\t\t\t\t\t<dynamics spec="Constant" id="constant" typeTrait="@typeTraitSet.t">\n');
        fprintf(g,'\t\t\t\t\t\t<Ne idref="Ne"/>\n');
        fprintf(g,'\t\t\t\t\t\t<backwardsMigration idref="m"/>\n');
        fprintf(g,'\t\t\t\t\t</dynamics>\n');
        fprintf(g,'\t\t\t\t</distribution>\n');
        fprintf(g,'\t\t\t</distribution>\n');
        fprintf(g,'\t\t</distribution>\n');
        fprintf(g,'\t\t<operator id="NeScaler" spec="ScaleOperator" scaleFactor="0.8" optimise="true" parameter="@Ne" scaleAll="true" scaleAllIndependently="true" weight="1.0"/>\n');   
        fprintf(g,'\t\t<operator id="MigrationScaler" spec="ScaleOperator" scaleFactor="0.8" optimise="true" parameter="@m" scaleAll="true" scaleAllIndependently="true" weight="1.0"/>\n');   
        fprintf(g,'\t\t<logger id="probtreelognud" fileName="%s.nud.trees" logEvery="5000" mode="tree">\n',flog);
        fprintf(g,'\t\t\t<log id="logTreesnud" spec="StructuredTreeLogger" upDown="false" mascot="@coalescent"/>\n');
        fprintf(g,'\t\t</logger>\n');
        fprintf(g,'\t\t<logger id="probtreelog" fileName="%s.trees" logEvery="5000" mode="tree">\n',flog);
        fprintf(g,'\t\t\t<log id="logTrees" spec="StructuredTreeLogger" mascot="@coalescent"/>\n');
        fprintf(g,'\t\t</logger>\n');

        fprintf(g,'\t\t<logger id="tracelog" fileName="%s.log" logEvery="200" model="@posterior" sanitiseHeaders="true" sort="smart">\n',flog);
        fprintf(g,'\t\t\t<log idref="m"/>\n');
        fprintf(g,'\t\t\t<log idref="Ne"/>\n');
        fprintf(g,'\t\t\t<log idref="posterior"/>\n');
        fprintf(g,'\t\t\t<log idref="prior"/>\n');
        fprintf(g,'\t\t\t<log spec="RootStateLogger" id="RootStateLogger" mascot="@coalescent"/>\n');
        fprintf(g,'\t\t</logger>\n');
        fprintf(g,'\t\t<logger id="screenlog" logEvery="1000">\n');
        fprintf(g,'\t\t\t<log idref="posterior"/>\n');
        fprintf(g,'\t\t</logger>\n');
        fprintf(g,'\t</run>\n');
        fprintf(g,'</beast>\n');
        fclose(f);
    end
end
