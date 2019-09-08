# MPMS_analysis.ipf
Correct MPMS data from Pd reference data

## Process
1. Analyze magnetic moment data of Pd reference sample by ```analysis_Pd``` function. It should be paramagnetic (=linear MH curve) and no hysteresis.
1. Correct measurement data by ```correctMPMS``` function. Magnetic field is constantly shifted, magnetic moment is constantly multiplied.

## Usage
```
analysis_Pd(prefix, folderName, mass, minRegFit, turning_point)
```
- **prefix[input]** prefix of the input wave name. Wave namd of the magnetic moment data is **prefix+"moment"**, that of the magnetic field is **prefix+"field"**, that of the regfit is **prefix+"regfit"**. Magnetic field must be **first decreasing** and **second increasing**.
- **folderName[output]** folder name in which the result is stored. The folder is created in root.
- **mass[input]** weight of the sample[g]
- **minRegFit[input]** min value of regfit of accepted data. regfit is 1 when the fitting is perfect, so minRegFit should be set to around 0.9.
- **turning_point[input]** flag by which where the turning point is stored is determined. When **turning_point&ge;0**, decrease part includes the turning point, and when **turning_point&le;0**, increase part includes the turning point. It means that when **turning_point=0** both increase part and decrease part include the turning point.

This function creates the following waves and global variables in the result folder:
- **Pd_moment_emumol** converted moment data [emu/mol] by ```emu_emumol``` function.
- **Pd_field, Pd_moment** field [Oe], magnetic moment data [emu/mol] regfit of which is larger than **minRegFit** .
- **Pd_field_decrease, Pd_moment_decrease** field decreasing part of **Pd_field, Pd_moment**, including the field turning point
- **Pd_field_increase, Pd_moment_increase** field increasing part of **Pd_field, Pd_moment**, including the field turning point
- **Pd_fit_increase** line fitting of MH decreasing part
- **Pd_fit_decrease** line fitting of MH increasing part
- **Pd_slope** line slope of MH graph, including both decreasing and increasing part
- **Pd_offset_decrease** M section of MH decreasing part (systematic error of magnetic field when decreasing)
- **Pd_offset_increase** M section of MH increasing part (systematic error of magnetic field when increasing)

```
correctMPMS(input_prefix, folderName, turning_point, output_prefix)
```
- **input_prefix[input]** prefix of the input wave name. Wave name of the magnetic moment data is **prefix+"moment"**, that of the magnetic field is **prefix+"field"**. Magnetic field must be **first decreasing** and **second increasing**.
- **folderName[input]** name of the folder in which Pd reference data is. Variables **Pd_slope**, **Pd_offset_decrease**, **Pd_offset_increase**, are used in correction process.
- **turning_point[input]** flag by which where the turning point is stored is determined. Rules are the same as ```analysis_Pd``` function.
- **output_prefix[output]** prefix of the output wave name. Wave name of corrected magnetic moment data is **prefix+"moment_increase"** and **prefix+"moment_decrease"**, and that of corrected magnetic field data is **prefix+"field_increase"** and **prefix+"field_decrease"**.

In correction process, magnetic moment is multiplied by **&chi;<sub>Pd</sub>/Pd_slope**, where **&chi;<sub>Pd</sub>** is exact susceptibility of Pd. From http://www.fizika.si/magnetism/MagSusceptibilities.pdf , **&chi;<sub>Pd</sub>**=540&times;10<sup>-6</sup> [cm<sup>3</sup>/mol]. Magnetic field is shifted by **Pd_offset_decrease** or **Pd_offset_increase**.