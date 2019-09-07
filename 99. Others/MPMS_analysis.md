# MPMS_analysis.ipf
Correct MPMS data from Pd reference data

## Process
1. Analyze magnetic moment data of Pd reference sample. It should be paramagnetic (=linear MH curve) and no hysteresis.
1. Correct measurement data. Magnetic field is constantly shifted, magnetic moment is constantly multiplied.

## Usage
```
analysis_Pd(prefix, folderName, mass, minRegFit)
```
- **prefix[input]** prefix of the input wave name. Wave namd of the magnetic moment data is **prefix+"moment"**, that of the magnetic field is **prefix+"field"**, that of the regfit is **prefix+"regfit"**. Magnetic field must be **first decreasing** and **second increasing**.
- **folderName[output]** folder name in which the result is stored. The folder is created in root.
- **mass[input]** weight of the sample[g]
- **minRegFit[input]** min value of regfit of accepted data. regfit is 1 when the fitting is perfect, so minRegFit should be set to around 0.9.

This function creates the following waves and global variables in the result folder:
- **Pd_field, Pd_moment** field, magnetic moment data regfit of which is larger than **minRegFit**.
- **Pd_field_decrease, Pd_moment_decrease** field decreasing part of **Pd_field, Pd_moment**, including the field turning point
- **Pd_field_increase, Pd_moment_increase** field increasing part of **Pd_field, Pd_moment**, including the field turning point
- **Pd_fit_increase** line fitting of MH decreasing part
- **Pd_fit_decrease** line fitting of MH increasing part
- **Pd_slope** line slope of MH graph, including both decreasing and increasing part
- **Pd_offset_decrease** M section of MH decreasing part (systematic error of magnetic field when decreasing)
- **Pd_offset_increase** M section of MH increasing part (systematic error of magnetic field when increasing)