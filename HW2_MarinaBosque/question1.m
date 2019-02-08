%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%% DEVELOPMENT ECONOMICS - PROBLEM SET 2 %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all
clc

%% SETTING %%

% Parameters
N = 1000;
T = 12 * 40; % 12 months * 40 years of age
beta = 0.99^(1/12); % Anual beta (b^12) is 0.99
sigma2_e = 0.2;
sigma2_u = 0.2; 
eta1 = 1;
eta2 = 2;
eta4 = 4;

% Deterministic seasonal component
gm_low = [-0.073, -0.185, 0.071, 0.066, 0.045, 0.029, 0.018, 0.018, 0.018, 0.001, -0.017, -0.041];
gm_middle = [-0.147, -0.370, 0.141, 0.131, 0.090, 0.058, 0.036, 0.036, 0.036, 0.002, -0.033, -0.082];
gm_high = [-0.293, -0.739, 0.282, 0.262, 0.180, 0.116, 0.072, 0.072, 0.072, 0.004, -0.066, -0.164];

% Stochastic seasonal component
sigma2_low = [0.043, 0.034, 0.145, 0.142, 0.137, 0.137, 0.119, 0.102, 0.094, 0.094, 0.085, 0.068];
sigma2_middle = [0.085, 0.068, 0.290, 0.283, 0.273, 0.273, 0.239, 0.205, 0.188, 0.188, 0.171, 0.137];
sigma2_high = [0.171, 0.137, 0.580, 0.567, 0.546, 0.546, 0.478, 0.410, 0.376, 0.376, 0.341, 0.273];


%% QUESTION 1 - PART 1 %%

% Generate the individual component
ln_u = transpose(mvnrnd(zeros(N,1), eye(N) * sigma2_u)); % Nx1 matrix with the individual ln_u
z = exp(-sigma2_u/2) * exp(ln_u); % Nx1 column with individual components
z = z * ones(1,T); % NxT matrix, where each row contains the same individual component 

% Generate matrices with seasonal components (using kronecker product)
S_low = exp(kron(ones(N,40),gm_low)); % NxT matrix, where each column has a different seasonal component depending on age and season
S_middle = exp(kron(ones(N,40),gm_middle));
S_high = exp(kron(ones(N,40),gm_high));

% Generate matrix with individual errors for any period
ln_e = zeros(N,T);
for i = 1:N
    for j = 0:39
        ln_e(i,(1+12*j):((j+1)*12)) = normrnd(0,sqrt(sigma2_e));
    end
end
ind_shock = exp(-sigma2_e/2) * exp(ln_e);

% Calculate matrix of individual consumption with all components
consumption_low_all = z .* S_low .* ind_shock;      % NxT matrix
consumption_middle_all = z .* S_middle .* ind_shock;   % NxT matrix
consumption_high_all = z .* S_high .* ind_shock;    % NxT matrix

% Calculate matrix of individual consumption (without individual stochastic component)
consumption_low_sea = z .* S_low; 
consumption_middle_sea = z .* S_middle;
consumption_high_sea = z .* S_high;

% Calculate matrix of individual consumption (without seasonal component)
consumption_ind = z .* ind_shock; 

% Calculate matrix of individual consumption (without seasonal component and individual stochastic component)
consumption = z;

% Discount factor matrix
beta_m = zeros(1,12);
beta_age = zeros(1,40);
 for i = 1:12
     beta_m(1,i) = beta.^(i-1);
 end
 for i = 1:40 
     beta_age(1,i) = beta.^(12*i);
 end
betas = ones(N,1) * kron(beta_age,beta_m); % NxT matrix with all the discount factors


%% PART 1A: WELFARE GAINS REMOVING SEASONALITY %%

% Welfare gains from removing seasonal component (eta = 1)
% This are the matrix that will have the g's that represent the amount of consumption across 
% all periods and states that individuals living in a reference scenario will demand to remain 
% indifferent between their current scenario and the counterfactual, which is the value we are 
% interested to find. 

gl1_sea = zeros(N,1); 
gm1_sea = zeros(N,1);
gh1_sea = zeros(N,1);

% Here I compare the welfare gains of changing from the consumption with all the shocks with 
% the consumption after removing the seasonal component. In order to find the g's that satisfy,
% the equation I use a function that minimizes the absolute value of the difference between
% the two different scenarios we are comparing.

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(betas(i,:) .* log(consumption_low_all(i,:)*(1+gl))) - transpose(betas(i,:) .* log(consumption_ind(i,:))))));
    gl1_sea(i,1) = fminbnd(funlow,0,4);

    funmid = @(gm) abs(transpose(sum(transpose(betas(i,:) .* log(consumption_middle_all(i,:)*(1+gm))) - transpose(betas(i,:) .* log(consumption_ind(i,:))))));
    gm1_sea(i,1) = fminbnd(funmid,0,4);

    funhigh = @(gh) abs(transpose(sum(transpose(betas(i,:) .* log(consumption_high_all(i,:)*(1+gh))) - transpose(betas(i,:) .* log(consumption_ind(i,:))))));
    gh1_sea(i,1) = fminbnd(funhigh,0,4);
end

% Matrix with the mean results
Results = [mean(gl1_sea), mean(gm1_sea), mean(gh1_sea)];
disp(' RESULTS PART 1A - Mean welfare gains from removing seasonal component (eta=1)')
disp(Results)
disp('Each column represents the mean "g" for low, mid and high seasonality.')
disp(' ')
disp(' ')

%% PART 1B: WELFARE GAINS REMOVING NONSEASONAL CONSUMPTION RISK (individual stochastic component) %%

% Welfare gains from removing nonseasonal consumption risk (eta = 1)
gl1_ind = zeros(N,1);
gm1_ind = zeros(N,1);
gh1_ind = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(betas(i,:) .* log(consumption_low_all(i,:)*(1+gl))) - transpose(betas(i,:) .* log(consumption_low_sea(i,:))))));
    gl1_ind(i,1) = fminbnd(funlow,-4,4);

    funmid = @(gm) abs(transpose(sum(transpose(betas(i,:) .* log(consumption_middle_all(i,:)*(1+gm))) - transpose(betas(i,:) .* log(consumption_middle_sea(i,:))))));
    gm1_ind(i,1) = fminbnd(funmid,-4,4);

    funhigh = @(gh) abs(transpose(sum(transpose(betas(i,:) .* log(consumption_high_all(i,:)*(1+gh))) - transpose(betas(i,:) .* log(consumption_high_sea(i,:))))));
    gh1_ind(i,1) = fminbnd(funhigh,-4,4);
end

% Matrix with the mean results from removing nonseasonal consumption risk
Results = [mean(gl1_ind), mean(gm1_ind), mean(gh1_ind); std(gl1_ind), std(gm1_ind), std(gh1_ind)];

disp(' RESULTS PART 1B - Welfare gains of removing nonseasonal consumption risk (eta=1)')
disp(Results)
disp('First row: means. Second row: standard errors')
disp('Each column represents the mean "g" for low, mid, high and no seasonality.')
disp(' ')
disp(' ')

% Graph to compare distribution of welfare gains of removing nonseasonal consumption risk
%hold on
hist(gl1_ind);
xlabel('Individual g')
ylabel('Number of households')
legend('eta=1')
title({'Welfare gains of removing nonseasonal consumption risk'})
print('Q1_Part1_B','-dpng')


%% PART 1D: REDO FOR ETA = 2 & ETA = 4 %%

% Welfare gains removing seasonal component (eta = 2)
gl2_sea = zeros(N,1);
gm2_sea = zeros(N,1);
gh2_sea = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(betas(i,:) .* ((consumption_low_all(i,:)*(1+gl))).^(1-eta2) / (1-eta2)) - transpose(betas(i,:) .* ((consumption_ind(i,:)).^(1-eta2) / (1-eta2)) ))));
    gl2_sea(i,1) = fminbnd(funlow,-4,4);

    funmid = @(gm) abs(transpose(sum(transpose(betas(i,:) .* ((consumption_middle_all(i,:)*(1+gm))).^(1-eta2) / (1-eta2)) - transpose(betas(i,:) .* ((consumption_ind(i,:)).^(1-eta2) / (1-eta2))))));
    gm2_sea(i,1) = fminbnd(funmid,-4,4);

    funhigh = @(gh) abs(transpose(sum(transpose(betas(i,:) .* ((consumption_high_all(i,:)*(1+gh))).^(1-eta2) / (1-eta2)) - transpose(betas(i,:) .* ((consumption_ind(i,:)).^(1-eta2) / (1-eta2))))));
    gh2_sea(i,1) = fminbnd(funhigh,-4,4);
end

% Welfare gains removing seasonal component (eta = 4)
gl4_sea = zeros(N,1);
gm4_sea = zeros(N,1);
gh4_sea = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(betas(i,:) .* ((consumption_low_all(i,:)*(1+gl))).^(1-eta4) / (1-eta4)) - transpose(betas(i,:) .* ((consumption_ind(i,:)).^(1-eta4) / (1-eta4))))));
    gl4_sea(i,1) = fminbnd(funlow,-4,4);

    funmid = @(gm) abs(transpose(sum(transpose(betas(i,:) .* ((consumption_middle_all(i,:)*(1+gm))).^(1-eta4) / (1-eta4)) - transpose(betas(i,:) .* ((consumption_ind(i,:)).^(1-eta4) / (1-eta4))))));
    gm4_sea(i,1) = fminbnd(funmid,-4,4);

    funhigh = @(gh) abs(transpose(sum(transpose(betas(i,:) .* ((consumption_high_all(i,:)*(1+gh))).^(1-eta4) / (1-eta4)) - transpose(betas(i,:) .* ((consumption_ind(i,:)).^(1-eta4) / (1-eta4))))));
    gh4_sea(i,1) = fminbnd(funhigh,-4,4);
end

% Matrix with the mean results from removing seasonality
Results = [mean(gl2_sea), mean(gm2_sea), mean(gh2_sea); mean(gl4_sea), mean(gm4_sea), mean(gh4_sea)];
disp(' RESULTS PART 1D - Mean welfare gains of removing seasonality (eta=2 and eta=4)')
disp(Results)
disp('Row 1: eta=2. Row 2: eta=4')
disp('Each column represents the mean "g" for low, mid and high seasonality.')
disp(' ')
disp(' ')

% Welfare gains removing nonseasonal consumption risk (eta = 2)
gl2_ind = zeros(N,1);
gm2_ind = zeros(N,1);
gh2_ind = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(betas(i,:) .* ((consumption_low_all(i,:)*(1+gl))).^(1-eta2) / (1-eta2)) - transpose(betas(i,:) .* ((consumption_low_sea(i,:)).^(1-eta2) / (1-eta2))))));
    gl2_ind(i,1) = fminbnd(funlow,-4,4);

    funmid = @(gm) abs(transpose(sum(transpose(betas(i,:) .* ((consumption_middle_all(i,:)*(1+gm))).^(1-eta2) / (1-eta2)) - transpose(betas(i,:) .* ((consumption_middle_sea(i,:)).^(1-eta2) / (1-eta2))))));
    gm2_ind(i,1) = fminbnd(funmid,-4,4);

    funhigh = @(gh) abs(transpose(sum(transpose(betas(i,:) .* ((consumption_high_all(i,:)*(1+gh))).^(1-eta2) / (1-eta2)) - transpose(betas(i,:) .* ((consumption_high_sea(i,:)).^(1-eta2) / (1-eta2))))));
    gh2_ind(i,1) = fminbnd(funhigh,-4,4);
end

% Welfare gains removing nonseasonal consumption risk (eta = 4)
gl4_ind = zeros(N,1);
gm4_ind = zeros(N,1);
gh4_ind = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(betas(i,:) .* ((consumption_low_all(i,:)*(1+gl))).^(1-eta4) / (1-eta4)) - transpose(betas(i,:) .* ((consumption_low_sea(i,:)).^(1-eta4) / (1-eta4)) ))));
    gl4_ind(i,1) = fminbnd(funlow,-4,4);

    funmid = @(gm) abs(transpose(sum(transpose(betas(i,:) .* ((consumption_middle_all(i,:)*(1+gm))).^(1-eta4) / (1-eta4)) - transpose(betas(i,:) .* ((consumption_middle_sea(i,:)).^(1-eta4) / (1-eta4)) ))));
    gm4_ind(i,1) = fminbnd(funmid,-4,4);

    funhigh = @(gh) abs(transpose(sum(transpose(betas(i,:) .* ((consumption_high_all(i,:)*(1+gh))).^(1-eta4) / (1-eta4)) - transpose(betas(i,:) .* ((consumption_high_sea(i,:)).^(1-eta4) / (1-eta4)) ))));
    gh4_ind(i,1) = fminbnd(funhigh,-4,4);
end

Results_2 = [mean(gl2_ind), mean(gm2_ind), mean(gh2_ind); std(gl2_ind), std(gm2_ind), std(gh2_ind)];

Results_4 = [mean(gl4_ind), mean(gm4_ind), mean(gh4_ind); std(gl4_ind), std(gm4_ind), std(gh4_ind)];
        
% Matrix with the mean results
disp(' RESULTS PART 1D - Welfare gains of removing nonseasonal consumption risk (eta=2 and eta=4)')
disp(Results_2)
disp(Results_4)
disp('Rows 1 and 2: means for eta 2 and 4. Rows 3 and 4: standard errors for eta 2 and 4')
disp('Each column represents the mean "g" for low, mid, high and no seasonality.')
disp(' ')
disp(' ')

% Graph to compare distribution of welfare gains of removing nonseasonal consumption risk
figure 
hold on
histogram(gl1_ind);
hold on
histogram(gl2_ind);
hold on
histogram(gl4_ind);
xlabel('Individual g')
ylabel('Number of households')
legend('eta=1','eta=2','eta=4')
title({'Welfare gains of removing nonseasonal consumption risk'})
print('Q1_Part1_D','-dpng')


%% QUESTION 1 - PART 2 %%

% Generate matrices with seasonal components (NxT)
SR_low = zeros(N,T);
for i = 1:N
    for j = 0:39
      SR_low(i,(1+j*12):(j+1)*12) = exp(-sigma2_low/2) .* exp(mvnrnd(zeros(12,1), ones(12,1) * sigma2_low .* eye(12)));
    end
end

SR_middle = zeros(N,T);
for i = 1:N
    for j = 0:39
      SR_middle(i,(1+j*12):(j+1)*12) = exp(-sigma2_middle/2) .* exp(mvnrnd(zeros(12,1), ones(12,1) * sigma2_middle .* eye(12) ) );
    end
end

SR_high = zeros(N,T);
for i = 1:N
    for j = 0:39
      SR_high(i,(1+j*12):(j+1)*12) = exp(-sigma2_high/2) .* exp(mvnrnd(zeros(12,1), ones(12,1) * sigma2_high .* eye(12) ) );
    end
end

% Calculate matrix of individual consumption with all components
CS_low_all = z .* S_middle .*  SR_low .* ind_shock; 
CS_middle_all = z .* S_middle .* SR_middle .* ind_shock;
CS_high_all = z .* S_middle .* SR_high .* ind_shock;

% Calculate matrix of individual consumption (without seasonal component)
CS_low_sea = z .* SR_low .* ind_shock; 
CS_middle_sea = z .* SR_middle .* ind_shock;
CS_high_sea = z .* SR_high .* ind_shock;

% Calculate matrix of individual consumption (without individual stochastic component)
CS_low_ind = z .* S_middle .*  SR_low; 
CS_middle_ind = z .* S_middle .* SR_middle;
CS_high_ind = z .* S_middle .* SR_high;

% Calculate matrix of individual consumption (without stochastic seasonal component)
CS_sto = z .* S_middle .* ind_shock; 


%% PART 2A: WELFARE GAINS REMOVING SEASONALITY %%

% Welfare gains removing deterministic seasonal component (eta = 1)
gl1_sea2 = zeros(N,1); 
gm1_sea2 = zeros(N,1);
gh1_sea2 = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(betas(i,:) .* log(CS_low_all(i,:)*(1+gl))) - transpose(betas(i,:) .* log(CS_low_sea(i,:))))));
    gl1_sea2(i,1) = fminbnd(funlow,-4,4);

    funmid = @(gm) abs(transpose(sum(transpose(betas(i,:) .* log(CS_middle_all(i,:)*(1+gm))) - transpose(betas(i,:) .* log(CS_middle_sea(i,:))))));
    gm1_sea2(i,1) = fminbnd(funmid,-4,4);

    funhigh = @(gh) abs(transpose(sum(transpose(betas(i,:) .* log(CS_high_all(i,:)*(1+gh))) - transpose(betas(i,:) .* log(CS_high_sea(i,:))))));
    gh1_sea2(i,1) = fminbnd(funhigh,-4,4);
end

% Welfare gains removing stochastic seasonal component (eta = 1)
gl1_rsea = zeros(N,1); 
gm1_rsea = zeros(N,1);
gh1_rsea = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(betas(i,:) .* log(CS_low_all(i,:)*(1+gl))) - transpose(betas(i,:) .* log(CS_sto(i,:))))));
    gl1_rsea(i,1) = fminbnd(funlow,-4,4);

    funmid = @(gm) abs(transpose(sum(transpose(betas(i,:) .* log(CS_middle_all(i,:)*(1+gm))) - transpose(betas(i,:) .* log(CS_sto(i,:))))));
    gm1_rsea(i,1) = fminbnd(funmid,-4,4);

    funhigh = @(gh) abs(transpose(sum(transpose(betas(i,:) .* log(CS_high_all(i,:)*(1+gh))) - transpose(betas(i,:) .* log(CS_sto(i,:))))));
    gh1_rsea(i,1) = fminbnd(funhigh,-4,4);
end
  
% Welfare gains removing both seasonal components (eta = 1)
gl1_S_SR = zeros(N,1); 
gm1_S_SR = zeros(N,1);
gh1_S_SR = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(betas(i,:) .* log(CS_low_all(i,:)*(1+gl))) - transpose(betas(i,:) .* log(consumption_ind(i,:))))));
    gl1_S_SR(i,1) = fminbnd(funlow,-4,4);

    funmid = @(gm) abs(transpose(sum(transpose(betas(i,:) .* log(CS_middle_all(i,:)*(1+gm))) - transpose(betas(i,:) .* log(consumption_ind(i,:))))));
    gm1_S_SR(i,1) = fminbnd(funmid,-4,4);

    funhigh = @(gh) abs(transpose(sum(transpose(betas(i,:) .* log(CS_high_all(i,:)*(1+gh))) - transpose(betas(i,:) .* log(consumption_ind(i,:))))));
    gh1_S_SR(i,1) = fminbnd(funhigh,-4,4);
end

% Matrix with the mean results from removing deterministic component:
Results = [mean(gl1_sea2), mean(gm1_sea2), mean(gh1_sea2)];
disp(' RESULTS PART 2A - Welfare gains of removing deterministic seasonal component (eta=1)')
disp(Results)
disp('Rows: Means')
disp('Each column represents the mean "g" for low, mid and high seasonality.')
disp(' ')
disp(' ')

% Matrix with the mean results from removing stochastic component:
Results = [mean(gl1_rsea), mean(gm1_rsea), mean(gh1_rsea); std(gl1_rsea), std(gm1_rsea), std(gh1_rsea)];

disp('RESULTS PART 2A - Welfare gains of removing stochastic seasonal components (eta=1)')
disp(Results)
disp('Each column represents the mean "g" for low, mid and high seasonality.')
disp(' ')
disp(' ')

% Matrix with the mean results from removing both stochastic and deterministic component:
Results = [mean(gl1_S_SR), mean(gm1_S_SR), mean(gh1_S_SR); std(gl1_S_SR), std(gm1_S_SR), std(gh1_S_SR)];
       
disp(' RESULTS PART 2A: Welfare gains of removing both seasonality components (eta=1)')
disp(Results)
disp('Each column represents the mean "g" for low, mid and high seasonality.')
disp(' ')
disp(' ')

% Graph of the distribution of welfare gains of removing the seasonal stochastic component
figure 
hold on
histogram(gl1_rsea);
hold on
histogram(gm1_rsea);
hold on
histogram(gh1_rsea);
xlabel('Individual g')
ylabel('Number of households')
legend('Low seasonality dispersion','Medium seasonality dispersion','High seasonality dispersion')
title({'Welfare gains of removing stochastic seasonal component'})
print('Q1_Part2_A1','-dpng')

% Graph of the distribution of welfare gains of removing both seasonal components
figure 
hold on
histogram(gl1_S_SR);
hold on
histogram(gm1_S_SR);
hold on
histogram(gh1_S_SR);
xlabel('Individual g')
ylabel('Number of households')
legend('Low seasonality dispersion','Medium seasonality dispersion','High seasonality dispersion')
title({'Welfare gains of removing both seasonal components'})
print('Q1_Part2_A2','-dpng')

  
%% PART 2B: WELFARE GAINS REMOVING NONSEASONAL RISK  %%

% Welfare gains removing nonseasonal consumption risk (eta = 1)
gl1_ind_2 = zeros(N,1);
gm1_ind_2 = zeros(N,1);
gh1_ind_2 = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(betas(i,:) .* log(CS_low_all(i,:)*(1+gl))) - transpose(betas(i,:) .* log(CS_low_ind(i,:))))));
    gl1_ind_2(i,1) = fminbnd(funlow,-4,4);

    funmid = @(gm) abs(transpose(sum(transpose(betas(i,:) .* log(CS_middle_all(i,:)*(1+gm))) - transpose(betas(i,:) .* log(CS_middle_ind(i,:))))));
    gm1_ind_2(i,1) = fminbnd(funmid,-4,4);

    funhigh = @(gh) abs(transpose(sum(transpose(betas(i,:) .* log(CS_high_all(i,:)*(1+gh))) - transpose(betas(i,:) .* log(CS_high_ind(i,:))))));
    gh1_ind_2(i,1) = fminbnd(funhigh,-4,4);
end

% Matrix with the mean results
Results = [mean(gl1_ind_2), mean(gm1_ind_2), mean(gh1_ind_2); std(gl1_ind_2), std(gm1_ind_2), std(gh1_ind_2)];

disp(' RESULTS PART 2B - Welfare gains of removing nonseasonal consumption risk (eta=1)')
disp(Results)
disp('Each column represents the mean "g" for low, mid and high seasonality.')
disp(' ')
disp(' ')

% Graph to compare distribution of welfare gains of removing nonseasonal consumption risk
figure
hold on
hist(gl1_ind_2);
xlabel('Individual g')
ylabel('Number of households')
legend('eta=1')
title({'Welfare gains of removing nonseasonal consumption risk'})
print('Q1_Part2_B','-dpng')

%% PART 2D: REDO FOR ETA = 2 & ETA = 4 %%

% Welfare gains removing deterministic seasonal component (eta = 2)
gl2_sea2 = zeros(N,1); 
gm2_sea2 = zeros(N,1);
gh2_sea2 = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(betas(i,:) .* ((CS_low_all(i,:)*(1+gl))).^(1-eta2) / (1-eta2)) - transpose(betas(i,:) .* ((CS_low_sea(i,:)).^(1-eta2) / (1-eta2))))));
    gl2_sea2(i,1) = fminbnd(funlow,-4,4);

    funmid = @(gm) abs(transpose(sum(transpose(betas(i,:) .* ((CS_middle_all(i,:)*(1+gm))).^(1-eta2) / (1-eta2)) - transpose(betas(i,:) .* ((CS_middle_sea(i,:)).^(1-eta2) / (1-eta2))))));
    gm2_sea2(i,1) = fminbnd(funmid,-4,4);

    funhigh = @(gh) abs(transpose(sum(transpose(betas(i,:) .* ((CS_high_all(i,:)*(1+gh))).^(1-eta2) / (1-eta2)) - transpose(betas(i,:) .* ((CS_high_sea(i,:)).^(1-eta2) / (1-eta2))))));
    gh2_sea2(i,1) = fminbnd(funhigh,-4,4);
end


% Welfare gains removing deterministic seasonal component (eta = 4)
gl4_sea2 = zeros(N,1); 
gm4_sea2 = zeros(N,1);
gh4_sea2 = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(betas(i,:) .* ((CS_low_all(i,:)*(1+gl))).^(1-eta4) / (1-eta4)) - transpose(betas(i,:) .* ((CS_low_sea(i,:)).^(1-eta4) / (1-eta4))))));
    gl4_sea2(i,1) = fminbnd(funlow,-4,4);

    funmid = @(gm) abs(transpose(sum(transpose(betas(i,:) .* ((CS_middle_all(i,:)*(1+gm))).^(1-eta4) / (1-eta4)) - transpose(betas(i,:) .* ((CS_middle_sea(i,:)).^(1-eta4) / (1-eta4))))));
    gm4_sea2(i,1) = fminbnd(funmid,-4,4);

    funhigh = @(gh) abs(transpose(sum(transpose(betas(i,:) .* ((CS_high_all(i,:)*(1+gh))).^(1-eta4) / (1-eta4)) - transpose(betas(i,:) .* ((CS_high_sea(i,:)).^(1-eta4) / (1-eta4))))));
    gh4_sea2(i,1) = fminbnd(funhigh,-4,4);
end

% Matrix with the mean results from removing deterministic component (eta = 2)
Results_2 = [mean(gl2_sea2), mean(gm2_sea2), mean(gh2_sea2)];
disp(' RESULTS PART 2D - Welfare gains of removing deterministic seasonal component (eta=2)')
disp(Results_2)
disp('Rows: Means')
disp('Each column represents the mean "g" for low, mid and high seasonality.')
disp(' ')
disp(' ')

% Matrix with the mean results from removing deterministic component (eta = 4)
Results_4 = [mean(gl4_sea2), mean(gm4_sea2), mean(gh4_sea2)];
disp(' RESULTS PART 2D - Welfare gains of removing deterministic seasonal component (eta=4)')
disp(Results_4)
disp('Rows: Means')
disp('Each column represents the mean "g" for low, mid and high seasonality.')
disp(' ')
disp(' ')


% Welfare gains removing stochastic seasonal component (eta = 2)
gl2_rsea = zeros(N,1); 
gm2_rsea = zeros(N,1);
gh2_rsea = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(betas(i,:) .* ((CS_low_all(i,:)*(1+gl))).^(1-eta2) / (1-eta2)) - transpose(betas(i,:) .* ((CS_sto(i,:)).^(1-eta2) / (1-eta2)) ))));
    gl2_rsea(i,1) = fminbnd(funlow,-4,4);

    funmid = @(gm) abs(transpose(sum(transpose(betas(i,:) .* ((CS_middle_all(i,:)*(1+gm))).^(1-eta2) / (1-eta2)) - transpose(betas(i,:) .* ((CS_sto(i,:)).^(1-eta2) / (1-eta2)) ))));
    gm2_rsea(i,1) = fminbnd(funmid,-4,4);

    funhigh = @(gh) abs(transpose(sum(transpose(betas(i,:) .* ((CS_high_all(i,:)*(1+gh))).^(1-eta2) / (1-eta2)) - transpose(betas(i,:) .* ((CS_sto(i,:)).^(1-eta2) / (1-eta2)) ))));
    gh2_rsea(i,1) = fminbnd(funhigh,-4,4);
end


% Welfare gains removing stochastic seasonal component (eta = 4)
gl4_rsea = zeros(N,1); 
gm4_rsea = zeros(N,1);
gh4_rsea = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(betas(i,:) .* ((CS_low_all(i,:)*(1+gl))).^(1-eta4) / (1-eta4)) - transpose(betas(i,:) .* ((CS_sto(i,:)).^(1-eta4) / (1-eta4)) ))));
    gl4_rsea(i,1) = fminbnd(funlow,-4,4);

    funmid = @(gm) abs(transpose(sum(transpose(betas(i,:) .* ((CS_middle_all(i,:)*(1+gm))).^(1-eta4) / (1-eta4)) - transpose(betas(i,:) .* ((CS_sto(i,:)).^(1-eta4) / (1-eta4)) ))));
    gm4_rsea(i,1) = fminbnd(funmid,-4,4);

    funhigh = @(gh) abs(transpose(sum(transpose(betas(i,:) .* ((CS_high_all(i,:)*(1+gh))).^(1-eta4) / (1-eta4)) - transpose(betas(i,:) .* ((CS_sto(i,:)).^(1-eta4) / (1-eta4)) ))));
    gh4_rsea(i,1) = fminbnd(funhigh,-4,4);
end

% Matrix with the mean results from removing stochastic component (eta=2)
Results_2 = [mean(gl2_rsea), mean(gm2_rsea), mean(gh2_rsea); std(gl2_rsea), std(gm2_rsea), std(gh2_rsea)];
       
disp(' RESULTS PART 2D - Welfare gains of removing stochastic seasonal components (eta=2)')
disp(Results_2)
disp('Each column represents the mean "g" for low, mid and high seasonality.')
disp(' ')
disp(' ')

% Matrix with the mean results from removing stochastic component (eta=4)
Results_4 = [mean(gl4_rsea), mean(gm4_rsea), mean(gh4_rsea); std(gl4_rsea), std(gm4_rsea), std(gh4_rsea)];
       
disp(' RESULTS PART 2D - Welfare gains of removing stochastic seasonal components (eta=4)')
disp(Results_4)
disp('Each column represents the mean "g" for low, mid and high seasonality.')
disp(' ')
disp(' ')
  

% Welfare gains removing both seasonal components (eta = 2)
gl2_S_SR = zeros(N,1); 
gm2_S_SR = zeros(N,1);
gh2_S_SR = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(betas(i,:) .* ((CS_low_all(i,:)*(1+gl))).^(1-eta2) / (1-eta2)) - transpose(betas(i,:) .* ((consumption_ind(i,:)).^(1-eta2) / (1-eta2)) ))));
    gl2_S_SR(i,1) = fminbnd(funlow,-4,4);

    funmid = @(gm) abs(transpose(sum(transpose(betas(i,:) .* ((CS_middle_all(i,:)*(1+gm))).^(1-eta2) / (1-eta2)) - transpose(betas(i,:) .* ((consumption_ind(i,:)).^(1-eta2) / (1-eta2)) ))));
    gm2_S_SR(i,1) = fminbnd(funmid,-4,4);

    funhigh = @(gh) abs(transpose(sum(transpose(betas(i,:) .* ((CS_high_all(i,:)*(1+gh))).^(1-eta2) / (1-eta2)) - transpose(betas(i,:) .* ((consumption_ind(i,:)).^(1-eta2) / (1-eta2)) ))));
    gh2_S_SR(i,1) = fminbnd(funhigh,-4,4);
end

% Welfare gains removing both seasonal components (eta = 4)
gl4_S_SR = zeros(N,1); 
gm4_S_SR = zeros(N,1);
gh4_S_SR = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(betas(i,:) .* ((CS_low_all(i,:)*(1+gl))).^(1-eta4) / (1-eta4)) - transpose(betas(i,:) .* ((consumption_ind(i,:)).^(1-eta4) / (1-eta4)) ))));
    gl4_S_SR(i,1) = fminbnd(funlow,-4,4);

    funmid = @(gm) abs(transpose(sum(transpose(betas(i,:) .* ((CS_middle_all(i,:)*(1+gm))).^(1-eta4) / (1-eta4)) - transpose(betas(i,:) .* ((consumption_ind(i,:)).^(1-eta4) / (1-eta4)) ))));
    gm4_S_SR(i,1) = fminbnd(funmid,-4,4);

    funhigh = @(gh) abs(transpose(sum(transpose(betas(i,:) .* ((CS_high_all(i,:)*(1+gh))).^(1-eta4) / (1-eta4)) - transpose(betas(i,:) .* ((consumption_ind(i,:)).^(1-eta4) / (1-eta4)) ))));
    gh4_S_SR(i,1) = fminbnd(funhigh,-4,4);
end

% Matrix with the mean results from removing both stochastic and deterministic component (eta=2):
Results_2 = [mean(gl2_S_SR), mean(gm2_S_SR), mean(gh2_S_SR); std(gl2_S_SR), std(gm2_S_SR), std(gh2_S_SR)];
       
disp(' RESULTS PART 2D - Welfare gains of removing both seasonality components (eta=2)')
disp(Results_2)
disp('Each column represents the mean "g" for low, mid and high seasonality.')
disp(' ')
disp(' ')

% Matrix with the mean results from removing both stochastic and deterministic component (eta=4):
Results_4 = [mean(gl4_S_SR), mean(gm4_S_SR), mean(gh4_S_SR); std(gl4_S_SR), std(gm4_S_SR), std(gh4_S_SR)];
       
disp(' RESULTS PART 2D - Welfare gains of removing both seasonality components (eta=4)')
disp(Results_4)
disp('Each column represents the mean "g" for low, mid and high seasonality.')
disp(' ')
disp(' ')

% Welfare gains removing nonseasonal consumption risk (eta = 2)
gl2_ind_2 = zeros(N,1);
gm2_ind_2 = zeros(N,1);
gh2_ind_2 = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(betas(i,:) .* ((CS_low_all(i,:)*(1+gl))).^(1-eta2) / (1-eta2)) - transpose(betas(i,:) .* ((CS_low_ind(i,:)).^(1-eta2) / (1-eta2)) ))));
    gl2_ind_2(i,1) = fminbnd(funlow,-4,4);

    funmid = @(gm) abs(transpose(sum(transpose(betas(i,:) .* ((CS_middle_all(i,:)*(1+gm))).^(1-eta2) / (1-eta2)) - transpose(betas(i,:) .* ((CS_middle_ind(i,:)).^(1-eta2) / (1-eta2)) ))));
    gm2_ind_2(i,1) = fminbnd(funmid,-4,4);

    funhigh = @(gh) abs(transpose(sum(transpose(betas(i,:) .* ((CS_high_all(i,:)*(1+gh))).^(1-eta2) / (1-eta2)) - transpose(betas(i,:) .* ((CS_high_ind(i,:)).^(1-eta2) / (1-eta2)) ))));
    gh2_ind_2(i,1) = fminbnd(funhigh,-4,4);
end


% Welfare gains removing nonseasonal consumption risk (eta = 4)
gl4_ind_2 = zeros(N,1);
gm4_ind_2 = zeros(N,1);
gh4_ind_2 = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(transpose(sum(transpose(betas(i,:) .* ((CS_low_all(i,:)*(1+gl))).^(1-eta4) / (1-eta4)) - transpose(betas(i,:) .* ((CS_low_ind(i,:)).^(1-eta4) / (1-eta4)) ))));
    gl4_ind_2(i,1) = fminbnd(funlow,-4,4);

    funmid = @(gm) abs(transpose(sum(transpose(betas(i,:) .* ((CS_middle_all(i,:)*(1+gm))).^(1-eta4) / (1-eta4)) - transpose(betas(i,:) .* ((CS_middle_ind(i,:)).^(1-eta4) / (1-eta4)) ))));
    gm4_ind_2(i,1) = fminbnd(funmid,-4,4);

    funhigh = @(gh) abs(transpose(sum(transpose(betas(i,:) .* ((CS_high_all(i,:)*(1+gh))).^(1-eta4) / (1-eta4)) - transpose(betas(i,:) .* ((CS_high_ind(i,:)).^(1-eta4) / (1-eta4)) ))));
    gh4_ind_2(i,1) = fminbnd(funhigh,-4,4);
end

% Matrix with the mean results
Results_2 = [mean(gl2_ind_2), mean(gm2_ind_2), mean(gh2_ind_2); std(gl2_ind_2), std(gm2_ind_2), std(gh2_ind_2)];

disp(' RESULTS PART 2D - Welfare gains of removing nonseasonal consumption risk (eta=2)')
disp(Results_2)
disp('Each column represents the mean "g" for low, mid and high seasonality.')
disp(' ')
disp(' ')

% Matrix with the mean results
Results_4 = [mean(gl4_ind_2), mean(gm4_ind_2), mean(gh4_ind_2); std(gl4_ind_2), std(gm4_ind_2), std(gh4_ind_2)];

disp(' RESULTS PART 2D - Welfare gains of removing nonseasonal consumption risk (eta=4)')
disp(Results_4)
disp('Each column represents the mean "g" for low, mid and high seasonality.')
disp(' ')
disp(' ')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
