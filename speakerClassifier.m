classdef speakerClassifier
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
            elseif nargin == 3
                obj.numClusters = varargin{1};
                obj.numFilters = varargin{2};
                obj.numCoeffs = varargin{3};
                obj.frameDuration = 25; % ms
                obj.strideDuration = 10; % ms
            elseif nargin == 0
                obj.numClusters = 8;
                obj.numFilters = 32;
                obj.numCoeffs = 12;
                obj.frameDuration = 25; % ms
                obj.strideDuration = 10; % ms
            end
        end
        
        function codeBooks = train(obj,speakerSamples)
            %TRAIN Generates codebooks for each speaker
            %
            % Inputs:   speakerSamples  1D cells containing a sample of 
            %                           each speaker
            % 
            % Outputs:  codeBooks       vector of centroids of clustered
            %                           samples
            
            assert(iscell(speakerSamples),['speakerSamples variable is,'...
                                           'not type cell.'])
            numTrain = length(speakerSamples);
            codeBooks = cell(numTrain,1);
            for i = 1:numTrain
                filename = 's' + string(i) + '.wav';
                path = fullfile(TrainDir,filename);
                MFCCs = speechpreprocess(path,numFilters,frameDuration,...
                                         strideDuration,false);
                [idx,C,sumd] = kmeans(MFCCs(2:numMFCCs+1,:)',numClusters,...
                                      'Replicates',20,'MaxIter',80);
                codeBooks{i} = C;
            end
        end
    end
end

