function companion_matrix = VAR_companion(VAR_coefficients);

% This function constructs the companion matrix of a VAR from the 
% cell-array estimates of the coefficients matrices of the VAR 
% in difference equation form
% Thus VAR_coefficients{1} is the coefficients on y(t-1) and so on

n_lags = length(VAR_coefficients);
[n_variables,~] = size(VAR_coefficients{1});
n_fill = (n_lags-1)*n_variables;

companion_matrix = [cell2mat(VAR_coefficients);eye(n_fill),zeros(n_fill,n_variables)];


