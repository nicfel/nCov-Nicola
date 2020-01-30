function [] = getXmlConditions(growth_sigma)

system('rm -r xmls');
system('mkdir xmls');


h = fopen('expo_rates.csv', 'w');

for a = 1:length(growth_sigma)
    fprintf(h, '%d,%f\n', a,growth_sigma(a));
    f = fopen('xml_templates/expo_template.xml');
    g = fopen(sprintf('xmls/expo_%d.xml', a), 'w');
    while ~feof(f)
        line = fgets(f);
        if contains(line, 'insert_sigma')
            fprintf(g, strrep(line, 'insert_sigma', num2str(growth_sigma(a))));
        else
            fprintf(g, line);
        end
    end
    fclose(f);
    fclose(g);
end
fclose(h);

h = fopen('bdsky_rates.csv', 'w');


uninfectious_time = [1/5 1/10 1/20]*365;
orign_prior = [50 70 90]/365;
sampling = [0.01 0.05 0.1 0.25];

for a = 1:length(uninfectious_time)
    for b = 1:length(orign_prior)
        for c = 1:length(sampling)
            fprintf(h, '%d,%d,%d,%f,%f,%f\n', a,b,c,uninfectious_time(a), orign_prior(b), sampling(c));

            f = fopen('xml_templates/bdsky_template.xml');
            g = fopen(sprintf('xmls/bdsky_%d_%d_%d.xml', a, b, c), 'w');
            while ~feof(f)
                line = fgets(f);
                if contains(line, 'insert_uninfectious')
                    fprintf(g, strrep(line, 'insert_uninfectious', num2str(uninfectious_time(a))));
                elseif contains(line, 'insert_orign_prior')
                    fprintf(g, strrep(line, 'insert_orign_prior', num2str(orign_prior(b))));
                elseif contains(line, 'insert_sampling')
                    fprintf(g, strrep(line, 'insert_sampling_prop', num2str(sampling(c))));
                else
                    fprintf(g, line);
                end
            end
            fclose(f);
            fclose(g);
        end
    end
end
fclose(h);
end
