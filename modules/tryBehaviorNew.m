function [overorderrate_tried, all_profits_tried] = tryBehaviorNew(current_firm_updating, current_overorder_rates...
    , trait_exploration_step, evolutionary_period, minimum_overordering_rates ...
    , decay_rate, perturbation_regime, failure_rates, connectivity_matrix, original_productivity, price, final_demand, primary_producers, n)

    % Compute the overorder rates that will be tried
    current_trait = current_overorder_rates(current_firm_updating);
    min_trait_value = minimum_overordering_rates(current_firm_updating);
    trait_to_try = [max(min_trait_value, current_trait - trait_exploration_step); current_trait + trait_exploration_step; current_trait];

    % Prepare the exploration: generate list of failures to try, compute nb of trials and create data that will be stored
    list_failures = (rand(evolutionary_period,n) > (ones(evolutionary_period,1) * failure_rates));
    nb_trials = length(trait_to_try);
    all_profits_tried = zeros(nb_trials,n);
    
    % Loop over the trials
    %if the current overordering is the minimum one, then the first and third trial will the same, so that we can keep the first one
    EPSILON = 1e-4;
    if current_trait < min_trait_value + EPSILON, first_trial =2; else first_trial=1; end
        
    for trial=first_trial:nb_trials

        % Update the overordering rates
        over_order_rate = current_overorder_rates;
        over_order_rate(current_firm_updating) = trait_to_try(trial);

        % Given the current value of the trait, update the initial conditions
        [production_targets, initial_inventories, fixed_order_flows, fixed_import_flows] = setFixedOrdersProdTargets(over_order_rate, connectivity_matrix, original_productivity, final_demand, primary_producers, n);

        % Perform the dynamics during one evolutionary time step
        profits_ts = performDynProfitOnly(evolutionary_period...
            , production_targets, initial_inventories, fixed_order_flows, fixed_import_flows ...
            , decay_rate, perturbation_regime, failure_rates, list_failures, original_productivity, final_demand, price, n);

        % Store the variables
        overorderrate_tried = trait_to_try;
        all_profits_tried(trial,:) = mean(profits_ts);

    end
                
end