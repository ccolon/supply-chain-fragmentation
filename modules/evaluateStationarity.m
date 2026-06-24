function is_stationary = evaluateStationarity(my_last_overorder, stationary_threshold, convergence_window)

    coefs = polyfit((1:convergence_window)', my_last_overorder,1);
    coef_var = coefs(1);
    
    if abs(coef_var) <= stationary_threshold
        is_stationary = 1;
        %disp(coef_var);
    else
        is_stationary = 0;
    end
    
end