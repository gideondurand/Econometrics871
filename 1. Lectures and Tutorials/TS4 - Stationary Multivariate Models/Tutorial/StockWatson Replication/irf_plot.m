function irf_plot(irf,irf_lower,irf_upper,options)

[periods,shocks,responses]=size(irf);

if nargin==1
    options.shock_selection = 1:shocks;
    options.response_selection = 1:responses;
    options.confidence_bands = false;
end

if isfield(options,'shock_names')
    shock_names = options.shock_names;
else
    shock_names = cell(shocks,1);
    for shock = options.shock_selection
        shock_names{shock}=['$\varepsilon_{',num2str(shock),'}$'];
    end
end

if isfield(options,'variable_names')
    variable_names = options.variable_names;
else
    variable_names = cell(responses,1);
    for response = options.response_selection
        variable_names{response}=['$x_{',num2str(response),'}$'];
    end
end

subplot_numbers = 1:shocks*responses;
subplot_numbers = reshape(subplot_numbers,responses,shocks);

if ~options.confidence_bands % no confidence bands
    figure
    for shock = 1:shocks
        for variable= 1:responses
            %subplot(shocks,responses,subplot_numbers(shock,variable))
            subplot(shocks,responses,subplot_numbers(variable,shock))
                hold on
                line([1 periods],[0 0],'Color','k','LineWidth',1);
                plot(irf(:,shock,variable),'Color',[0,0.447,0.741],'LineWidth',1.5);                
                grid on
                axis([1,periods,-inf,inf])
                title(['response of ',variable_names{variable},' to ',shock_names{shock}],'Interpreter','latex')
                hold off          
        end
    end

else % confidence bands
    
    figure
    for shock = 1:shocks
        for variable= 1:responses
            %subplot(shocks,responses,subplot_numbers(shock,variable))
            subplot(shocks,responses,subplot_numbers(variable,shock))
                hold on
                line([1 periods],[0 0],'Color','k','LineWidth',1);
                area_components = area([irf_lower(:,shock,variable),irf_upper(:,shock,variable)-irf_lower(:,shock,variable)],'EdgeColor','none');
                area_components(1).FaceColor = 'none';
                area_components(2).FaceColor = [0,0.447,0.741];
                area_components(2).FaceAlpha = 0.5;
                plot(irf(:,shock,variable),'Color',[0,0.447,0.741],'LineWidth',1.5);
                grid on
                axis([1,periods,-inf,inf])
                title(['response of ',variable_names{variable},' to ',shock_names{shock}],'Interpreter','latex')
                hold off          
        end
    end
    
end


% for later development
% % set up name-value pairs for varargin.
% for i = 1:2:length(varargin) % work for a list of name-value pairs
%     if ischar(varargin{i}) % check if is character
%         params.(varargin{i}) = varargin{i+1} % override or add parameters to structure.
%     end
% end
