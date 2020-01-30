function [] = maskRandomSNPs(start_pos, end_pos, mask_prob, exclude)

% get the alignments and the variable positions
fasta_ori = fastaread('../ncov/data/ncov.fasta');
% remove all sequences with unknown sampling time
c = 1;
name = cell(0,0);
for i = 1:length(fasta_ori)
    tmp = strsplit(fasta_ori(i).Header, '|');
    seq_name = tmp{1};
    if ~contains(fasta_ori(i).Header, 'XX') && isempty(find(ismember(seq_name, exclude)))
        fasta(c) = fasta_ori(i);
        name{c} = tmp{1};
        c=c+1;
    end
end


% % vector keeping track if there are different based at a position
has_variability = false(1,length(fasta(1).Sequence));
is_SNP = false(1,length(fasta(1).Sequence));
nr_bases = 0;

for i = 1:length(fasta(1).Sequence)
    seqs = '';
    for j=1:length(fasta)
        seqs = [seqs fasta(j).Sequence(i)];
    end
    % remove all gaps and N's
    redseqs = regexprep(seqs, '[-N]', '');
    uni_chars = unique(redseqs);
    if length(uni_chars)>1
        has_variability(i) = true;
        % check if the variability is shared by more than one sequence
        for k = 1:length(uni_chars)
            nr_occurance = sum(redseqs==uni_chars(k));
            if nr_occurance~=1 && nr_occurance~=length(redseqs)-1
                disp(nr_occurance)
            end
            if nr_occurance==1
                index = find(ismember(seqs, uni_chars(k)));
                is_SNP(index, i) = true;
            end
        end
    end
    nr_bases = nr_bases+length(seqs);
end
% fprintf('SNP''s can be explained solely by a consensus calling error rate of\n%f\n', 1-sum(has_variability)/nr_bases);

system('rm -r masked_xmls')
system('mkdir masked_xmls')

% redo the xmls, but this time, randomly mask SNP's at a probability that
% is given by the mask prob
for a = 1:length(mask_prob)
    
    if mask_prob(a)>0
        nr_reps=10;
        xmls = dir('date_randomization_xmls/*true*.xml');
    else
        xmls = dir('date_randomization_xmls/*.xml');
        nr_reps=1;
    end
    % randomly mask mutations
    for r = 1:nr_reps
        [x,y] = find(is_SNP);
        l = length(x);
        for i = l:-1:1
            if rand > mask_prob(a)
                x(i) = [];
                y(i) = [];
            end
        end
        % replace all (x,y)'s with N's
        new_seqs = fasta;
        if length(x)>0
            for i=1:length(x)
                disp(new_seqs(x(i)).Sequence(y(i)))
                new_seqs(x(i)).Sequence(y(i)) = 'N';
                disp(new_seqs(x(i)).Sequence(y(i)))
            end
        end


        for b = 1:length(xmls)
            f = fopen(['date_randomization_xmls/' xmls(b).name]);
            g = fopen(['masked_xmls/' strrep(xmls(b).name, '.xml', sprintf('_%d_rep%d.xml', a, r))], 'w');
            while ~feof(f)
                line = fgets(f);
                if contains(line, '<sequence id="seq')
                    taxon=strsplit(line, '"');
                    index = find(ismember(name, taxon{6}));
                    
                    fprintf(g, '<sequence id="seq_%s" spec="Sequence" taxon="%s" totalcount="4" value="%s"/>\n',name{index},name{index},new_seqs(index).Sequence(start_pos:end_pos));
                elseif contains(line, 'insert_sampling_times')
                    sampling_times = 'remove';
                    for i = 1:length(new_seqs)
                        tmp = regexp(new_seqs(i).Header, '(\d*)-(\d*)-(\d*)', 'match');
                        sampling_times = [sampling_times ',' name{i} '=' tmp{1}];
                    end
                    sampling_times = strrep(sampling_times, 'remove,','');
                else
                    fprintf(g, line);
                end
            end
            fclose('all');
        end
    end
end
end