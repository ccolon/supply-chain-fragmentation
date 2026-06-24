%% This function is the most up to date, using the latest functions and with storability

function [eqs_reached, overorder_evoleq, all_trajectories] = reachEvolEq(n, connectivity_matrix, primary_producers...
            , price, final_demand, original_productivity, decay_rate...
            , perturbation_regime, failure_rates, original_over_order_rate, minimum_overordering_rates...
            , groups, evol_prim_prod_on_off, save_all_trajectories_on_off)


    % Set evolutionary parameters
    evolutionary_period = 100; %100
    trait_exploration_step = 0.05; %0.05
    h = 1;
    max_step = 0.03;%0.02
    % Set parameters to test the stationary conditions
    convergence_window = 30;%20
    if (mean(failure_rates) > 1 - 1/mean(original_productivity))
      convergence_window = 5;
    end
    max_evolloops = 500;%1000
    stationary_threshold = 1e-4;%1e-4

    % Initate results data structure
    if save_all_trajectories_on_off == 1
        all_trajectories = zeros(max_evolloops, n);
    else
        all_trajectories = 0;
    end

    % Set state variable on evolutionary loops
    overorder_last_evolloops = zeros(convergence_window, n);
    overorder_last_evolloops(end,:) = original_over_order_rate;

    % Loop over evolutionary loops, until a stop condition is met
    firm_index = 1:n;
    if evol_prim_prod_on_off
        firms_updating = firm_index;
    else
        firms_updating = firm_index(~primary_producers);
    end
    nb_updating_firms = length(firms_updating);
    evolloop = 0;
    do_we_stop = 0;

    while do_we_stop ~= 1

        evolloop = evolloop + 1;
        overorder_last_evolloops = circshift(overorder_last_evolloops,-1); %we shift backward the vectors of the last 'conv_window' overordering rates, thus sorting the last updated rates in row end-1
        overorder_last_evolloops(end,:) = overorder_last_evolloops(end-1,:); % and duplicate these last values, so that it will serve as the starting value in the current loop

        firms_that_stop = zeros(1,nb_updating_firms);

        % Loop over firms, i.e. over update steps (updts)
        updating_order = firms_updating(randperm(nb_updating_firms));

        for updts = 1:nb_updating_firms

            % Select the firm that will evolve and setup its trials
            current_firm_updating = updating_order(updts);
            %current_firm_updating = firms_updating(randi(nb_updating_firms,1));
            current_overorder_rates = overorder_last_evolloops(end, :);

            % Explore
            [overorderrate_tried, all_profits_tried] = tryBehaviorNew(current_firm_updating, current_overorder_rates...
                , trait_exploration_step, evolutionary_period, minimum_overordering_rates ...
                , decay_rate, perturbation_regime, failure_rates, connectivity_matrix, original_productivity, price, final_demand, primary_producers, n);

            % Analyse the data and choose
            [updated_trait, ~] = makeDecisionNew(overorderrate_tried, all_profits_tried, current_firm_updating, minimum_overordering_rates, groups, h, max_step);
 
            % Update the overorder rates of the current evolutionary loop
            overorder_last_evolloops(end, current_firm_updating) = updated_trait;

            % Test whether this firm has reached a stationary point
            my_last_overorder = overorder_last_evolloops(:, current_firm_updating);
            is_stationary = evaluateStationarity(my_last_overorder, stationary_threshold, convergence_window);

            % if it is the case, then we keep the mean value of the overordering over the convergence window
            if is_stationary == 1
                firms_that_stop(updts) = is_stationary;
                overorder_last_evolloops(end, current_firm_updating) = mean(my_last_overorder);
            end

        end

        if save_all_trajectories_on_off
            all_trajectories(evolloop,:) = overorder_last_evolloops(end, :);
        end

        firms_updating = updating_order(firms_that_stop == 0);
        nb_updating_firms = length(firms_updating);

        [eq_reached, do_we_stop] = evaluateStopConditions2(nb_updating_firms, evolloop, convergence_window, max_evolloops);

    end
    

    % Store results
    eqs_reached = eq_reached;
    overorder_evoleq = mean(overorder_last_evolloops);

    
end
