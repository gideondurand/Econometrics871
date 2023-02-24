%% Illustration Script of the Box-Jenkins methodology

% Example 1: Simulated data
% Step 0: generate the data
% The Econometrics toolbox has a strong suite of functions for ARIMA modelling.
 
true_model = arima('Constant',0.4,'AR',{0, 0.25},'D',0, 'MA',0.5,'Variance',0.15)
%Next, we use the built in function that simulates data from a wide array of different statistical models. A lot of additional options can be added, such as given initial conditions etc. 
T = 212; % number of observations
rng(1) % set the seed of the pseudo random number generator
y = simulate(true_model,T)
% Step 1.1: Visualize the data
% One must always look at a time series graph of the data at hand. This is the 
% first step to see obvious problems (missing data, outliers, changes in behaviour 
% over time.

plot(1:T,y)
xlabel('time periods')
ylabel('data values')

% Step 1.2: Evaluate the ACF and PACF
% To establish if there is strong evidence of specific patterns that hints at 
% the most appropriate ARMA order

autocorr(y)
parcorr(y)

% Step 1.3: Select the most likely set of ARMA models
% Compare these patterns to those described by Enders. Is there an obvious candidate? 
% Does it correspond to what we know the true process is? Remember that Enders 
% gives us the _theoretical_ patterns. With noise as here, the fit will never 
% be exact, but the patterns tend to be close to the theoretical ones. 
% Step 2: Estimate the selected model(s)
% In general, with real-world data, we would not want to take the risk of selecting 
% the wrong model (in terms of ARMA orders) so would typically start with a set 
% of potential models. For this simulated example, however, we can use the known 
% structure and compare it to more/less flexible models directly
% 
% We again use the arima function to specify the model. There are a number of 
% different ways to do it. Here I use the more explicit version as it is easier 
% to read what is going on. We specify it as above, but replace the known parameters 
% we chose above with NaN to indicate which coefficients should be estimated. 
% We can also impose restrictions on certain coefficients by entering numbers. 

% Name-Value syntax
% postulated_model = arima('Constant',nan,'AR',{nan},'D',0)

%% Alternative syntax 
% that is easier to use to search a large set of models,
% using a function that assumes that a constant has to be estimated:
% Set the order (for instance, an ARMA(1,1) model:
p = 1;
d = 0;
q = 1;
postulated_model = regARIMA(p,d,q);
estimated_model = estimate(postulated_model,y)

%% 
% Step 3: Evaluate model adequacy
% Now we need to check whether the fitted model satisfies our requirements.
% Step 3.1: Congruency
% Does the estimated statistical model have the properties of the postulated 
% statistical model? 
% 
% In our case, again, things are very simple. By construction, the functional 
% form will be the one we postulated. What we need to check is the other assumptions
% White noise, normally distributed residuals
% Find the residuals from the estimation:

residuals = infer(estimated_model,y);

% Plot them against time:

plot(1:T,residuals)
xlabel('time periods')
ylabel('residuals')
 
% Evaluate their ACF and PACF:

autocorr(residuals)
parcorr(residuals)

 
% Formally test for residual autocorrelation at a variety of lags using the 
% Ljung-Box test statistic (must start larger than the AR order of the estimated 
% model!)
% 
% The Matlab implementation of the Ljung-Box test has a number of different 
% ways it can be used. See the help file and experiment. 
% 
% We need to specify the degrees of freedom and the lags at which we want to 
% test the hypothesis.

lags = [2:12]; % select the lag or set of lags at which the test should be conducted
degrees_of_freedom = lags - 1; % sample size minus number of coefficients estimated other than the constant and variance
[reject_1,p_value_1] = lbqtest(residuals,'Lags',lags,'DOF',degrees_of_freedom)

 
% Check for autocorrelation in squared residuals (this tests for homoscedasticity 
% against and alternative of auto-regressive heteroscedasticity (ARCH effects):

[reject_2,p_value_2] = lbqtest(residuals.^2,'Lags',lags,'DOF',degrees_of_freedom) %#ok<*ASGLU> 

%% 
% Since, in this example, we postulated that the errors are normal, we can check 
% if the residuals test as such:
% 
% We will use the standard Jarque-Bera test, although there are more sophisticated 
% options. This test relies on the third moment (the normal distribution is symmetric, 
% so has a zero third moment) and the fourth moment (the fourth moment of a normal 
% distribution is always equal to 3), and combines them into a single test statistic 
% with a known distribution under the null hypothesis of normality. 

hist(residuals)
[reject_normality,p_value_normality,jbstat,critval] = jbtest(residuals)

%% Step 3.2. Parsimony
% using the Akaike and Bayesian Information Criteria

postulated_model_ARMA10 = regARIMA(1,0,0);
postulated_model_ARMA11 = regARIMA(1,0,1);
postulated_model_ARMA20 = regARIMA(2,0,0);
postulated_model_ARMA21 = regARIMA(2,0,1);

logL = zeros(4,1); % Preallocate loglikelihood vector
[~,~,logL(1)] = estimate(postulated_model_ARMA10,y,'Display','off');
[~,~,logL(2)] = estimate(postulated_model_ARMA11,y,'Display','off');
[~,~,logL(3)] = estimate(postulated_model_ARMA20,y,'Display','off');
[~,~,logL(4)] = estimate(postulated_model_ARMA21,y,'Display','off');


% The syntax for the test is:
% 
% [aic,bic] = aicbic(logL,numParam,numObs)|>

numParam = [3; 4; 5; 6];
numObs = length(y)*ones(4,1) - [1;1;2;2]; % adjust for the lost observations due to having to use lags

[aic,bic] = aicbic(logL, numParam , numObs)

% If you want to flex your coding muscles, look at this example of how to
% automate some of this, search for "Choose Lags for ARMA Error Model" in
% the help file and work through the example code
