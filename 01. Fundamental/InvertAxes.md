# InvertAxes.ipf
Invert k axes of 3D cube

## Usage
```
invertAxes3D(inputWave, invertSecond, invertThird, outputWave)
```
- **inputWave[input]** wave name of input. **row** of the wave (corresponding first index)  should be "energy". **column** (second index) and **layer** (third index) are "wavevector" or "angle."
- **invertSecond** If the value is 1, invert the **column** (second index)
- **invertThird** If the value is 1, invert the **layer** (second index)
- **outputWave[output]** wave name of output The order of index is the same as **inputWave**.
