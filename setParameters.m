%% Set parameters

% N number of firms
% S number of sectors
% W input output matrix, size SxS
% A connectivity matrix (unweighted), size NxN
% B household budget

function [price, final_demand, original_productivity, decay_rates...
            , perturbation_regime, failure_rates, original_over_order_rate, outsiders] = setParameters(n, primary_producers, final_producers...
            , failure_rates_all_firms, original_productivity_all_firms, decay_rates_all_firms)
   
    % Choice
    demand_type = 'final_producers';
    perturbation_regime = 'inputed';
    over_order_behavior = 'homogenous';
    pricing = 'homogenous';
    main_over_order_rate = 1;
    average_demand = 1;
    outsider_over_order_rate = 1;
    ratio_outsiders = 0.5;
    width_of_uniform_distribution_over_order_rate = 0;
    
    % Automatically generated parameters
    % Demand vector
    switch demand_type
        case 'uniform'
            final_demand = average_demand * ones(n,1);
            
        case 'last_one'
            final_demand = zeros(n,1);
            final_demand(n) = average_demand;
            
        case 'last_ones'
            final_demand = zeros(n,1);
            final_demand((n-2):n) = average_demand/3;
        
        case 'last_layer'
            in_degree = sum(primary_producers);
            final_demand = zeros(n,1);
            final_demand((end-in_degree+1):end) = average_demand/in_degree;
            
        case 'final_producers'
            final_demand = zeros(n,1);
            final_demand(final_producers) = average_demand/sum(final_producers);
            
        otherwise
            error('Wrong demand type selected');
    end
    
    % Price
    switch pricing
        case 'homogenous'
            price = ones(n,1);
            
        case 'mark-up'
            initial_cost = 1;
            margin = 0.3;
            trophic_levels = computeTrophicLevels(connectivity_matrix, primary_producers, n);
            price = (initial_cost + trophic_levels * margin)';
            
    end
    
    
    % Productivity, failure rates, decay rates
    original_productivity = original_productivity_all_firms * ones(1,n);
    failure_rates = failure_rates_all_firms * ones(1,n);
    decay_rates = decay_rates_all_firms * ones(1,n);
    
    % Over_ordering
    % the over_order_rate of primary producers is always 1
    outsiders = 0*(1:n);
    switch over_order_behavior
        case 'homogenous'
            original_over_order_rate = main_over_order_rate * ones(1,n);
            original_over_order_rate(primary_producers) = 1;
            
        case 'dual'
            original_over_order_rate = main_over_order_rate * ones(1,n);
            not_primary_producers = ~primary_producers;
            ids = (1:n);
            id_not_primary_producers = ids(not_primary_producers);
            n_not_primary_producers = sum(not_primary_producers);
            
            if ratio_outsiders > 0
                nb_outsiders = round(ratio_outsiders*n_not_primary_producers);
                outsiders_index = id_not_primary_producers(randsample(n_not_primary_producers,nb_outsiders));
                original_over_order_rate(outsiders_index) = outsider_over_order_rate;
                outsiders = ismember(1:n, outsiders_index);
            end
            
            original_over_order_rate(primary_producers) = 1;
            
        case 'uniformly_distributed' % draw according to a uniform distribution
            center_of_distribution = main_over_order_rate;
            width_of_distribution = width_of_uniform_distribution_over_order_rate;
            lower_bound = center_of_distribution - width_of_distribution/2;
            upper_bound = center_of_distribution + width_of_distribution/2;
            
            original_over_order_rate = lower_bound + rand(1,n) * (upper_bound-lower_bound);
            original_over_order_rate(primary_producers) = 1;
            
        case 'lognormal'
            if mean_lognorm == 0
                original_over_order_rate = ones(1,n);
            else
                scale_parameter = sqrt(log(1+sd_lognorm^2/mean_lognorm^2)); 
                location_parameter = log(mean_lognorm) - scale_parameter^2/2; 
                original_over_order_rate = 1 + exp(location_parameter + scale_parameter*randn(1,n));
            end
            original_over_order_rate(primary_producers) = 1;
            
        otherwise
            error('Wrong over_order_behavior selected');
    end
        
end