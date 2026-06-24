% Compute the production levels that satisfy the final demand, and deduce the inventories and orders

function [production_targets, initial_inventories, fixed_order_flows, fixed_import_flows] = setFixedOrdersProdTargets(order_rate, connectivity_matrix, original_productivity, final_demand, primary_producers, n)
    
    % We use the classical I/O balance relationship
    % For that we compute the weighted input output matrix (we add primary_producers just to avoid / 0, no influence)
    weighted_connectivity_matrix = connectivity_matrix ./ (ones(n,1) * (sum(connectivity_matrix,1) + primary_producers));
    weighted_connectivity_matrix_with_overordering = (ones(n,1) * (order_rate ./ original_productivity)) .* (weighted_connectivity_matrix);

    % Compute production targets, inventories and orders
    production_targets = (eye(n) - weighted_connectivity_matrix_with_overordering) \ final_demand;
    initial_inventories = production_targets .* (1 ./ original_productivity)';
    fixed_order_flows = (ones(n,1) * (production_targets .* (order_rate ./ original_productivity)')') .* weighted_connectivity_matrix;
    fixed_import_flows = (production_targets .* primary_producers') .* (order_rate ./ original_productivity)';
    
end
