function profits_ts = performDynProfitOnly(duration...
    , production_targets, initial_inventories, fixed_order_flows, fixed_import_flows ...
    , decay_rate, perturbation_regime, failure_rates, list_failures, original_productivity, final_demand, price, n)

    % Set initial conditions
    inventory = initial_inventories;
    
    % Set time series to store    
    profits_ts = zeros(duration, n);
    
    % Time loop
    for t=1:duration

        % Create shocks (shocks = 1 if no shock, 0 if shocks)
        switch perturbation_regime
            case 'none'
                shocks = ones(1,n);
            case 'permanent'
                shocks = (rand(1,n) > failure_rates);
            case 'inputed'
                shocks = list_failures(t,:);
            otherwise
                error('wrong type of shock regime inserted');
        end

        % Produce
        production = min(original_productivity' .* inventory, production_targets); % They do not produce more than what is demanded
        inventory_used = production ./ original_productivity';
        
        % Apply shocks
        production = production .* shocks';
        
        % Prepare delivery
        % disp((production ./ production_targets));
        rationing = min((production ./ production_targets), 1);
        % disp("rationing");
        % disp(size(rationing));

        % Trade
        %trade of intermediary goods
        good_flows = fixed_order_flows .* (rationing * ones(1,n));
        b2b_paiments = (price * ones(1,n)) .* good_flows;
        %trade of final goods
        final_good_flows = final_demand .* rationing;
        b2c_paiments = price .* final_good_flows;
        %trade of raw materials
        import_flows = fixed_import_flows;
        import_paiments = price .* import_flows;
    
        % Receive goods and update inventories
        inventory_decayed = (inventory - inventory_used) * decay_rate;
        new_good_received = sum(good_flows,1)' + import_flows;
        inventory = inventory - inventory_used - inventory_decayed + new_good_received;

        % Receive goods and update inventories
        benefits = b2c_paiments + sum(b2b_paiments,2);
        costs = sum(b2b_paiments,1)' + import_paiments;
        gross_profits = (benefits - costs);
           
        % Store output variable
        profits_ts(t, :) = gross_profits;
        
    end

end