function [eq_reached, do_we_stop] = evaluateStopConditions2(nb_updating_firms, evolloop, convergence_window, max_evolloops)

    eq_reached = 0;
    do_we_stop = 0;
        
    if evolloop >= convergence_window
        
        if evolloop > max_evolloops
            
            do_we_stop = 1;
            
        else
            
            if nb_updating_firms == 0
                
                do_we_stop = 1;
                eq_reached = 1;

            end
            
        end
        
    end

end
