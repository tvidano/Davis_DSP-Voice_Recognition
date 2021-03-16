function [codeBook] = lbgClustering(dataM, numCodes, epsilon)
%LBGCLUSTERING Clustering algorithm based on LBG Vector Quantizer.
%
% Inputs        dataM           matrix with data to be clustered
%               numCodes        number of codes in codeBook (centroids)
%               epsilon         convergence threshold
% 
% Outputs       codeBook        a set of codes, or centers of clusters

% Enforce input types
assert(mod(log2(numCodes),1)==0,['Invalid value, numCodes should be a ',...
    'power of 2.'])

% initial guess of codeBook
codeBook = mean(dataM,1);
avgDist = mean(disteu(codeBook',dataM'));
bookLen = size(codeBook,1);
while bookLen < numCodes
    % Split codeBook into two..
    codeBookLeft = codeBook - codeBook*epsilon;
    codeBookRight = codeBook + codeBook*epsilon;
    codeBook = [codeBookLeft;codeBookRight];
    bookLen = size(codeBook,1);
    % Find closest input vectors to each code..
    iter = 0;
    err = 1 + epsilon;
    newDist = avgDist;
    while err > epsilon
        prevDist = newDist;
        iter = iter + 1;
        [dist, iClosest] = pdist2(codeBook,dataM,'euclidean','Smallest',1);
        avgDist = mean(dist);
        for iCode = 1:bookLen
            partM = dataM(iClosest==iCode,:);
            % Calculate new codes to minimize distance..
            codeBook(iCode,:) = mean(partM,1);
        end
        [newDist,~] = pdist2(codeBook,dataM,'euclidean','Smallest',1);
        newDist = mean(newDist);
        err = (prevDist - newDist)/prevDist;
        if iter > 100
            break
        end
    end
end

end

