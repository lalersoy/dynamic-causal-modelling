# dynamic-causal-modelling

# Introduction
This repository contains code for performing Dynamic Causal Modeling (DCM) on fMRI data, focusing on four regions in the frontal gyrus: the left and right dorsal frontal gyri (ldF, rdF) and the left and right ventral frontal gyri (lvF, rvF). The analysis aims to test the hypothesis that words and pictures modulate the connectivity between these regions, particularly the connection from ldF to rdF, with a greater effect of pictures compared to words.

# Hypothesis
Words and pictures modulate the connection from ldF to rdF, with the influence from lvF to ldF and rvF to rdF.
The information flow from ldF to rdF will be decreased in the words condition compared to the pictures condition.
Previous Findings
PPI results show that both pictures and words modulate the connectivity between the ventral and dorsal frontal gyri in both hemispheres.
Following findings from Seghier et al. (2011), intra-hemispheric modulations were observed on feedback connections from the ventral to dorsal frontal regions for both types of stimuli.
Models Tested
Two DCM models were built to test the hypothesis.

# Model 1: 
Intra-hemispheric feedback connections from lvF to ldF and rvF to rdF, modulated by pictures and words.
# Model 2: 
Same as Model 1, but with an additional inter-hemispheric connection from ldF to rdF, modulated by both pictures and words.

# Methods
Parameter Matrices
Matrix A (Effective Connectivity): Represents the average rate of change in neural response. All bidirectional connections were switched on, except for heterotopic connections.
Matrix C (Driving Input): All dorsal regions (ldF and rdF) were enabled to receive the input.
Modulatory Effects:
Model 1: Modulation of connections within each hemisphere (from lvF to ldF, rvF to rdF) by pictures and words.
Model 2: Same as Model 1 but includes an additional inter-hemispheric modulation from ldF to rdF.
DCM Specification
Time-series data for the regions of interest (ROIs) were loaded for each subject.
Two DCMs were specified and estimated for each subject at the single subject level. The estimated parameters were stored separately for each subject in a Group DCM (GCM) file for subsequent second-level DCM analysis.

# Results
Model Comparison
The comparison of the two models was done on a randomly selected subject (Subject 28).
Fixed-effects Bayesian Model Selection (BMS: FFX) was performed using Negative Free Energy (F) values to assess the model fit.
Model 2 was found to have greater log-evidence and posterior probability, suggesting a better fit to the data.
Connectivity Analysis for Subject 28
The connectivity from ldF to rdF was significantly modulated by both pictures and words.
The normally inhibitory connection from ldF to rdF (-0.3811 Hz) was disinhibited by both pictures (+1.784 Hz) and words (+0.32 Hz).
Word modulation was 89% probable but not statistically significant.
Picture modulation was significant (p > 0.95), indicating a clear effect.
Connection from lvF to ldF was positively modulated by both pictures (+1.9 Hz) and words (+1.26 Hz), with pictures showing a stronger effect.
The rvF to rdF connection was significantly modulated only by words (+1.35 Hz).

# Conclusion
Picture modulation was found to significantly affect the connection from ldF to rdF, while word modulation showed only semi-evidence and was not significant.
The analysis provides evidence for the hypothesis that pictures modulate the connectivity from ldF to rdF more significantly than words.
