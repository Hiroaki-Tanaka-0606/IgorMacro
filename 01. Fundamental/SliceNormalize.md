# SliceNormalize.ipf
Modify intensity of each slice so that all slices have the same net intensity

## Process
The intensity of signal depends on matrix element of photoemission process and condition of light source, so sometimes intensity difference between slices makes image of constant-energy surface difficult to understand. Normalization of intensity may make the image more comprehensive.

Here, the last index of input wave is used as an index of "slice." Intensity of slice is the sum of intensity for the first and second (in 3D) or the first (in 2D) index. Then intensity is normalized by division so that every intensity of slice is the same as the average of intensity before normalization.

## Usage
```
sliceNormalize(inputWave, outputWave)
```
- **inputWave[input]** name of input wave. Be careful to make 3D cube in which the third index corresponds to slice index. Function ```composite3D``` can make such 3D wave.
- **outputWave[output]** name of output wave

```
sliceNormalize2D_range(inputWave, startX, endX, startY, endY, outputWave)
```
- **inputWave[input]** wave name of corrected measurement data (k-k)
- **startX[input]**, **endX[input]** kx range
- **startY[input]**, **endY[input]** ky range
- **outputWave[output]** wave name of normalized measurement data

Area of 1D slice input[][i], within the range **[startX, endX]** is calculated for correction.
If the y value of input[][i] is out of the range **[startY, endY]**, the intensity is kept the same.

```
sliceNormalize3D_range(inputWave, startE, endE, outputWave)
```
- **inputWave[input]** wave name of measurement data (E-k-k) (input)
- **startE[input]**, **endE[input]**: energy range (input)
- **outputWave[output]** wave name of normalized measurement data (output)

Area of 2D slice input[][][i], within the range **[startE, endE]** in the first index is calculated.

## Example
### Before
<img src="https://raw.githubusercontent.com/Hiroaki-Tanaka-0606/IgorMacro/master/00.%20Resources/FermiSurface_beforeNormalize.png" width="600px">

### After 
<img src="https://raw.githubusercontent.com/Hiroaki-Tanaka-0606/IgorMacro/master/00.%20Resources/FermiSurface_afterNormalize.png" width="600px">
