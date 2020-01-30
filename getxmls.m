clear 

% start and end position of to use from the sequence alignment
start_pos = 1000;
end_pos = 29000;

% list of sequences not included
exclude = {'Wuhan/IPBCAMS-WH-05/2020','Shenzhen/SZTH-001/2020'};

% mask random variable positions at prob
mask_prob = [0 0.25 0.5];

getXmlConditions([0.001 100]);
createRandomDates(start_pos, end_pos, exclude);
maskRandomSNPs(start_pos, end_pos, mask_prob, exclude);