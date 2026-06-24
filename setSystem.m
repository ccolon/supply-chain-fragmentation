%% Set system

function [connectivity_matrix, primary_producers, final_producers] = setSystem(graph_type, n, in_degree)
   
    % Automatically generated parameters
    % Connectivity matrix
    switch graph_type
        
        case 'ER_random'
            connectivity_matrix = zeros(n,n);
            % create a directed random graph based on the number of links, with at least 1 in-link for each node
            % Aij is a link from i to j.
            nb_links = in_degree * n; % should be more than N
            % choose initial suppliers
            for k=1:n
               potential_suppliers = setdiff(1:n,k);
               i=potential_suppliers(randi(numel(potential_suppliers)));
               connectivity_matrix((k-1)*n + i) = 1;
            end
            % add randomly new suppliers until we reach the desired connectivity
            while sum(sum(connectivity_matrix)) < nb_links
                i=randi(n); j=randi(n);
                if i==j || connectivity_matrix(i,j)>0; continue; end  % do not allow self-loops or double edges
                connectivity_matrix(i,j)=1;
            end
            
        case 'random_fixed_indeg'
            connectivity_matrix = zeros(n,n);
            % For each firm, add 'in_degree' number of suppliers
            for k=1:n
               potential_suppliers = setdiff(1:n,k);
               i=potential_suppliers(randperm(numel(potential_suppliers),in_degree));
               connectivity_matrix((k-1)*n + i) = 1;
            end
            
        case 'directional_av_indeg'
            connectivity_matrix = zeros(n,n);
            for i=1:(n-1)
                connectivity_matrix = connectivity_matrix + diag(rand(1,n-i),i);
            end
            threshold = n * in_degree / (n*(n-1)/2);
            connectivity_matrix = (connectivity_matrix > (1-threshold));
            
        case 'directional_fixed_indeg'
            connectivity_matrix = zeros(n,n);
            for i=(in_degree+1):n % the 'in_degree' first firms are primary producers
                suppliers = randsample(i-1,in_degree);
                connectivity_matrix(suppliers,i) = 1;
            end
  
        case 'linear'
            connectivity_matrix = diag(ones(1, n - 1), 1);
            
        case 'directed_lattice'
            nb_layers = 30;
            nb_nodes_per_layer = 2;
%             nb_nodes_per_layer = in_degree;
            connectivity_matrix = buildDirectedLattice(nb_layers, nb_nodes_per_layer);
            n = nb_layers * nb_nodes_per_layer;
            
        case 'layered_not_fully_connected'
            nb_layers = 10;
            nb_nodes_per_layer = 3;
            n = nb_layers * nb_nodes_per_layer;
            connectivity_matrix = buildDirectedLattice(nb_layers, nb_nodes_per_layer);
            while (sum(sum(connectivity_matrix))/n > in_degree_input)
                remaining_links = find((connectivity_matrix==1) & ((ones(n,1)*sum(connectivity_matrix))>1)); %conditions is that there should be at least two suppliers
                the_one_to_delete = remaining_links(randi(length(remaining_links),1));
                connectivity_matrix(the_one_to_delete)=0;
            end
            
            case 'layered_not_fully_connected_with_forward_links'
            nb_layers = 10;
            nb_nodes_per_layer = 3;
            n = nb_layers * nb_nodes_per_layer;
            connectivity_matrix = buildDirectedLattice(nb_layers, nb_nodes_per_layer);
            while (sum(sum(connectivity_matrix))/n > in_degree_input*0.9)
                remaining_links = find((connectivity_matrix==1) & ((ones(n,1)*sum(connectivity_matrix))>1)); %conditions is that there should be at least two suppliers
                the_one_to_delete = remaining_links(randi(length(remaining_links),1));
                connectivity_matrix(the_one_to_delete)=0;
            end
            while (sum(sum(connectivity_matrix))/n < in_degree_input)
                connectivity_matrix(randi(n,1), randi(n,1)) = 1;
                connectivity_matrix = triu(connectivity_matrix); % ensure that it is not a backward loop
            end
            
        otherwise
            error('Wrong matrix type selected');
            
    end
    
    % Identification of primary producers
    primary_producers = sum(connectivity_matrix,1) == 0;
    final_producers = (sum(connectivity_matrix,2) == 0)';
        
end
