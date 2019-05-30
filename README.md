# IgorMacro
Igor Macro for analysis of ARPES measurement data (Scienta Omicron, SES) and so on

# List

## For ARPES measurement 
### Fundamental

### Advanced


## Others
- **emu_muB.ipf** rescale emu to &mu;B/f.u.

# Note
The values of physical constants are from https://physics.nist.gov/cuu/Constants/

# Description of each file

## emu_muB.ipf
Rescale magnetization measurement data, from emu unit to &mu;B/f.u. unit

### equation
In cgs Gauss unit system, &mu;B=e hbar / 2 me c.
Therefore magnetization ***mag*** in unit of emu is equal to ***mag***/(mass/fw Na)/(e hbar/(2 me c)), where
- **mass** mass of the sample [g]
- **fw** formula weight of the compound [g mol<sup>-1</sup>]
- **Na** Avogadro constant 6.0021\*10<sup>23</sup> [mol<sup>-1</sup>]
- **e** elementary charge
- **c** speed of light, e/c=1.6022\*10<sup>-20</sup> [esu cm<sup>-1</sup> s]
- **hbar** Dirac constant 1.0546\*10<sup>-27</sup> [g cm<sup>2</sup> s<sup>-1</sup>]
- **me** mass of electron 9.1094\*10<sup>-28</sup> [g]

### usage
```
emu_muB(waveName, waveName2, mass, formulaWeight)
```
- **waveName[input]** wave name of measurement data
- **waveName2[output]** wave name of rescaled data
- **mass[input]** weight of the sample [g]
- **formulaWeight[input]** formula weight of the sample [g mol^-1]
