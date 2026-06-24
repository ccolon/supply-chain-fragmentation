addpath(['modules/']);


%% SETUP
tic

n=10;
c=2;

% Experiment parameters
save_all_trajectories_on_off = 0
evol_prim_prod_on_off = 0

% Generate network
connectivity_matrix = zeros(n,n);
for i=1:(n-1)
    connectivity_matrix = connectivity_matrix + diag(rand(1,n-i),i);
end
in_degree = c;
threshold = n * in_degree / (n*(n-1)/2);
connectivity_matrix = (connectivity_matrix > (1-threshold));
primary_producers = sum(connectivity_matrix,1) == 0;
final_producers = (sum(connectivity_matrix,2) == 0)';

% Fragmentation parameters
target_nb_of_groups = 100
all_groups = generateManyGroups(target_nb_of_groups, connectivity_matrix, n);
selected_groups = 10
groups = all_groups(selected_groups,:)

% Add one final producers
connectivity_matrix = [connectivity_matrix zeros(n,1); zeros(1,n+1)];
connectivity_matrix(final_producers,n+1) = 1;
final_producers = (sum(connectivity_matrix,2) == 0)';
primary_producers = sum(connectivity_matrix,1) == 0;
n=n+1;

% Generate the parameters
original_productivity_all_firms = 2;
failure_rates_all_firms = 0.1;
decay_rate_all_firms = 0.5

[price, final_demand, original_productivity, decay_rate...
            , perturbation_regime, failure_rates, original_over_order_rate, outsiders] = setParameters(n, primary_producers, final_producers...
            , failure_rates_all_firms, original_productivity_all_firms, decay_rate_all_firms);

original_over_order_rate = ones(1,n);
minimum_overordering_rates = ones(1,n);
[eqs_reached, overorder_evoleq, ~] = reachEvolEq(n, connectivity_matrix, primary_producers...
            , price, final_demand, original_productivity, decay_rate...
            , perturbation_regime, failure_rates, original_over_order_rate, minimum_overordering_rates...
            , groups, evol_prim_prod_on_off, save_all_trajectories_on_off);

 toc