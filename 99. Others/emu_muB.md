# emu_muB.ipf
Convert magnetization measurement data, from emu unit to &mu;B/f.u. unit

## Equation
In cgs Gauss unit system,
<img src="https://latex.codecogs.com/svg.latex?\inline&space;\dpi{300}&space;\fn_cm&space;\mu_B=\frac{e\hbar}{2m_\text{e}c}" alt="&mu;<sub>B</sub>=e hbar / 2 m<sub>e</sub> c">.
Therefore magnetization ***mag*<sub>emu</sub>** in unit of emu is converted to ***mag*<sub>&mu;B</sub>** by the following equation:

<img src="https://latex.codecogs.com/svg.latex?\dpi{300}&space;\fn_cm&space;mag_\mathrm{\mu&space;B}=\frac{mag_\text{emu}}{\dfrac{mass}{fw}\times&space;N_\text{A}\cdot&space;\dfrac{e\hbar}{2m_\text{e}c}}" alt="**mag***/(mass/fw Na)/(e hbar/(2 me c))">, 

where
- ***mass*** mass of the sample [g]
- ***fw*** formula weight of the compound [g mol<sup>-1</sup>]
- ***N*<sub>A</sub>** Avogadro constant 6.0021\*10<sup>23</sup> [mol<sup>-1</sup>]
- ***e*** elementary charge
- ***c*** speed of light, e/c=1.6022\*10<sup>-20</sup> [esu cm<sup>-1</sup> s]
- ***hbar*** Dirac constant 1.0546\*10<sup>-27</sup> [g cm<sup>2</sup> s<sup>-1</sup>]
- ***m*<sub>e</sub>** mass of electron 9.1094\*10<sup>-28</sup> [g]

## Usage
```
emu_muB(waveName, waveName2, mass, formulaWeight)
```
- **waveName[input]** wave name of measurement data
- **waveName2[output]** wave name of rescaled data
- **mass[input]** weight of the sample [g]
- **formulaWeight[input]** formula weight of the sample [g mol<sup>-1</sup>]

```
subtractBackground(inputWave, backgroundWave, outputWave)
```
- **inputWave[input]** wave name of measurement data
- **backgroundWave[input]** wave name of background data. The size of **inputWave** and **backgroundWave** must be the same.
- **outputWave[output]** wave name of output (=measurement-background) data
