# FermiEdgeFitting.ipf
Fit intensity by Fermi distribution function with gaussian-type fructuation

## Equation
Fitting is done by ```FuncFit``` function. The trial function **f(x)** is convolution of **Fermi distribution function (with linear slope) F(x)** and **gaussian-type fructuation G(x)**, in detail

<p><img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;F(x)=\frac{1&plus;p_1&space;x}{e^{\beta&space;x}&plus;1}"></p>
<p><img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;G(x)=\frac{1}{\sqrt{2\pi}\sigma}\exp\left(-\frac{x^2}{2\sigma^2}&space;\right&space;)"></p>
<p><img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;f(x)=p_0\times&space;F(x)\otimes&space;G(x)&plus;p_2&plus;p_3&space;x"></p>
<p><img src="https://latex.codecogs.com/svg.latex?\fn_cm&space;\beta=\frac{1}{k_B&space;T},\&space;\sigma=\frac{p_5}{2\sqrt{2\log&space;2}}"></p>

where ***p<sub>0</sub>*** - ***p<sub>5</sub>*** are fitting parameters, ***k<sub>B</sub>*** is Boltzmann's constant, ***T*** is the temperature.

## Process
1. Load following configuration values from **Config** wave:
    - First row (**conf[0]**): minimum of fitting range in unit of **index** (not **energy**). The default value is **zero**.
    - Second row (**conf[1]**): maximum of fitting range in unit of **index** (not **energy**). The default value is **the size of the wave**. Fitting range becomes **[conf[0], conf[1])** (including **conf[0]** but not including **conf[1]**).
    - Third row (**conf[2]**): range to calculate gaussian in unit of **sigma**. The default value is **five**.
    - Fourth row (**conf[3]**): temperature. It is set from the second argument of the function **EfFitting**.
1. When **Config** wave doesn't exist, make **Config** wave and the default values are set.
1. Set initial value of the fitting parameters from the result of ```EdgeStats``` function. Fitting parameters are stored in **Parameters** wave.
    - First row (**param[0]**, ***p_0***): scale of intensity
    - Second row (**param[1]**, ***p_1***): slope of intensity (not set by ```EdgeStats```, the initial value is ***zero***)
    - Third row (**param[2]**, ***p_2***): constant background
    - Fourth row (**param[3]**, ***p_3***): slope of background (not set by ```EdgeStats```, the initial value is ***zero***)
    - Fifth row (**param[4]**, ***p_4***): position of Fermi energy [eV]
    - Sixth row (**param[5]**, ***p_5***): FWHM of fructuation [eV]

1. When ```EdgeStats``` function couldn't find any edge successfully, **warning** or **error** is printed. In addition, when the **error** is printed, fitting is aborted.
1. When ```EdgeStats``` function could find an edge successfully, try fitting.

## Usage
```EfTrialFunc``` and ```GaussianWave``` functions in **FermiEdgeFitting.ipf** are called by ```EfFitting``` function and you don't call them by yourself.
```
EfFitting(waveName, temperature, holdParams, displayFlag)
```
- **waveName[input]** name of the input wave
- **temperature[input]** measurement temperature
- **holdParams[input]** 6-long string determing whether fitting parameters are hold constant or not. When the i-th letter of **holdParams** is "1", ***p<sub>i</sub>*** is hold constant and when the letter is "0", it is changed by fitting procedure. Parameters other than ***p<sub>1</sub>*** and ***p<sub>3</sub>*** are estimated in initialization by ```EdgeStats```, so holding these parameters constant is not reasonable.
- **displayFlag[input]** when **displayFlag** is **1** (not **"1"**), some information and fitting result is presented.

Output of ```EfFitting```function is the fitting parameters, which are stored in **Parameters** wave.

## Example
<img src="https://github.com/Hiroaki-Tanaka-0606/IgorMacro/raw/master/00.%20Resources/Au_edge_fitting.png" width=500>
