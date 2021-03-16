classdef speakerClassifier < handle
    %SPEAKERCLASSIFIER Speaker classifier using MFCCs and Clustering.
    %   Speaker classifier uses the following process to extract features,
    %   cluster them, and classify new audio samples of the same speakers:
    %       speakerAudio -> |Frame Blocking| -> |Windowing| -> |FFT|
    %           -> |Mel-Freq Wrapping| -> |DCT| -> features
    
    properties
        numClusters {mustBeNumeric}
        numFilters {mustBeNumeric}
        numCoeffs {mustBeNumeric}
        frameDuration {mustBeNumeric}
        strideDuration {mustBeNumeric}
        speakerModels
    end
    
    methods
        function obj = speakerClassifier(varargin)
            %SPEAKERCLASSIFIER Construct an instance of this class
            % 
            % Inputs:   numClusters     string, filepath to sound file
            %           numFilters      number of filters in the mel bank
            %           numCoeffs       number of MFCCs to use
            %           frameDuration   length of frame in ms
            %           strideDuration  ms to slide each frame forward
            %           numSpeakers     number of speakers to model
            %
            % Outputs:  obj             instance of object
            %
            % Usage:   
            if nargin == 5
                obj.numClusters = varargin{1};
                obj.numFilters = varargin{2};
                obj.numCoeffs = varargin{3};
                obj.frameDuration = varargin{4};
                obj.strideDuration = varargin{5};
                obj.speakerModels = [];
            elseif nargin == 3
                obj.numClusters = varargin{1};
                obj.numFilters = varargin{2};
                obj.numCoeffs = varargin{3};
                obj.frameDuration = 25; % ms
                obj.strideDuration = 10; % ms
                obj.speakerModels = [];
            elseif nargin == 0
                obj.numClusters = 8;
                obj.numFilters = 32;
                obj.numCoeffs = 12;
                obj.frameDuration = 25; % ms
                obj.strideDuration = 10; % ms
                obj.speakerModels = [];
            else
                error(['Incorrect number of input variables. Requires, '...
                       '5, 3, or no input variables.'])
            end            
        end
        
        function codeBooks = train(obj,speakerSamples)
            %TRAIN Generates codebooks for each speaker
            %
            % Inputs:   speakerSamples  cells containing speaker samples:
            %                           the first cell contains the audio 
            %                           data and sample freq. of the first 
            %                           speaker..
            %
            % Outputs:  codeBooks       vector of centroids of clustered
            %                           samples
            
            assert(iscell(speakerSamples),['speakerSamples variable is,'...
                                           'not type cell.'])
            assert(obj.numFilters > obj.numCoeffs,['Invalid input',...
                ', must at least 2 more filters than MFCCs.'])
            numSpeakers = length(speakerSamples);
            obj.speakerModels = cell(numSpeakers,1);
            for i = 1:numSpeakers
                x = speakerSamples{i}{1};
                fs = speakerSamples{i}{2};
                MFCCs = speechpreprocess(x,fs,obj.numFilters,...
                            obj.frameDuration,obj.strideDuration,false);
%                 [~,C,~] = kmeans(MFCCs(2:obj.numCoeffs+1,:)',...
%                                  obj.numClusters,'Replicates',20,...
%                                  'MaxIter',80);
%                 obj.speakerModels{i} = C;
                obj.speakerModels{i} = lbgClustering(MFCCs(2:obj.numCoeffs+1,:)',obj.numClusters,.01);
            end
            codeBooks = obj.speakerModels;
        end
        
        function [speakers] = classify(obj,testSamples)
            %CLASSIFY classifies new speaker samples based on trained
            % classifier. 
            %
            % Inputs:   testSamples     cells containing test samples
            %
            % Outputs:  speakers        speakers identified using indexes
            %                           of the trained codeBooks.
            
            numTest = length(testSamples);
            speakers = zeros(numTest,1);
            numSpeakers = length(obj.speakerModels);
            for i = 1:numTest
                x = testSamples{i}{1};
                fs = testSamples{i}{2};
                MFCCs = speechpreprocess(x,fs,obj.numFilters,...
                            obj.frameDuration,obj.strideDuration,false);
                MFCCs = MFCCs(2:obj.numCoeffs+1,:);
                
                lowestDist = inf;
                iLowest = 0;
                for j = 1:numSpeakers
                    codeBook = obj.speakerModels{j};
                    [nearCentrDist,~] = pdist2(codeBook,MFCCs',...
                                               'euclidean','Smallest',1);
                    dist = mean(nearCentrDist);
                    if dist < lowestDist
                        lowestDist = dist;
                        iLowest = j;
                    end
                end
                speakers(i) = iLowest;
            end
        end
        
        function status = test(obj,speakerSamples)
            %TEST outputs functional test data as outlined in project
            %guidlines.
            %
            % Inputs:   speakerSamples
            %           numFilters
            %           frameDuration
            %           strideDuration
            %           numClusters
            %
            % Outputs:  status      indicates completion status of function
            
            % Use the first two speaker samples..
            numSpeakers = length(speakerSamples);
            obj.speakerModels = cell(numSpeakers,1);
            x = speakerSamples{1}{1};
            fs = speakerSamples{1}{2};
            MFCCs = speechpreprocess(x,fs,obj.numFilters,...
                obj.frameDuration,obj.strideDuration,true);
            
            % Cluster Speaker 1
            [~,C,~] = kmeans(MFCCs(2:end,:)',obj.numClusters,...
                'Replicates',20,'MaxIter',80);
            
            % Cluster Speaker 2
            x2 = speakerSamples{2}{1};
            fs2 = speakerSamples{2}{2};
            MFCC2 = speechpreprocess(x2,fs2,obj.numFilters,...
                            obj.frameDuration,obj.strideDuration,false);
            [~,C2,~] = kmeans(MFCC2(2:end,:)',obj.numClusters,...
                'Replicates',20,'MaxIter',80);
            
            % Plot MFCC-2 vs. MFCC-3
            figure; hold on;
            scatter(MFCCs(2,:),MFCCs(3,:))
            scatter(MFCC2(2,:),MFCC2(3,:))
            hold off;
            title('Test5')
            
            % Plot MFCC-2 vs. MFCC-3 with Centroids
            figure; hold on;
            scatter(C(2,:),C(3,:))
            scatter(C2(2,:),C2(3,:))
            hold off;
            title('Test6')
                        
            status =1;
        end
            
    end
end

