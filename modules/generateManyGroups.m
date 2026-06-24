%% Function to generate many groups

function all_groups = generateManyGroups(target_nb, connectivity_matrix, n)
    
    all_groups = zeros(target_nb, n);
    current_nb = 0;
    
    % generate the first group
    groups = 1:n;
    all_groups(1,:) = groups;
    current_nb = 1;
    
    % we do the same routine until all_groups is filled
    while current_nb < target_nb
        % we start with no groups
        groups = 1:n;
        % and create them one by one, and stop if all_gruops is filed
        while length(unique(groups)) >= 2 && current_nb < target_nb;
           groups = mergeTwoGroups(groups, connectivity_matrix, n);
           % check that this is a new setting, if so, we add it to the new groups
           is_new = sum(sum(all_groups == (ones(1,target_nb)' * groups), 2) == n) < 1; % actually this is just a simple assessment, not cover all case, more needed
           if is_new
               all_groups(current_nb+1, :) = groups;
               current_nb = current_nb + 1;
           end
        end
    end

end