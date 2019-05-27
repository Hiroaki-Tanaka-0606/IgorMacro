#pragma rtGlobals=1		// Use modern global access method.

//EfFitting: Fermi edge (with temperature & noise fluctuation) fitting 

//Fitting function (same as InoMacro Ver3.124)
//=w[0]*(convolve((1+w[1]x)/(exp(beta(w[6]))+1),gaussian(w[5]))+w[2]+w[3]*x)
//x=energy-w[4]

//Fitting Parameters: stored in "Parameters" wave
//param[0]: Intensity @ef
//param[1]: Slope of Intensity [/eV]
//param[2]: Background @ef
//param[3]: Slope of Background [/eV]
//param[4]: ef [eV]
//param[5]: sigma(FWHM) [eV]
//param[6]: temperature [K]

//Fitting Configuration: stored in "Config" wave
//conf[0]: fitting range (min, including itself) [index], 0 if the value is the same as of smaller than 0
//conf[1]: fitting range (max, not including itself) [index], DimSize(wave,0) if the value is larger than that value
//range: [conf[0],conf[1])
//conf[2]: min dE, default ddE/10
//conf[3]: # of points in k_B T range, default 2
//conf[4]: # of points in sigma range, default 5
//smallest value of dE from conf[2], conf[3], conf[4], ddE is used for calculation
//and slighty modified so that ddE = (integer) * dE
//ddE = delta E of data
//conf[5]: range to calculate gaussian [*sigma]
//conf[6]: fitting tolerance

//Usage
//waveName: wave name to fit

Function EfFitting(waveName)
	String waveName
	
	Wave/D input=$waveName
	//energy information
	Variable/G size=DimSize(input,0)
	Variable/G offset=DimOffset(input,0)
	Variable/G delta=DimDelta(input,0)
	Print "Offset: "+num2str(offset)
	Print "Delta: "+num2str(delta)
	Print "Size: "+num2str(size)
	
	//get initial value
	EdgeStats/A=5/B=5/F=0.25/P input
	
End
