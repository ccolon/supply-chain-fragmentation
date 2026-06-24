function vec_neighboors = identifyNeighboors(current_firm_updating, rank_neighboors, client_or_supplier, connectivity_matrix, n)
    
    vec_current_firm = zeros(1,n);
    vec_current_firm(current_firm_updating) = 1;
    
    vec_neighboors = vec_current_firm;
    i=1;

    while i<=rank_neighboors
        
        suppliers = (connectivity_matrix^i * vec_current_firm')';
        customers = vec_current_firm * connectivity_matrix^i;
        
        switch client_or_supplier
            case 'client'    
                vec_neighboors = customers | vec_neighboors;
            case 'supplier'
                vec_neighboors = suppliers | vec_neighboors;
            otherwise
                vec_neighboors = suppliers | customers | vec_neighboors;
        end
        i=i+1;
        
    end
    
end