function x = ad2mv( x, gains )

VRange = 10;
NLevels = 2048;

x = 1e3 .* bsxfun( @rdivide, VRange.*double(x)./NLevels, double(gains) );