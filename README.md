# Davis_DSP-Voice_Recognition

Authors: Trevor Vidano, Tanuj Kalakuntla

## Background
This repository is a MATLAB implementation of a speaker classification class. It classifies speakers based on the commonly used 
Digital Signal Processing technique of Mel-Frequency Cepstrum Coefficient (MFCC) extraction. It uses an implimentation of the LBG
vector quantization algorithm to cluster these coefficients to build speaker models. To classify speakers, samples are passed
to the classifier and new MFCCs are compared to the speaker model.

## Repository Organization
This repository is based on a MATLAB project labelled `voice_recognition`. The project contains two files to be executed in MATLAB:
1. `main.m` is the script that creates instances of the `speakerClassifier` class, trains, and tests those instances.
2. `human_benchmark.mlx` is a a live script that is used to collect data on a human's ability to classify speakers.

## Contributions
At this time no contributors are encouraged to continue this project. This repository is mainly for demonstrative purposes
and to satisfy the final project requirement in UC Davis' EEC 201: Digital Signal Processing course taught in Winter Quarter 2021.
