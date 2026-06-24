%% Take a network, the list of the groups of two, and merge two groups randomly
% Remarque: at the end, the group vector does not generally have a continuous set of integer group nbs

function groups = mergeTwoGroups(groups, connectivity_matrix, n)
    % store index as we will reuse it often
    index=1:n;
    
    % check nb of groups
    id_groups = unique(groups);
    nb_of_groups = length(id_groups);
    
    % we will run the module only if there are more than 1 group
    if (nb_of_groups >= 2)
        
        % we will run it until there is a merge that occur
        merge_occurred = 0;
        
        while merge_occurred == 0
    
            % randomly select one group
            rdm_group_nb = id_groups(randi(nb_of_groups,1,1));

            % see who is in the group
            ids_in_selected_group = index(groups == rdm_group_nb);

            % collect all first tier neighboors (including the one in the group)
            all_ids_neighboors = ids_in_selected_group;
            for i=1:length(ids_in_selected_group)
               current_firm = ids_in_selected_group(i);
               bool_neighboors = identifyNeighboors(current_firm, 1, 'both', connectivity_matrix, n);
               all_ids_neighboors = [all_ids_neighboors index(bool_neighboors)];
            end

            % find which groups they belong to, simplify, and remove the selected group
            potential_partner_groups = groups(all_ids_neighboors);
            potential_partner_groups = unique(potential_partner_groups);
            potential_partner_groups = potential_partner_groups(potential_partner_groups ~= rdm_group_nb);

            % if this is a non empty set, randomly pick up a potential partner and merge the two groups
            if ~isempty(potential_partner_groups)
                candidate_group = potential_partner_groups(randi(length(potential_partner_groups),1,1));
                groups(groups == candidate_group) = rdm_group_nb;
                merge_occurred = 1;
            end
            
            
        
        end
    
    end

end
