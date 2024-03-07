function VAR_roots_test(AR_coefficients,options)

% computes the characteristic roots of the companion matrix of the VAR 
% to assess stationarity of VAR
% reporting can be disabled with the options

if nargin<2
    report = "figure";
else
    report = options.report;
end

characteristic_roots = eig(VAR_companion(AR_coefficients));
absolute_characteristic_roots = abs(characteristic_roots);



if report == "table"
    table(sort(absolute_characteristic_roots,'descend'))
elseif report == "figure"
    abs_max_root = max(absolute_characteristic_roots)
    phi = linspace(0,2*pi,100)';
    [x,y] = pol2cart(phi,ones(100,1));
    figure
    hold on
    plot(characteristic_roots,'o','MarkerSize',4,'MarkerEdgeColor','none','MarkerFaceColor','b')
    plot(x,y,'r')
    title('Characteristic Roots of VAR')
    xlabel('real parts')
    ylabel('imaginary parts')
    axis([-1.1 1.1 -1.1 1.1])
    axis square
end

    