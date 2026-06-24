function [updated_trait, derivative] = makeDecisionNew(overorderrate_tried, all_profits_tried, current_firm_updating, minimum_overordering_rates, groups, h, max_step)

    % We determine the quantity to optimize, based on the groups
    group_of_current_firm = groups(current_firm_updating);
    quantity_to_maximize = all_profits_tried * (groups == group_of_current_firm)';
    
    % If the current_trait is one, then there was no first trial, and there is only two points on the curve
    % We simply fit a straight line
    current_trait = overorderrate_tried(3); % We retrieve the current trait, it is simply the last trait tried, as arbitraty chosen
    minimum_trait_value = minimum_overordering_rates(current_firm_updating);
    Y = quantity_to_maximize;
    X = overorderrate_tried;
        
    % If it was close the minimum values, it did only two trials
    EPSILON = 1e-4;
    if (current_trait <= minimum_trait_value+EPSILON)
        derivative = (Y(3) - Y(2)) / (X(3) - X(2));
    else
%          coefs = polyfit(X, Y, 2);
%          a1 = coefs(2);
%          a2 = coefs(1);
        [~, a1, a2] = quadraticFit(Y, X);
        derivative = 2 * a2 * current_trait + a1;
    end
    
    % We update the trait correspondingly
    evol_step = max(-max_step, min(max_step, h * derivative));
    
    updated_trait = max(minimum_trait_value, current_trait + evol_step);
%     updated_trait = max(0, current_trait + evol_step);
%     
%      [~, choice] = max(quantity_to_maximize);
%      updated_trait = overorderrate_tried(choice);

end