% combine sequence and meta data
clear
fasta = fastaread('../ncov/data/ncov.fasta'); % read fasta files
f = fopen('../ncov/data/metadata.tsv');c=1;fgets(f)
while ~feof(f)
    line = fgets(f);
    tmp = strsplit(line, '\t');
    name{c,1} = tmp{3};
    time{c,1} = tmp{4};
    c = c+1;
end
fclose(f);

dsa
c=1;
for i = 1 : length(fasta)
    tmp = strsplit(fasta(i).Header, '|');
    index = find(ismember(name,tmp{2}));
    if ~isempty(index)
        Data(c) = fasta(i);
        Data(c).Header = [Data(c).Header '|' time{index}];
        c = c+1;
    end 
end
delete('data/sequences_meta.fasta')
fastawrite('data/sequences_meta.fasta', Data)
