clear,clc
% % Vacuum permittivity
% phys_const.epsilon0 = 8.8542;
% % relative permittivity
% phys_const.epsilonr = 80;
% % Boltzmann constant
% phys_const.kb = 1.3806;
% % elementary positive charge
% phys_const.e = 1.6;
% % avogadro constant
% phys_const.Na = 6.023;
% % num of particles
% phys_cond.numParticles = 1500;
% % temperature of experiment
% phys_cond.T = 323;
% % length of the box
% % phys_cond.L = 43088;
% % radius of particle
% phys_cond.R = 7.5;
% % average electric charge
% phys_cond.averagee = 300;
% % photon wave length created by ATP
% phys_cond.wavelambda = 7000; 
phys_cond = readstruct("phys_cond.xml");
phys_const = readstruct("phys_const.xml");

% numbers of bins
Ng = 10000;
diff_phase = zeros(size(20:200,2),1);
g = zeros(Ng,size(20:1500,2));

parfor D = 25:58
    % D = 100;
    distances  = D*100;
    [cdInit,charge,L] = Init_D(distances,phys_cond,phys_const); % 'D' indicates distances corresponding to the concentration
    for i = 1:5e5
        %{
            distance_step stands for distance per Monte_Carlo step.
            For the sake of simulation speed, step value's supposed to be
            large. Default setting is 0.1 times half of the length of box.
        %}
        distance_step = L * 0.1;
        [cdMoved] = monte_carlo(phys_cond,phys_const,ceil(phys_cond.numParticles * rand),cdInit,charge,distance_step,L);
        cdInit = cdMoved;
    end

    % fig = figure;
    for i = 1:3e6
        %{
            distance_step stands for distance per Monte_Carlo step.
            Now start moving to the equilibrium position in smaller steps. 
            Default setting is 0.05 times half of the length of box.
        %}
        distance_step = L * 0.05;
        [cdMoved] = monte_carlo(phys_cond,phys_const,ceil(phys_cond.numParticles * rand),cdInit,charge,distance_step,L);
        cdInit = cdMoved;
        % if rem(i,1000) == 0
        %     plot3Dspheres(cdInit,numParticle,phys_cond)
        %     hold off
        %     frame = getframe(fig);
        % end
    end
    % close;
    %%

    for i = 1:1e6
        %{
            distance_step stands for distance per Monte_Carlo step.
            Now it's the thermal motion after equilibrium. 
            Default setting is 0.01 times half of the length of box.
        %}
        distance_step = L * 0.01;
        [cdMoved] = monte_carlo(phys_cond,phys_const,ceil(phys_cond.numParticles * rand),cdInit,charge,distance_step,L);
        if rem(i,10000) == 0
            % g(:,D-24) = g(:,D-24) + rdf(cdMoved, L, Ng, phys_cond.numParticles);
            % g(:,C-2) = rdf(cdMoved, phys_cond.L, Ng, numParticle);
            % diff_phase(D-24) = diff_phase(D-24) + calculate_phase(phys_cond,cdMoved,L);
            diff_phase(D-24) = diff_phase(D-24) + calculate_phase_simpler(phys_cond,cdMoved);
        end
        cdInit = cdMoved;
    end
    g(:,D-24) = g(:,D-24) / 100;
    diff_phase(D-24) = diff_phase(D-24) / 100;
    disp(D)
end
% plot((1:Ng)* 10000/Ng ,g) % !!!Caution: Value of rc in function 'rdf()' should be noted.
% save('results_D.mat');