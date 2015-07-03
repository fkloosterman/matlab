function r = circ_uniformize( population, sample )
%CIRC_UNIFORMIZE transform sample assuming the population is uniform
%
%  u=CIRC_UNIFORMIZE(population) returns the circular rank of the angles
%  in population.
%
%  u=CIRC_UNIFORMIZE(population, sample) return the angles in sample
%  after transformation acoording to the estimated cdf of the angles in
%  population (i.e. the population distribution made uniform). Sample can
%  be a vector or a cell array of vectors.
%
%  u=CIRC_UNIFORMIZE(cdf_fcn, sample) takes a function that computes the
%  cdf of a certain distribution at given angles and will transform the
%  angles in sample according to this cdf.
%


%  Copyright 2005-2008 Fabian Kloosterman

%check input arguments
if nargin<1
    help(mfilename)
    return
end

%is the population a function handle?
if isa( population, 'function_handle' )

    if nargin<2
        help(mfilename)
        return
    end
    
    %uniformize
    if ~iscell(sample)
        r = 2*pi.*population( sample );
    else
        r = {};
        for k=1:numel(sample)
            r{k} = 2*pi*population( sample{k} );
        end
    end
    
else
    
    population = limit2pi( population );
    poprank = circ_rank( population );

    [population, bi] = unique(population);
    poprank = poprank(bi);
    
    if nargin<2
        r = poprank;
        return
    end
    
    %uniformize
    if ~iscell(sample)
        sample = limit2pi( sample );
        r = interp1( population, poprank, sample, 'linear' );
    else
        r = {};
        for k=1:numel(sample)
            r{k} = interp1( population, poprank, sample{k}, 'linear' );
        end
    end
    
end
