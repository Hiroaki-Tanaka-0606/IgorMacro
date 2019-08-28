# Analysis_2goki.ipf
A combination of macros for analyzing ARPES data from 2goki@ISSP

## Analysis Process
1. Analyze the intensity spectrum of Au polycrystal by ```Au_2goki``` function. The function creates new folder **root:Au** and the result of the analysis is stored in the folder.
1. When analyzing 2D data, use ```correct2D_2goki``` function. It does the following procedure.
	1. Remove constant background by ```BackGroundFilter2D```
	1. Normalize the intensity of each slice by ```AuNormalize2D```
	1. Set the Fermi energy to zero by ```AuEfCorrect2D```
1. When analyzing 3D data, use ```correct3D_2goki``` function. It does the similar procedure to ```correct2D_2goki```.

## Usage
```
Au_2goki(inputWave, temp)
```
- **inputWave[input]** Wave name of the ARPES spectrum from Au polycrystal
- **temp[input]** Measurement temperature [K]

It creates the folder **root:Au**, and waves **Au**(copied from **inputWave**), **Au_bg**(constant background), **Au_ef**(Fermi energy), **Au_fwhm**(energy resolution in FWHM), **Au_intensity**(intensity spectrum) are created in the folder.

```
correct2D_2goki(inputWave, folder, suffix)
```
- **inputWave[input]** Wave name of the 2D ARPES data
- **folder[input]** Name of the folder in which the corrected data is stored
- **suffix[input]** Suffix of the corrected data name

Before using the function, **folder** must be created. It creates the corrected 2D ARPES data in **folder** and the name of the wave is **(folder name in which the inputWave is)**+**suffix**, because the folder name of the raw data, representing the measurement number, is more important than the name of the **inputWave**, representing the sequence name.

```
correct3D_2goki(inputWave, outputWave)
```
- **inputWave[input]** Wave name of the 3D ARPES data
- **outputWave[output]** Wave name of the corrected 3D ARPES data

See **AuNormalize.md** for the order of the indices of **inputWave**.