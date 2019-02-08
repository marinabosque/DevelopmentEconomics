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
sigma_e = sqrt(sigma2_e);
sigma2_u = 0.2; 
v = 1;

% Calibrate for kappa
theta = 0.6; % Labor share of total output
y_over_c = 1/0.25; % Output over consumption
h_month = 28.5 * (30/7); % Hours worked per month
kappa = theta * y_over_c * (h_month)^(-1-1/v);

% Deterministic seasonal component
gm_low = [-0.073, -0.185, 0.071, 0.066, 0.045, 0.029, 0.018, 0.018, 0.018, 0.001, -0.017, -0.041];
gm_middle = [-0.147, -0.370, 0.141, 0.131, 0.090, 0.058, 0.036, 0.036, 0.036, 0.002, -0.033, -0.082];
gm_high = [-0.293, -0.739, 0.282, 0.262, 0.180, 0.116, 0.072, 0.072, 0.072, 0.004, -0.066, -0.164];

% Stochastic seasonal component
sigma2_low = [ 0.043, 0.034, 0.145, 0.142, 0.137, 0.137, 0.119, 0.102, 0.094, 0.094, 0.085, 0.068];
sigma2_mid = [0.085, 0.068, 0.290, 0.283, 0.273, 0.273, 0.239, 0.205, 0.188, 0.188, 0.171, 0.137];
sigma2_high = [0.171, 0.137, 0.580, 0.567, 0.546, 0.546, 0.478, 0.410, 0.376, 0.376, 0.341, 0.273];

% Discounting matrix
beta_m = zeros(1,12);
beta_age = zeros(1,40);
 for i = 1:12
     beta_m(1,i) = beta.^(i-1);
 end
 for i = 1:40 
     beta_age(1,i) = beta.^(12*i);
 end
betas = ones(N,1) * kron(beta_age,beta_m);

%% PREPARING CONSUMPTION AND LABOR COMMON %%

% Generate matrices with seasonal components (using kronecker product)
S_low = exp(kron(ones(N,40),gm_low)); % NxT matrix, where each column has a different seasonal component depending on age and season
S_middle = exp(kron(ones(N,40),gm_middle));
S_high = exp(kron(ones(N,40),gm_high));

% Positively correlated: Stochastic seasonal components for both consumption and labor
SR_low = zeros(N,T);
lab_SR_low = zeros(N,T);
for k = 1:1000
    for j = 0:39
        for i = 1:12
            varcov = [sigma2_low(1,i), 0.03; 0.03,sigma2_low(1,i)];
            ln = mvnrnd(zeros(2,1), varcov);
            SR_low(k,i+j*12) = exp(-sigma2_low(1,i)/2) * exp(ln(1,1));
            lab_SR_low(k,i+j*12) = exp(-sigma2_low(1,i)/2) * exp(ln(1,2));
        end
    end
end

SR_middle = zeros(N,T);
lab_SR_middle = zeros(N,T);
for k = 1:1000
    for j = 0:39
        for i = 1:12
            varcov = [sigma2_mid(1,i), 0.03; 0.03,sigma2_mid(1,i)];
            ln = mvnrnd(zeros(2,1), varcov);
            SR_middle(k,i+j*12) = exp(-sigma2_mid(1,i)/2) * exp(ln(1,1));
            lab_SR_middle(k,i+j*12) = exp(-sigma2_mid(1,i)/2) * exp(ln(1,2));
        end
    end
end

SR_high = zeros(N,T);
lab_SR_high = zeros(N,T);
for k = 1:1000
    for j = 0:39
        for i = 1:12
            varcov = [sigma2_high(1,i), 0.03; 0.03,sigma2_high(1,i)];
            ln = mvnrnd(zeros(2,1), varcov);
            SR_high(k,i+j*12) = exp(-sigma2_high(1,i)/2) * exp(ln(1,1));
            lab_SR_high(k,i+j*12) = exp(-sigma2_high(1,i)/2) * exp(ln(1,2));
        end
    end
end

% Negatively correlated: Stochastic seasonal components for both consumption and labor
SR_low_negative = zeros(N,T);
lab_SR_low_negative = zeros(N,T);
for k = 1:1000
    for j = 0:39
        for i = 1:12
        varcov = [sigma2_low(1,i), -0.03; -0.03,sigma2_low(1,i)];
        ln = mvnrnd(zeros(2,1), varcov);
        SR_low_negative(k,i+j*12) = exp(-sigma2_low(1,i)/2) * exp(ln(1,1));
        lab_SR_low_negative(k,i+j*12) = exp(-sigma2_low(1,i)/2) * exp(ln(1,2));
        end
    end
end

SR_middle_negative = zeros(N,T);
lab_SR_middle_negative = zeros(N,T);
for k = 1:1000
    for j = 0:39
        for i = 1:12
        varcov = [sigma2_mid(1,i), -0.03; -0.03,sigma2_mid(1,i)];
        ln = mvnrnd(zeros(2,1), varcov);
        SR_middle_negative(k,i+j*12) = exp(-sigma2_mid(1,i)/2) * exp(ln(1,1));
        lab_SR_middle_negative(k,i+j*12) = exp(-sigma2_mid(1,i)/2) * exp(ln(1,2));
        end
    end
end

SR_high_negative = zeros(N,T);
lab_SR_high_negative = zeros(N,T);
for k = 1:1000
    for j = 0:39
        for i = 1:12
        varcov = [sigma2_high(1,i), -0.03; -0.03,sigma2_high(1,i)];
        ln = mvnrnd(zeros(2,1), varcov);
        SR_high_negative(k,i+j*12) = exp(-sigma2_high(1,i)/2) * exp(ln(1,1));
        lab_SR_high_negative(k,i+j*12) = exp(-sigma2_high(1,i)/2) * exp(ln(1,2));
        end
    end
end

%% GENERATE CONSUMPTION %%

% Generate the individual component
ln_u = transpose(mvnrnd(zeros(N,1), eye(N) * sigma2_u)); % Nx1 matrix with the individual ln_u
z = exp(-sigma2_u/2) * exp(ln_u); % Nx1 column with individual components
z = z * ones(1,T); % NxT matrix, where each row contains the same individual component 

% Generate matrix with individual errors for any period
ln_e = zeros(N,T);
for i = 1:N
    for j = 0:39
        ln_e(i,(1+12*j):((j+1)*12)) = normrnd(0,sqrt(sigma2_e));
    end
end
ind_shock = exp(-sigma2_e/2) * exp(ln_e);


%% GENERATE LABOR %%

% Generate the individual component
lab_ln_u = mvnrnd(zeros(N,1),eye(N) * sigma2_u).'; 
lab_z = exp(-sigma2_u/2) * exp(lab_ln_u); 
lab_z = lab_z * ones(1,T); 

% Generate matrix with individual errors for any period
lab_ln_e = zeros(N,T);
for i = 1:N
    for j = 0:39
        lab_ln_e(i,(1+12*j):((j+1)*12)) = normrnd(0,sqrt(sigma2_e));
    end
end
lab_ind_shock = exp(-sigma2_e/2) * exp(lab_ln_e);


%% GENERATE CONSUMPTION AND LABOR POSITIVELY CORRELATED

% Calculate matrix of individual consumption
C_low_all = z .* S_low .*  SR_low .* ind_shock; 
C_middle_all = z .* S_middle .* SR_middle .* ind_shock;
C_high_all = z .* S_high .* SR_high .* ind_shock;

C_low_S_SR = z .* S_low .*  SR_low; 
C_middle_S_SR = z .* S_middle .* SR_middle;
C_high_S_SR = z .* S_high .* SR_high;

C_low_sind = z .* S_low .* ind_shock; 
C_middle_sind = z .* S_middle .* ind_shock;
C_high_sind = z .* S_high .* ind_shock;

C_low_sea = z .* S_low; 
C_midle_sea = z .* S_middle;
C_high_sea = z .* S_high;

C_ind = z .* ind_shock; 
C = z;

% Calculate matrix of individual labor 
L_low_all = lab_z .* S_low .*  lab_SR_low .* lab_ind_shock; 
L_middle_all = lab_z .* S_middle .* lab_SR_middle .* lab_ind_shock;
L_high_all = lab_z .* S_high .* lab_SR_high .* lab_ind_shock;

L_low_S_SR = lab_z .* S_low .*  lab_SR_low; 
L_middle_S_SR = lab_z .* S_middle .* lab_SR_middle;
L_high_S_SR = lab_z .* S_high .* lab_SR_high;

L_low_sind = lab_z .* S_low .* lab_ind_shock; 
L_middle_sind = lab_z .* S_middle .* lab_ind_shock;
L_high_sind = lab_z .* S_high .* lab_ind_shock;

L_low_sea = lab_z .* S_low; 
L_middle_sea = lab_z .* S_middle;
L_high_sea = lab_z .* S_high;

L_ind = lab_z .* lab_ind_shock; 
L = lab_z;

%% GENERATE CONSUMPTION AND LABOR NEGATIVELY CORRELATED

% Calculate matrix of individual consumptions (NxT each matrix)
C_low_all_negative = z .* S_low .*  SR_low_negative .* ind_shock; 
C_middle_all_negative = z .* S_middle .* SR_middle_negative .* ind_shock;
C_high_all_negative = z .* S_high .* SR_high_negative .* ind_shock;
C_low_S_SR_negative = z .* S_low .*  SR_low_negative; 
C_middle_S_SR_negative = z .* S_middle .* SR_middle_negative;
C_high_S_SR_negative = z .* S_high .* SR_high_negative;

% Calculate matrix of individual labors (NxT each matrix)
L_low_all_negative = lab_z .* S_low .*  lab_SR_low_negative .* lab_ind_shock; 
L_middle_all_negative = lab_z .* S_middle .* lab_SR_middle_negative .* lab_ind_shock;
L_high_all_negative = lab_z .* S_high .* lab_SR_high_negative .* lab_ind_shock;
L_low_S_SR_negative = lab_z .* S_low .*  lab_SR_low_negative; 
L_middle_S_SR_negative = lab_z .* S_middle .* lab_SR_middle_negative;
L_high_S_SR_negative = lab_z .* S_high .* lab_SR_high_negative;


%% QUESTION 2 - PART A : HIGHLY POSITIVELY CORRELATED CONSUMPTION AND LEISURE %%

% Total effects
gl_S_SR = zeros(N,1); 
gm_S_SR = zeros(N,1);
gh_S_SR = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(sum(...
        transpose(betas(i,:).*(log(C_low_all(i,:).*(1+gl))  -  kappa.*(L_low_all(i,:).^(1+1/v)/(1+1/v))  )) - ... 
        transpose(betas(i,:).*(log(C_ind(i,:))  -  kappa.*(L_ind(i,:).^(1+1/v)/(1+1/v)) ))));
    gl_S_SR(i,1) = fminbnd(funlow,-20,20);

    funmid = @(gm) abs(sum(...
        transpose(betas(i,:).*(log(C_middle_all(i,:).*(1+gm))  -  kappa.*(L_middle_all(i,:).^(1+1/v)/(1+1/v))  )) - ... 
        transpose(betas(i,:).*(log(C_ind(i,:))  -  kappa.*(L_ind(i,:).^(1+1/v)/(1+1/v)) ))));
    gm_S_SR(i,1) = fminbnd(funmid,-20,20);

    funhigh = @(gh) abs(sum(...
        transpose(betas(i,:).*(log(C_high_all(i,:).*(1+gh))  -  kappa.*(L_high_all(i,:).^(1+1/v)/(1+1/v))  )) - ... 
        transpose(betas(i,:).*(log(C_ind(i,:))  -  kappa.*(L_ind(i,:).^(1+1/v)/(1+1/v)) ))));
    gh_S_SR(i,1) = fminbnd(funhigh,-20,20);
end

% Consumption effects
gl_S_SR_con = zeros(N,1); 
gm_S_SR_con = zeros(N,1);
gh_S_SR_con = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(sum(...
        transpose(betas(i,:).*(log(C_low_all(i,:).*(1+gl))  -  kappa.*(L_low_all(i,:).^(1+1/v)/(1+1/v))  )) - ... 
        transpose(betas(i,:).*(log(C_ind(i,:))  -  kappa.*(L_low_all(i,:).^(1+1/v)/(1+1/v)) ))));
    gl_S_SR_con(i,1) = fminbnd(funlow,-20,20);

    funmid = @(gm) abs(sum(...
        transpose(betas(i,:).*(log(C_middle_all(i,:).*(1+gm))  -  kappa.*(L_middle_all(i,:).^(1+1/v)/(1+1/v))  )) - ... 
        transpose(betas(i,:).*(log(C_ind(i,:))  -  kappa.*(L_middle_all(i,:).^(1+1/v)/(1+1/v)) ))));
    gm_S_SR_con(i,1) = fminbnd(funmid,-20,20);

    funhigh = @(gh) abs(sum(...
        transpose(betas(i,:).*(log(C_high_all(i,:).*(1+gh))  -  kappa.*(L_high_all(i,:).^(1+1/v)/(1+1/v))  )) - ... 
        transpose(betas(i,:).*(log(C_ind(i,:))  -  kappa.*(L_high_all(i,:).^(1+1/v)/(1+1/v)) ))));
    gh_S_SR_con(i,1) = fminbnd(funhigh,-20,20);
end

% Labor effects
gl_S_SR_lab = zeros(N,1); 
gm_S_SR_lab = zeros(N,1);
gh_S_SR_lab = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(sum(...
        transpose(betas(i,:).*(log(C_ind(i,:).*(1+gl))  -  kappa.*(L_low_all(i,:).^(1+1/v)/(1+1/v))  )) - ... 
        transpose(betas(i,:).*(log(C_ind(i,:))  -  kappa.*(L_ind(i,:).^(1+1/v)/(1+1/v))  ))));
    gl_S_SR_lab(i,1) = fminbnd(funlow,-20,20);

    funmid = @(gm) abs(sum(...
        transpose(betas(i,:).*(log(C_ind(i,:).*(1+gm))  -  kappa.*(L_middle_all(i,:).^(1+1/v)/(1+1/v))  )) - ... 
        transpose(betas(i,:).*(log(C_ind(i,:))  -  kappa.*(L_ind(i,:).^(1+1/v)/(1+1/v))  ))));
    gm_S_SR_lab(i,1) = fminbnd(funmid,-20,20);

    funhigh = @(gh) abs(sum(...
        transpose(betas(i,:).*(log(C_ind(i,:).*(1+gh))  -  kappa.*(L_high_all(i,:).^(1+1/v)/(1+1/v))  )) - ... 
        transpose(betas(i,:).*(log(C_ind(i,:)) -  kappa.*(L_ind(i,:).^(1+1/v)/(1+1/v)) ))));
    gh_S_SR_lab(i,1) = fminbnd(funhigh,-20,20);
end

 
% Summary statistics total effects
Results = [mean(gl_S_SR), mean(gm_S_SR), mean(gh_S_SR); std(gl_S_SR), std(gm_S_SR), std(gh_S_SR)];
       
disp(' RESULTS PART A - Total effects')
disp(Results)
disp('Each column: "g" for low, mid, high, and no seasonality')
disp(' ')
disp(' ')
 
% Summary statistics consumption effects
Results = [mean(gl_S_SR_con), mean(gm_S_SR_con), mean(gh_S_SR_con); std(gl_S_SR_con), std(gm_S_SR_con), std(gh_S_SR_con)];
       
disp(' RESULTS PART A - Consumption effects')
disp(Results)
disp('Each column: "g" for low, mid, high, and no seasonality')
disp(' ')
disp(' ')

% Summary statistics labor effects
Results = [mean(gl_S_SR_lab), mean(gm_S_SR_lab), mean(gh_S_SR_lab); std(gl_S_SR_lab), std(gm_S_SR_lab), std(gh_S_SR_lab)];

disp(' RESULTS PART A - Labor effects')
disp(Results)
disp('Each column: "g" for low, mid, high, and no seasonality')
disp(' ')
disp(' ')

% Graphs
figure
subplot(3,1,1);
hold on
histogram(gl_S_SR,16,'BinWidth',0.01);
hold on
histogram(gl_S_SR_con,16,'BinWidth',0.01);
hold on
histogram(gl_S_SR_lab,16,'BinWidth',0.01);
xlim([-0.05 0.4]);
xlabel('Individual g')
ylabel('Num indiv')
legend('g_{total}','g_{consumption}','g_{labor}')
title('Low seasonality. Positive correlation')
 
subplot(3,1,2);
hold on
histogram(gm_S_SR,16,'BinWidth',0.01);
hold on
histogram(gm_S_SR_con,16,'BinWidth',0.01);
hold on
histogram(gm_S_SR_lab,16,'BinWidth',0.01);
xlim([-0.05 0.4]);
xlabel('Individual g')
ylabel('Num indiv')
legend('g_{total}','g_{consumption}','g_{labor}')
title('Medium seasonality. Positive correlation')
 
subplot(3,1,3);
hold on
histogram(gh_S_SR,16,'BinWidth',0.01);
hold on
histogram(gh_S_SR_con,16,'BinWidth',0.01);
hold on
histogram(gh_S_SR_lab,16,'BinWidth',0.01);
xlim([-0.05 0.4]);
xlabel('Individual g')
ylabel('Num indiv')
legend('g_{total}','g_{consumption}','g_{labor}')
title('high seasonality. Positive correlation')
print('Q2_A','-dpng')


%% QUESTION 2 - PART B : HIGHLY NEGATIVELY CORRELATED CONSUMPTION AND LEISURE %%

% Total effects
gl_S_SR_negative = zeros(N,1); 
gm_S_SR_negative = zeros(N,1);
gh_S_SR_negative = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(sum(...
        transpose(betas(i,:).*(log(C_low_all_negative(i,:).*(1+gl))  -  kappa.*(L_low_all_negative(i,:).^(1+1/v)/(1+1/v))  )) - ... 
        transpose(betas(i,:).*(log(C_ind(i,:))  -  kappa.*(L_ind(i,:).^(1+1/v)/(1+1/v)) ))));
    gl_S_SR_negative(i,1) = fminbnd(funlow,-20,20);

    funmid = @(gm) abs(sum(...
        transpose(betas(i,:).*(log(C_middle_all_negative(i,:).*(1+gm))  -  kappa.*(L_middle_all_negative(i,:).^(1+1/v)/(1+1/v))  )) - ... 
        transpose(betas(i,:).*(log(C_ind(i,:))  -  kappa.*(L_ind(i,:).^(1+1/v)/(1+1/v)) ))));
    gm_S_SR_negative(i,1) = fminbnd(funmid,-20,20);

    funhigh = @(gh) abs(sum(...
        transpose(betas(i,:).*(log(C_high_all_negative(i,:).*(1+gh))  -  kappa.*(L_high_all_negative(i,:).^(1+1/v)/(1+1/v))  )) - ... 
        transpose(betas(i,:).*(log(C_ind(i,:))  -  kappa.*(L_ind(i,:).^(1+1/v)/(1+1/v))  ))));
    gh_S_SR_negative(i,1) = fminbnd(funhigh,-20,20);
end

% Consumption effects
gl_S_SR_con_negative = zeros(N,1); 
gm_S_SR_con_negative = zeros(N,1);
gh_S_SR_con_negative = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(sum(...
        transpose(betas(i,:).*(log(C_low_all_negative(i,:).*(1+gl))  -  kappa.*(L_low_all_negative(i,:).^(1+1/v)/(1+1/v))  )) - ... 
        transpose(betas(i,:).*(log(C_ind(i,:))  -  kappa.*(L_low_all_negative(i,:).^(1+1/v)/(1+1/v)) ))));
    gl_S_SR_con_negative(i,1) = fminbnd(funlow,-20,20);

    funmid = @(gm) abs(sum(...
        transpose(betas(i,:).*(log(C_middle_all_negative(i,:).*(1+gm))  -  kappa.*(L_middle_all_negative(i,:).^(1+1/v)/(1+1/v))  )) - ... 
        transpose(betas(i,:).*(log(C_ind(i,:))  -  kappa.*(L_middle_all_negative(i,:).^(1+1/v)/(1+1/v))  ))));
    gm_S_SR_con_negative(i,1) = fminbnd(funmid,-20,20);

    funhigh = @(gh) abs(sum(...
        transpose(betas(i,:).*(log(C_high_all_negative(i,:).*(1+gh))  -  kappa.*(L_high_all_negative(i,:).^(1+1/v)/(1+1/v))  )) - ... 
        transpose(betas(i,:).*(log(C_ind(i,:))  -  kappa.*(L_high_all_negative(i,:).^(1+1/v)/(1+1/v)) ))));
    gh_S_SR_con_negative(i,1) = fminbnd(funhigh,-20,20);
end

% Labor effects
gl_S_SR_lab_negative = zeros(N,1); 
gm_S_SR_lab_negative = zeros(N,1);
gh_S_SR_lab_negative = zeros(N,1);

for i = 1:N
    funlow = @(gl) abs(sum(...
        transpose(betas(i,:).*(log(C_ind(i,:).*(1+gl))  -  kappa.*(L_low_all_negative(i,:).^(1+1/v)/(1+1/v))  )) - ... 
        transpose(betas(i,:).*(log(C_ind(i,:))  -  kappa.*(L_ind(i,:).^(1+1/v)/(1+1/v))  ))));
    gl_S_SR_lab_negative(i,1) = fminbnd(funlow,-20,20);

    funmid = @(gm) abs(sum(...
        transpose(betas(i,:).*(log(C_ind(i,:).*(1+gm))  -  kappa.*(L_middle_all_negative(i,:).^(1+1/v)/(1+1/v))  )) - ... 
        transpose(betas(i,:).*(log(C_ind(i,:))  -  kappa.*(L_ind(i,:).^(1+1/v)/(1+1/v)) ))));
    gm_S_SR_lab_negative(i,1) = fminbnd(funmid,-20,20);

    funhigh = @(gh) abs(sum(...
        transpose(betas(i,:).*(log(C_ind(i,:).*(1+gh))  -  kappa.*(L_high_all_negative(i,:).^(1+1/v)/(1+1/v))  )) - ... 
        transpose(betas(i,:).*(log(C_ind(i,:)) -  kappa.*(L_ind(i,:).^(1+1/v)/(1+1/v)) ))));
    gh_S_SR_lab_negative(i,1) = fminbnd(funhigh,-20,20);
end

 
% Summary statistics total effects
Results = [mean(gl_S_SR_negative), mean(gm_S_SR_negative), mean(gh_S_SR_negative); std(gl_S_SR_negative), std(gm_S_SR_negative), std(gh_S_SR_negative)];
       
disp(' RESULTS PART B - Total effects')
disp(Results)
disp('Each column: "g" for low, mid, high, and no seasonality')
disp(' ')
disp(' ')
 
% Summary statistics consumption effects
Results = [mean(gl_S_SR_con_negative), mean(gm_S_SR_con_negative), mean(gh_S_SR_con_negative); ...
           std(gl_S_SR_con_negative), std(gm_S_SR_con_negative), std(gh_S_SR_con_negative)];
       
disp(' RESULTS PART B - Consumption effects')
disp(Results)
disp('Each column: "g" for low, mid, high, and no seasonality')
disp(' ')
disp(' ')

% Summary statistics labor effects
Results = [mean(gl_S_SR_lab_negative), mean(gm_S_SR_lab_negative), mean(gh_S_SR_lab_negative); std(gl_S_SR_lab_negative), std(gm_S_SR_lab_negative), std(gh_S_SR_lab_negative)];
       
disp(' RESULTS PART B - Labor effects')
disp(Results)
disp('Each column: "g" for low, mid, high, and no seasonality')
disp(' ')
disp(' ')

% Graphs
figure
subplot(3,1,1);
hold on
histogram(gl_S_SR_negative,16,'BinWidth',0.01);
hold on
histogram(gl_S_SR_con_negative,16,'BinWidth',0.01);
hold on
histogram(gl_S_SR_lab_negative,16,'BinWidth',0.01);
xlim([-0.05 0.4]);
xlabel('Individual g')
ylabel('Num indiv')
legend('g_{total}','g_{consumption}','g_{labor}')
title('Low seasonality. Negative correlation')
 
subplot(3,1,2);
hold on
histogram(gm_S_SR_negative,16,'BinWidth',0.01);
hold on
histogram(gm_S_SR_con_negative,16,'BinWidth',0.01);
hold on
histogram(gm_S_SR_lab_negative,16,'BinWidth',0.01);
xlim([-0.05 0.4]);
xlabel('Individual g')
ylabel('Num indiv')
legend('g_{total}','g_{consumption}','g_{labor}')
title('Medium seasonality. Negative correlation')
 
subplot(3,1,3);
hold on
histogram(gh_S_SR_negative,16,'BinWidth',0.01);
hold on
histogram(gh_S_SR_con_negative,16,'BinWidth',0.01);
hold on
histogram(gh_S_SR_lab_negative,16,'BinWidth',0.01);
xlim([-0.05 0.4]);
xlabel('Individual g')
ylabel('Num indiv')
legend('g_{total}','g_{consumption}','g_{labor}')
title('high seasonality. Negative correlation')
print('Q2_B','-dpng')

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
