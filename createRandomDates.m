function [] = createRandomDates(start_pos, end_pos, exclude)

% randomize dates
dates ={'true', 'random'};


rng(1); % set the random number generator for reproducability of random dates
fasta_ori = fastaread('../ncov/data/ncov.fasta'); % read in the alignments
f = fopen('sequences_used.csv', 'w');
fprintf(f, 'Accession|Strain|Sampling Times|Lab|Authors\n');

% remove all sequences with unknown sampling time
c = 1;
name = cell(0,0);
for i = 1:length(fasta_ori)
    tmp = strsplit(fasta_ori(i).Header, '|');
    seq_name = tmp{1};
    if ~contains(fasta_ori(i).Header, 'XX')  && isempty(find(ismember(seq_name, exclude)))
        fasta(c) = fasta_ori(i);
        tmp = strsplit(fasta(c).Header, '|');
        fprintf(f, '%s|%s|%s|%s|%s\n', tmp{3}, tmp{1}, tmp{5}, tmp{13}, tmp{14});
        name{c} = tmp{1};
        c=c+1;
    end    
end
fclose(f);

system('rm -r date_randomization_xmls')
system('mkdir date_randomization_xmls')

% redo the xmls, but this time, randomly mask SNP's at a probability that
% is given by the mask prob
xmls = dir('xmls/expo*.xml');
for a = 1:length(dates)
    nr_reps = 1;
    if strcmp(dates{a}, 'random')
        nr_reps = 10;
    end
    
    for r = 1 : nr_reps    
        for b = 1:length(xmls)
            if strcmp(dates{a}, 'random')
                date_map = 1:length(fasta);
                date_map = date_map(randperm(length(date_map)));
            else
                date_map = 1:length(fasta);
            end

            f = fopen(['xmls/' xmls(b).name]);
            g = fopen(['date_randomization_xmls/' strrep(xmls(b).name, '.xml', sprintf('_%s_%d.xml', dates{a},r))], 'w');
            while ~feof(f)
                line = fgets(f);
                if contains(line, 'insert_sequences')
                    for i = 1:length(fasta)
                        fprintf(g, '<sequence id="seq_%s" spec="Sequence" taxon="%s" totalcount="4" value="%s"/>\n',name{i},name{i},fasta(i).Sequence(start_pos:end_pos));
                    end
                elseif contains(line, 'insert_sampling_times')
                    sampling_times = 'remove';
                    for i = 1:length(fasta)
                        tmp = regexp(fasta(date_map(i)).Header, '(\d*)-(\d*)-(\d*)', 'match');
                        sampling_times = [sampling_times ',' name{i} '=' tmp{1}];
                    end
                    sampling_times = strrep(sampling_times, 'remove,','');
                    fprintf(g, strrep(line,'insert_sampling_times',sampling_times));
                elseif contains(line, 'M="0.0015" S="0.25"')
                    fprintf(g, '                <LogNormal id="Uniform.3" name="distr" M="0" S="4"/>');
%                     fprintf(g, strrep(line,'0.25','4'));
                else
                    fprintf(g, line);
                end
            end
            fclose('all');
        end
    end
end
end


