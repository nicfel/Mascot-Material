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


for S = 1 : 1000
    filename = sprintf('Rates_S%d_master',S);
    fname = sprintf('./master/%s.xml',filename);   % set the file name
    p = fopen(fname,'w');
    
    migration = exprnd(0.5,30,1);
    Ne = lognrnd(-0.125,0.5,6,1);
    ri = randi(6,50,1);
    sample_nr(1) =  sum(ri==1);
    sample_nr(2) =  sum(ri==2);
    sample_nr(3) =  sum(ri==3);
    sample_nr(4) =  sum(ri==4);
    sample_nr(5) =  sum(ri==5);
    sample_nr(6) =  sum(ri==6);
    
    while min(sample_nr)==0
        ri = randi(6,50,1);
        sample_nr(1) =  sum(ri==1);
        sample_nr(2) =  sum(ri==2);
        sample_nr(3) =  sum(ri==3);
        sample_nr(4) =  sum(ri==4);
        sample_nr(5) =  sum(ri==5);
        sample_nr(6) =  sum(ri==6);
    end
    

    sample_nr = sample_nr*20;
    
    Ne_nr = 1;
    m_nr = 1;

    for l = 1 : length(temp_lines)
        if ~isempty(strfind(temp_lines{l},'insert_coalescent'));
            Ne_rate = Ne(Ne_nr);
            fprintf(p,'%s',strrep(temp_lines{l},'insert_coalescent',num2str(1/(2*Ne_rate))));
            Ne_nr = Ne_nr + 1;
        elseif  ~isempty(strfind(temp_lines{l},'insert_migration'));
            migration_rates = migration(m_nr);
            fprintf(p,'%s',strrep(temp_lines{l},'insert_migration',num2str(migration_rates)));
            m_nr = m_nr + 1;
        elseif  ~isempty(strfind(temp_lines{l},'insert_samples'));                
            for a = 1 : sample_nr(1)
                fprintf(p,'\t\t\t<lineageSeedMultiple spec="MultipleIndividuals" copies="1" time="%.4f">\n',10*rand);
                fprintf(p,'\t\t\t\t<population spec="Population" type="@L" location="0"/>\n');
                fprintf(p,'\t\t\t</lineageSeedMultiple>\n');
            end
            for a = 1 : sample_nr(2)
                fprintf(p,'\t\t\t<lineageSeedMultiple spec="MultipleIndividuals" copies="1" time="%.4f">\n',10*rand);
                fprintf(p,'\t\t\t\t<population spec="Population" type="@L" location="1"/>\n');
                fprintf(p,'\t\t\t</lineageSeedMultiple>\n');
            end    
            for a = 1 : sample_nr(3)
                fprintf(p,'\t\t\t<lineageSeedMultiple spec="MultipleIndividuals" copies="1" time="%.4f">\n',10*rand);
                fprintf(p,'\t\t\t\t<population spec="Population" type="@L" location="2"/>\n');
                fprintf(p,'\t\t\t</lineageSeedMultiple>\n');
            end 
            for a = 1 : sample_nr(4)
                fprintf(p,'\t\t\t<lineageSeedMultiple spec="MultipleIndividuals" copies="1" time="%.4f">\n',10*rand);
                fprintf(p,'\t\t\t\t<population spec="Population" type="@L" location="3"/>\n');
                fprintf(p,'\t\t\t</lineageSeedMultiple>\n');
            end            
            for a = 1 : sample_nr(5)
                fprintf(p,'\t\t\t<lineageSeedMultiple spec="MultipleIndividuals" copies="1" time="%.4f">\n',10*rand);
                fprintf(p,'\t\t\t\t<population spec="Population" type="@L" location="4"/>\n');
                fprintf(p,'\t\t\t</lineageSeedMultiple>\n');
            end            
            for a = 1 : sample_nr(6)
                fprintf(p,'\t\t\t<lineageSeedMultiple spec="MultipleIndividuals" copies="1" time="%.4f">\n',10*rand);
                fprintf(p,'\t\t\t\t<population spec="Population" type="@L" location="5"/>\n');
                fprintf(p,'\t\t\t</lineageSeedMultiple>\n');
            end   
        elseif ~isempty(strfind(temp_lines{l},'insert_filename'));
            fprintf(p,'%s',strrep(temp_lines{l},'insert_filename',filename));
        else
            fprintf(p,'%s',temp_lines{l});  % print line unchanged
        end
    end
    fclose(p); %close file again
end
