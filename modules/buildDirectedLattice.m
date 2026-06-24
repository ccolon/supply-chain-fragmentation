function connectivity_matrix = buildDirectedLattice(nb_layers, nb_nodes_per_layer)
   
    % Build the sector matrix
    sector_connectivity_matrix = diag(ones(1, nb_layers - 1), 1);

    % Build the connectivity matrix from the sector matrix using cell
    s = size(sector_connectivity_matrix,1);
    connectivity_cell = cell(s);
    
    for i=1:s
        for j=1:s
           if sector_connectivity_matrix(i,j) == 0
               connectivity_cell{i,j} = zeros(nb_nodes_per_layer);
           else
               connectivity_cell{i,j} = ones(nb_nodes_per_layer);
           end
        end
    end
    
    connectivity_matrix = cell2mat(connectivity_cell);
    
end