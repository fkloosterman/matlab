function x = mv2ad( x, gains )

VRange = 10;
NLevels = 2048;

x = bsxfun( @times, x .* 1e-3, gains ).*NLevels./VRange;