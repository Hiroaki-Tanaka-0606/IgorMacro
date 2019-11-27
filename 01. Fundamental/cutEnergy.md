# cutEnergy.ipf
cut 3D cube along energy direction to smallen the size of the cube

## Usage
```
cutEnergy3D(inputWave, energyMin, energyMax, outputWave)
```
- **inputWave** name of the 3D input (E-k-k or E-theta-phi)
- **energyMin** minimum energy of the output
- **energyMax** maximum energy
- **outputWave** name of the output

Energy range of the output is the smallest range including **[energyMin, energyMax]**.