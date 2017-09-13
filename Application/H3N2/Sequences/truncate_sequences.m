clear
fasta = fastaread('Fludb_30_06_2017.fasta');

dont_use = 'EU857031 EU501751 EU501840 AB243870';

c = 1;
for i = 1 : length(fasta)
    tmp = strsplit(fasta(i).Header,'|');
    if isempty(strfind(dont_use,tmp{2}))    
        tmp2 = strsplit(tmp{3},'/');
        if length(tmp2)==3
            if length(fasta(i).Sequence) > 984
                seq_elements = unique(fasta(i).Sequence);
                if length(seq_elements)<5
                    year = str2double(tmp2{3})+1;
                    newtime = (year-1)+ (datenum(tmp{3},'mm/dd/yyyy') -...
                        datenum(tmp2{3},'yyyy'))/...
                        (datenum(sprintf('%d',year),'yyyy') - datenum(tmp2{3},'yyyy'));
                    if newtime <2003
                        header = strrep(fasta(i).Header,tmp{3},...
                            sprintf('%.6f',newtime));
                        Data(c) = fasta(i);
                        Data(c).Header = header;
                        location{c,1} = tmp{4};
                        c = c + 1;
                    end
                end
            end
        end
    else
        disp(tmp{2})
    end
end

ul = unique(location);
for i = 1 : length(ul)
    nr(i) = length(find(ismember(location,ul{i})));
end


% delete('H3N2_notaligned.fasta');
% fastawrite('H3N2_notaligned.fasta', Data);

%% subsampled to have 300 sequences from each location

use = zeros(0,0);
rng(1);

for i = 1 : length(ul)
    tmp = find(ismember(location,ul{i}));
    if length(tmp)>15
        tmp2 = randsample(tmp,min(100,length(tmp)));
        use = [use;tmp2];
    end
end

SubSampled = Data(use);
delete('H3N2_notaligned_subsampled.fasta');
fastawrite('H3N2_notaligned_subsampled.fasta', SubSampled);


