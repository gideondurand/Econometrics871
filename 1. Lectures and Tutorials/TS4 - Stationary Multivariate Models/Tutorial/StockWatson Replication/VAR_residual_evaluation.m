function output = VAR_residual_evaluation(VAR_residuals,options)

[num_obs,num_var]=size(VAR_residuals);

if nargin < 2
    names = cell(1:num_var);
    standardize = true;
    outlier_def = 3;
else
    names = options.names;
    standardize = options.standardize;
    outlier_def = options.outlier_def; % number of standard deviations that is considered an outlier
end

[num_obs,num_var]=size(VAR_residuals);



dates = 1:num_obs; % to be updated to handle input dates

std_residuals = (VAR_residuals - mean(VAR_residuals))./repmat(std(VAR_residuals),num_obs,1);

output.outliers = abs(std_residuals)>outlier_def;

if standardize
    
    figure
    for i = 1:num_var
        if i == 1
            title('standardized residuals')
        end
        subplot(num_var,1,i)
        hold on
        plot(dates,std_residuals(:,i)) 
        line([1,num_obs],[-2 -2],'Color','r')
        line([1,num_obs],[2 2],'Color','r')
        ylabel(names{i})
    end
    
else
    lower_bounds = mean(VAR_residuals)-2*std(VAR_residuals);
    upper_bounds = mean(VAR_residuals)+2*std(VAR_residuals);
    figure
    for i = 1:num_var
        title('residuals')
        subplot(num_var,1,i)
        hold on
        plot(dates,VAR_residuals(:,i)) 
        line([1,num_obs],[lower_bounds(i) lower_bounds(i)],'Color','r')
        line([1,num_obs],[upper_bounds(i) upper_bounds(i)],'Color','r')
        ylabel(names{i})
    end
end
Lags = [1:12]';

for i = 1:num_var
    [reject,pValue,stat,cValue] = lbqtest(VAR_residuals(:,i),'Lags',Lags);
    names{i}
    table(Lags,stat,cValue,pValue,reject)
end