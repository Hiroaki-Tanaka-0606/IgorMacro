# Composite3D.ipf
Composite 3D cube from slices of 2D data

## Process
In the function ```composite3D```, the following folders and waves are assumed to exist:
```
|--XXX_0001 (folder)
|  |--sequence (wave) 
|
|--XXX_0002
|  |--sequence
|
...
```
The function ```composite3D``` collects 2D waves named **sequence** in the folders listed in a wave (named **mappingWave**). In output 3D wave, the first and the second dimension is the same as those of the first wave in the list and the third dimension is determined by **mappingWave**.

## Usage
```
composite3D(mappingWave, sequence, outputWave)
```
- **mappingWave[input]** name of a ***text*** wave in which names of folders are listed. Don't forget to set **offset** and **delta** of the wave (which are inherited by output wave).
- **sequence[input]** name of 2D waves. All 2D waves should have the same name. In case of the measurement by SES, wave name is the same as sequence name, so 2D waves for composition of 3D cube always have the same name.
- **outputWave[output]** name of output wave
