# SliceNormalize.ipf
Modify intensity of each slice so that all slices have the same net intensity

## Process
The intensity of signal depends on matrix element of photoemission process and condition of light source, so sometimes intensity difference between slices makes image of constant-energy surface difficult to understand. Normalization of intensity may make the image more comprehensive.

Here, the third index of input wave (3D) is used as an index of "slice." Intensity of slice is the sum of intensity for the first and second index. Then intensity is normalized by division so that every intensity of slice is the same as the average of intensity before normalization.

## Usage
```
sliceNormalize(inputWave, outputWave)
```
- **inputWave[input]** name of input wave. Be careful to make 3D cube in which the third index corresponds to slice index. Function ```composite3D``` can make such 3D wave.
- **outputWave[output]** name of output wave

## Example
### Before
<img src="https://raw.githubusercontent.com/Hiroaki-Tanaka-0606/IgorMacro/master/00.%20Resources/FermiSurface_beforeNormalize.png">

### After 
<img src="https://raw.githubusercontent.com/Hiroaki-Tanaka-0606/IgorMacro/master/00.%20Resources/FermiSurface_afterNormalize.png">
