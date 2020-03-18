# Facial-landmark-tracking-by-ICBL 
The Matlab codes for facial landmark tracking on the 300-VW dataset. 
The Incremental Cascade Broad Learning framework has been uploaded. Please download the model and results published in the original paper from: https://pan.baidu.com/s/1WFVSeOd-3VL6kmgRsMvDDQ, the extraction code is: kk35.
The downloaded models contain offline-models(w300_DataVariation_offline.mat,w300BLS_regressors_offline.mat,w300LearnedDistribution_offline.mat) and frame-judge classifier. Unrar them to the right file paths for running the testing codes or training the new model with new parameters.
Please run the TestOnlineModel.m file and set the ralated file paths you like.
In these codes, the face boxs(bounding boxes) are released by the dataset or can be obtained by using the DLIB library. 
Copyright : These Matlab code for the paper "An Incrementally Cascaded Broad Learning Framework to Facial Landmark Tracking", which will be published soon. The code is released as is for the research purposes only. Please contact me if you use the code.
