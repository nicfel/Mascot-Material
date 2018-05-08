%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% creates structured coalescent xmls from the master trees. Always creates
% 3 xmls per tree with different initial values
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
% create lisco files
tree_files = dir('master/*.tree');

system('rm -r mtt');
system('mkdir mtt');

for i = 1 : length(tree_files)
    
    %get the number of states
    tmp = strsplit(tree_files(i).name,'_');
    states = str2double(tmp{2});
    lins = str2double(tmp{3});

    use = true;
    if states > 6 || lins > 400
        use = false;
    end

    disp(i)
    if use
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
            flog = strrep(tree_files(i).name,'master.tree',sprintf('%dmtt',tr));
            fname = sprintf('mtt/%s.xml',flog);


            f = fopen(fname,'w');

            fprintf(g,'<beast version=''2.0'' namespace=''beast.evolution.alignment:beast.core:beast.core.parameter:beast.evolution.tree:beast.evolution.tree.coalescent:beast.core.util:beast.evolution.operators:beast.evolution.sitemodel:beast.evolution.substitutionmodel:beast.evolution.likelihood:beast.evolution.migrationmodel:beast.math.distributions:multitypetree.distributions:multitypetree.operators:multitypetree.util''>\n');    
            fprintf(g,'<alignment spec="beast.evolution.alignment.Alignment" id="alignment" dataType="nucleotide">\n');

            for j = 1 : length(leafnames)
                fprintf(g,'\t\t<sequence id="%s" taxon="%s" totalcount="4" value="??"/>\n',leafnames{j},leafnames{j});
            end
            fprintf(g,'\t</alignment>\n');


            fprintf(g,'<typeTraitSet spec=''TraitSet'' id=''typeTraitSet'' traitname="type" value="\n');
            for j = 1 : length(leafnames)-1
                tmp1 = strsplit(leafnames{j},'_');
                fprintf(g,'%s=state%s,',leafnames{j},tmp1{end});
            end
            tmp1 = strsplit(leafnames{end},'_');
            fprintf(g,'%s=state%s">\n',leafnames{end},tmp1{end});
            fprintf(g,'<taxa spec=''TaxonSet'' alignment=''@alignment''/>\n');
            fprintf(g,'</typeTraitSet>\n');

            fprintf(g,'<migrationModel spec=''SCMigrationModel'' id=''migModel''>\n');
            fprintf(g,'<rateMatrix spec=''RealParameter'' value="1.0" dimension="%d" id="rateMatrix"/>\n', states*(states-1));
            fprintf(g,'<popSizes spec=''RealParameter'' value="1.0" dimension="%d" id="popSizes"/>\n', states);
            fprintf(g,'</migrationModel>\n');

            fprintf(g,'<!-- Parameter priors -->\n');
            fprintf(g,'<input spec=''CompoundDistribution'' id=''parameterPriors''>\n');       
            fprintf(g,'<distribution spec=''beast.math.distributions.Prior'' x="@rateMatrix">\n');
            fprintf(g,'<distr spec=''Exponential'' mean="1"/>\n');
            fprintf(g,'</distribution>\n');
            fprintf(g,'<distribution spec=''beast.math.distributions.Prior'' x="@popSizes">\n');
            fprintf(g,'<distr spec="OneOnX"/>\n');
            fprintf(g,'</distribution>\n');
            fprintf(g,'</input>\n');



            fprintf(g,'<input spec=''StructuredCoalescentTreeDensity'' id=''treePrior''>\n');
            fprintf(g,'<multiTypeTree idref="tree"/>\n');
            fprintf(g,'<migrationModel idref="migModel"/>\n');
            fprintf(g,'</input>\n');


            fprintf(g,'<run spec="MCMC" id="mcmc" chainLength="10000000" storeEvery="10000">\n');


            fprintf(g,'<state>\n');
            fprintf(g,'<stateNode id="tree" spec="beast.evolution.tree.MultiTypeTreeFromUntypedNewick">\n%s\n',print_tree);
            fprintf(g,'\t<migrationModel spec=''SCMigrationModel''>\n');
            fprintf(g,'\t<rateMatrix spec=''RealParameter'' value="1.0" dimension="%d"/>\n',states*(states-1));
            fprintf(g,'\t<popSizes spec=''RealParameter'' value="1.0" dimension="%d"/>\n',states);
    %         fprintf(g,'\t<typeSet idref="typeSet"/>\n');
            fprintf(g,'</migrationModel>\n');
            fprintf(g,'<typeTrait idref="typeTraitSet"/>\n');
            fprintf(g,'</stateNode>\n');
            fprintf(g,'<stateNode idref="rateMatrix"/>\n');
            fprintf(g,'<stateNode idref="popSizes"/>\n');
            fprintf(g,'</state>\n');




            fprintf(g,'<distribution spec=''CompoundDistribution'' id=''posterior''>\n');
            fprintf(g,'<distribution idref=''treePrior''/>\n');
            fprintf(g,'<distribution idref="parameterPriors"/>\n');
            fprintf(g,'</distribution>\n');

            fprintf(g,'<operator spec=''ScaleOperator'' id=''RateScaler''\n');
            fprintf(g,'parameter="@rateMatrix"\n');
            fprintf(g,'scaleFactor="0.8" weight="1">\n');
            fprintf(g,' </operator>\n');

            fprintf(g,'<operator spec="ScaleOperator" id="PopSizeScaler"\n');
            fprintf(g,'parameter="@popSizes"\n');
            fprintf(g,'scaleFactor="0.8" weight="1"/>\n');

            fprintf(g,'<operator spec="NodeRetype" id="NR"\n');
            fprintf(g,'weight="10" multiTypeTree="@tree"\n');
            fprintf(g,'migrationModel="@migModel"/>\n');

            fprintf(g,'<logger logEvery="1000" fileName="$(filebase).log">\n');
            fprintf(g,'<model idref=''posterior''/>\n');
            fprintf(g,'<log idref="posterior"/>\n');
            fprintf(g,'<log idref="treePrior"/>\n');
            fprintf(g,'<log id="migModelLogger" spec="MigrationModelLogger" migrationModel="@migModel" multiTypeTree="@tree"/>\n');
    %         fprintf(g,'<log spec=''Sum'' arg="@typeChangeCounts" id="totalTypeChanges" />\n');
    %         fprintf(g,'<log spec=''NodeTypeCounts'' multiTypeTree="@tree"\n');
    %         fprintf(g,'migrationModel="@migModel" />\n');
            fprintf(g,'<log spec=''TreeRootTypeLogger'' multiTypeTree="@tree"/>\n');
            fprintf(g,'</logger>\n');

            fprintf(g,'<logger logEvery="10000" fileName="$(filebase).trees" mode="tree">\n');
            fprintf(g,'<log idref="tree"/>\n');
            fprintf(g,'</logger>\n');


            fprintf(g,'<logger logEvery="100000" fileName="$(filebase).typedNode.trees" mode="tree">\n');
            fprintf(g,'<log spec=''TypedNodeTreeLogger'' multiTypeTree="@tree"/>\n');
            fprintf(g,'</logger>\n');

            fprintf(g,'<logger logEvery="10000">\n');
            fprintf(g,'<model idref=''posterior''/>\n');
            fprintf(g,'<log idref="posterior"/>\n');
    %         fprintf(g,'<log idref="treeLikelihood"/>\n');
            fprintf(g,'<log idref="treePrior"/>\n');
    %         fprintf(g,'<log idref="totalTypeChanges"/>\n');
    %         fprintf(g,'<ESS spec=''ESS'' name=''log'' arg="@treePrior"/>\n');
            fprintf(g,'</logger>\n');
            fprintf(g,'</run>\n');

            fprintf(g,'</beast>\n');






            fclose(f);
        end
    end
end
