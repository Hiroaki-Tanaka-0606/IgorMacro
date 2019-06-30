# BackGroundFilter.ipf
Remove constant noise from broken channels of micro-channel plate

## Process
Functions ```BackGroundFilter2D``` and ```BackGroundFilter3D``` in this file calculate constant noise from average intensity above an energy (**aboveEf[input]**) and subtract it. Noise intensity is calculated in each column (2D case), each column and layer (3D case).

## Usage
```
BackGroundFilter3D(inputWave, aboveEf, outputWave)
```

```
BackGroundFilter2D(inputWave, aboveEf, outputWave)
```
- **inputWave[input]** wave name of input. In both case, **row** of the wave (corresponding first index)  should be "energy". **column** (second index) and **layer** (third index) are "wavevector" or "angle."
- **aboveEf[input]** an energy slightly above Fermi energy, so that above **aboveEf** only noise affects the intensity and thermally fluctuated signal don't. The unit of this variable is the same as that of the first dimension of **inputWave**.
- **outputWave[output]** wave name of output The order of index is the same as **inputWave**.

Through these processes, **inputWave** is not changed.

## Example
### Before
<img src="https://raw.githubusercontent.com/Hiroaki-Tanaka-0606/IgorMacro/master/00.%20Resources/Au_poly.png">

### After
<img src="https://raw.githubusercontent.com/Hiroaki-Tanaka-0606/IgorMacro/master/00.%20Resources/Au_poly_filtered.png">
