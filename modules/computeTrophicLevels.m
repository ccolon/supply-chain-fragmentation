function trophic_levels = computeTrophicLevels(connectivity_matrix, primary_producers, n)

    index = 1:n;
    primary_producer_ids = index(primary_producers);

    nb_path_length_k = zeros(n,n);
    for k=1:n
        power_matrix = connectivity_matrix^k;
        nb_path_length_k(k,:) = sum(power_matrix(primary_producer_ids,:),1);
    end
    
    path_length = 1:n;
    total_nb_paths = sum(nb_path_length_k,1);
    trophic_levels = 1 + sum((path_length' * ones(1,n)) .* nb_path_length_k) ./ (total_nb_paths + primary_producers);

end