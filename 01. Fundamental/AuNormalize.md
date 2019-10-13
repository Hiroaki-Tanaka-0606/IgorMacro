# AuNormalize.ipf
Normalize the ARPES data using the ARPES spectrum of Au polycrystal

## Normalization Process
1. Using ```AuAnalyze```, analyze the ARPES spectrum of Au polycrystal by ```EfFitting``` in **FermiEdgeFitting.ipf** and get the values of Fermi energy and background.
1. Using ```AuIntensity```, subtract the background and get the intensity spectrum. Or using ```MCPReference```, create the intensity spectrum for fixed mode.
1. Using ```AuNormalize3D```, ```AuNormalize2D```, ```MCPNormalize3D```, or ```MCPNormalize2D```, normalize the ARPES data by intensity spectrum data.
1. Using ```AuEfCorrect3D``` or ```AuEfCorrect2D```, set the Fermi energy to zero.

### Note
When you use ```AuIntensity```, slope of the background is not used. So you probably should neglect this parameter in ```EfFitting``` by setting **holdParams="000100"**.

## Usage
### For Fermi Edge Analysis
```
AuAnalyze(inputWave, temperature, bgWave, efWave, fwhmWave, holdParams)
```
- **inputWave[input]** wave name of Au ARPES data. The first index is energy, the second index is angle.
- **temperature[input]** measurement temperature [K]
- **bgWave[output]** wave name of background data
- **efWave[output]** wave name of Fermi energy data
- **fwhmWave[output]** wave name of the resolution (fwhm) data
- **holdParams[input]** 6-long string determing whether fitting parameters are hold constant or not. See ```FermiEdgeFitting.md``` for detail.

**bgWave**, **efWave** and **fwhmWave** are one-dimensional wave and their lengths are the same as the length of the second index of **inputWave**.

```
AuAnalyze_nearEf(inputWave, temperature, referenceWave, width1, width2, width3, angleSum, energySum, efWave, fwhmWave, holdParams)
```
- **inputWave[input]** wave name of Au ARPES data
- **temperature[input]** measurement temperature [K]
- **referenceWave[input]** reference wave by which the position where the intensity comes is determined, usually the same as **inputWave** in ```MCPReference``` function
- **width1[input]** width for fitting. Fitting width is **[EfApprox-width1, EfApprox+width1]**.
- **width2[input]** width for finding EfApprox. Approximate Fermi edge position is found by ```EdgeStats``` function in **[averageEfApprox-width2, averageEfApprox+width2]**. **averageEfApprox** is the Fermi edge position of the spectrum summed up along angle dimension.
- **width3[input]** width for determing the valid region. Edge fitting is conducted if the area **[EfApprox-width3, EfApprox+width3]** is entirely valid in **referenceWave**.
- **angleSum[input]** the intensity of the angle index **j** is actually the intensity summed up from the angle **j-angleSum** to **j+angleSum**
- **energySum[input]** the intensity of the energy index **i** is actually the intensity summed up from the angle **i-energySum** to **i*angleSum**
- **efWave[output]** wave name of the Fermi edge energy data. The Fermi edge of the invalid area (see the description of **width3**) is set to **-1**.
- **fwhmWave[output]** wave name of the resolution (fwhm) data. The fwhm of the invalid area is set to **-1**.
- **holdParams[input]** 6-long string determing the fitting condition. See ```FermiEdgeFitting.md``` for detail.

### For Intensity Correction
```
AuIntensity(inputwave, bgWave, intensityWave)
```
- **inputWave[input]** wave name of Au ARPES data (the same as **inputWave** of the function ```AuAnalyze```)
- **bgWave[input]** wave name of background data (made by the function ```AuAnalyze```)
- **intensityWave[output]** wave name of intensity data

The (normalized) intensity spectrum is calculated by the following equation:

<p><img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;\texttt{intensity[j]}=\frac{\sum_i&space;\Bigl(\texttt{input[i][j]}-\texttt{background[j]}\Bigr)}{\sum_j&space;\texttt{intensity[j]}}"></p>

The length of the one-dimensional **intensityWave** is the same as the length of the second index of **inputWave**.

```
AuNormalize3D(inputWave, bgWave, intensityWave, coeff, outputWave)
AuNormalize2D(inputWave, bgWave, intensityWave, coeff, outputWave)
```
- **inputWave[input]** wave name of the measurement data
- **bgWave[input]** wave name of the background data (made by the function ```AuAnalyze```)
- **intensityWave[input]** wave name of the intensity data (made by the function ```AuIntensity```)
- **coeff[input]** coefficient for background subtraction. **bgWave[j]\*coeff** is subtracted from **inputWave[][j]**. If you want to subtract background by this function, set **(Number of sweeps in inputWave measurement)/(Number of sweeps in Au measurement)**. However, thie procedure doesn't work well, so you should subtract the background of **inputWave** by ```BackgroundFilter3D``` or ```BackgroundFilter2D``` in **BackgroundFilter.ipf** and set **coeff=0**.
- **outputWave[output]** wave name of the normalized data

In ```AuNormalize3D```, the indices of the **inputWave** are energy, angle/wave vector, angle/wave vector and the two-dimensional slices **input[][][i] (i=0, 1, ..., (length of the third index))** are normalized. In ```AuNormalize2D```, the indices are energy, angle/wave vector.

The following equation is used in normalization process:

<p><img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;\texttt{output[i][j]}=\frac{\texttt{input[i][j]}-\texttt{background[j]}*\texttt{coeff}}{\texttt{intensity[j]}}"></p>

```
MCPHistogram(inputWave, bins, outputWave)
```
- **inputWave[input]** 2D(E-k) measurement data in fixed mode, in which whole valid area is covered by flat intensity
- **bins[input]** number of bins of the histogram
- **outputWave[output]** histogram data

```
MCPReference(inputWave, threshold, outputWave)
```
- **inputWave[input]** 2D(E-k) measurement data in fixed mode, the same as ```MCPHistogram```
- **threshold[input]** intensity threshold, by which whether the position is valid of invalid is determined
- **outputWave[output]** normalized intensity so that the average intensity of valid area is 1. Intensity of the invalid area is set to -1.

```
MCPNormalize2D(inputWave, referenceWave, outputWave)
MCPNormalize3D(inputWave, referenceWave, outputWave)
```
- **inputWave[input]** wave name of the measurement data
- **referenceWave[input]** intensity reference data created by ```MCPReference```
- **outputWave[output]** wave name of the normalized data

### For Fermi Edge Correction

```
AuEfCorrect3D(inputWave, efWave, outputWave)
AuEfCorrect2D(inputWave, efWave, outputWave)
```
- **inputWave[input]** wave name of the measurement data. **row** of the wave (corresponding first index)  should be "energy". **column** (second index) and **layer** (third index) are "wavevector" or "angle."
- **efWave** wave name of the Fermi energy data (made by the function ```AuAnalyze```)
- **outputWave[output]** wave name of output The order of index is the same as **inputWave**.

Fermi energy correction process is the following:

1. Calculate the average of fermi energy, excluding the position where fermi energy is negative.
1. Calculate the index shift of each column by the following equation, where **&Delta;E** is the data pitch of energy row:
    <p><img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;\texttt{shift[j]}=\texttt{round}\left(&space;\frac{E_\text{F,average}-\texttt{EF[j]}}{\Delta&space;\texttt{E}}\right&space;)"></p>
1. Set the offset (the energy of the 0-th row) by the following equation.
    <p><img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;\texttt{offset}_\text{new}=\texttt{offset}_\text{old}-E_\text{F,average}&plus;\min_j(\texttt{shift[j]})"></p>
1. Shift the each column by **shift[j]-min(shift[j])**. The intensity of the area where fermi energy is negative is set to zero.

The rule of **inputWave** is the same as ```AuNormalize3D``` and ```AuNormalize2D```.

## Example
### Au Fermi energy
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorMacro/raw/master/00.%20Resources/Au_ef.png" width=400>

### Au Intensity spectrum
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorMacro/raw/master/00.%20Resources/Au_intensity.png" width=400>

### Before normalization
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorMacro/raw/master/00.%20Resources/ARPES_beforeNormalize.png" width=400>

### After normalization
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorMacro/raw/master/00.%20Resources/ARPES_afterNormalize.png" width=400>
