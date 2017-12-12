%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% creates master files from the template with different asymmetric
% or migration rates.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
% open the template
f = fopen('Rates_master.xml','r');   

% cell to save the lines
temp_lines = cell(0,0);  

system('rm -r master');
system('mkdir master');


% while there are still lines
while ~feof(f) 
    % read line by line
    temp_lines{end+1,1} = fgets(f);   
end

% close the template xml    
fclose(f);  

rng(1)

%define the number of states
states_array = 2:2:10;

%define the number of lineages
lineages_array = 10:5:50;


%%


for nr_states = 1 : length(states_array)
    for nr_lineages = 1 : length(lineages_array)
        for S = 1 : 100
            states = states_array(nr_states);
            lineages = lineages_array(nr_lineages);
            filename = sprintf('Rates_%d_%d_%d_master',states, lineages*20, S);
            fname = sprintf('./master/%s.xml',filename);   % set the file name
            p = fopen(fname,'w');

            migration =  exprnd(0.5,states*(states-1),1);
            Ne = lognrnd(-0.125,0.5,states,1);
            
            ri = randi(states,lineages,1);
            for i = 1 : states
                sample_nr(i) =  sum(ri==i);
            end

            while min(sample_nr)==0
                ri = randi(states,lineages,1);
                for i = 1 : states
                    sample_nr(i) =  sum(ri==i);
                end
            end


            sample_nr = sample_nr*20;

            Ne_nr = 1;
            m_nr = 1;

            for l = 1 : length(temp_lines)
                if ~isempty(strfind(temp_lines{l},'insert_coalescent'));
                    for i = 1 : states
                        fprintf(p, '\t\t\t\t<reaction spec=''Reaction'' rate="%s">\n',num2str(1/(2*Ne(i))));
                        fprintf(p, '\t\t\t\t\t2L[%d]:1 -> L[%d]:1\n',i-1,i-1);
                        fprintf(p, '\t\t\t\t</reaction>\n');
                    end
                elseif  ~isempty(strfind(temp_lines{l},'insert_migration'));
                    counter = 1;
                    for a = 1 : states
                        for b = 1 : states
                            if a ~= b
                                fprintf(p, '\t\t\t\t<reaction spec=''Reaction'' rate="%s">\n',num2str(migration(counter)));
                                fprintf(p, '\t\t\t\t\tL[%d]:1 -> L[%d]:1\n',a-1,b-1);
                                fprintf(p, '\t\t\t\t</reaction>\n');
                                counter = counter + 1;
                            end
                        end
                    end
                elseif  ~isempty(strfind(temp_lines{l},'insert_samples')); 
                    for i = 1 : states
                        rest_samples = sample_nr(i);
                        next_samples = poissrnd(10);
                        while rest_samples > 0
                            time = 50*rand;
                            fprintf(p,'\t\t\t<lineageSeedMultiple spec="MultipleIndividuals" copies="%d" time="%.4f">\n',next_samples, time);
                            fprintf(p,'\t\t\t\t<population spec="Population" type="@L" location="%d"/>\n',i-1);
                            fprintf(p,'\t\t\t</lineageSeedMultiple>\n');
                            rest_samples = rest_samples - next_samples;
                            next_samples = poissrnd(10);
                        end
                    end
                elseif ~isempty(strfind(temp_lines{l},'insert_dimension'));
                    fprintf(p,'%s',strrep(temp_lines{l},'insert_dimension',num2str(states)));
                elseif ~isempty(strfind(temp_lines{l},'insert_filename'));
                    fprintf(p,'%s',strrep(temp_lines{l},'insert_filename',filename));
                else
                    fprintf(p,'%s',temp_lines{l});  % print line unchanged
                end
            end
            fclose(p); %close file again
        end
        fclose('all')
    end
end
