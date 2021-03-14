function [codeBook] = lbjClustering(dataM, numCodes)
%LBJCLUSTERING Clustering algorithm based on LBJ Vector Quantizer.
%
% Inputs        dataM           matrix with data to be clustered
%               numCodes        number of codes in codeBook (centroids)           
% 
% Outputs       codeBook        a set of codes, or centers of clusters

assert(mod(log2(numCodes),1) == 0, 'numCodes must be power of 2.')

% Distortion measure
squareError = @(x1,x2) sum(abs(x1 - x2).^2);
holderNorm = @(x1,x2,v) (sum(abs(x1 - x2).^v)).^(1/v);

% Assume matrix has dims = # of rows, observations = # of columns..
[numDims, numObs] = size(dataM);

% Initial guess by splitting
perturbation = 0.01;
codeBook = rand(numDims,1);
while size(codeBook,1) < numCodes
    codeBookLeft = codeBook - perturbation;
    codeBookRight = codeBook + perturbation;
    codeBook = [codeBookLeft,codeBookRight];
end

% Implement clustering algorithm
epsilon = 0.001; % distortion threshold
Dm0 = inf;
dist = disteu(codeBook,dataM);
Dm1 = (1/numObs)*sum(min(dist,[],2));
while (Dm0 - Dm1)/Dm1 > epsilon
    Dm0 = Dm1;
    Dm1 = 
end

end

