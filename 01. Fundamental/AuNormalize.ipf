#pragma rtGlobals=1		// Use modern global access method.

#include "FermiEdgeFitting"

//MCPNormalize3D: normalize intensity in fixed mode
//Usage
//inputWave: 3D(E-k-k) measurement data
// slices input[][][i] is normalized
//referenceWave: reference data for correction
//outputWave: corrected data
Function MCPNormalize3D(inputWave, referenceWave, outputWave)
	String inputWave, referenceWave, outputWave
	Variable threshold
	Print("[MCPNormalize3D]")
	Wave/D input=$inputWave
	Wave/D reference=$referenceWave
		
	//energy row information
	Variable size1=DimSize(input,0) 
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	//angle1 column information
	Variable size2=DimSize(input,1)
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	//angle2 layer information
	Variable size3=DimSize(input,2)
	Variable offset3=DimOffset(input,2)
	Variable delta3=DimDelta(input,2)
			
	Variable size4=DimSize(reference,0)
	Variable size5=DimSize(reference,1)
	
	If(size1!=size4 || size2!=size5)
		Print("Error: sizes of input and reference are different")
		Print(num2str(size1))
		abort
	Endif
	
	Make/O/D/N=(size1,size2,size3) $outputWave
	Wave/D output=$outputWave
	
	SetScale/P x offset1, delta1, output
	SetScale/P y offset2, delta2, output
	SetScale/P z offset3, delta3, output

	Variable i,j,k
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2;j+=1)
			If(reference[i][j]<0)
				output[i][j][]=0
			Else
				output[i][j][]=input[i][j][r]/reference[i][j]
			Endif
		Endfor
	Endfor
End

//MCPNormalize2D: normalize intensity in fixed mode
//Usage
//inputWave: 2D(E-k) measurement data
//referenceWave: reference data for correction
//outputWave: corrected data
Function MCPNormalize2D(inputWave, referenceWave, outputWave)
	String inputWave, referenceWave, outputWave
	Variable threshold
	Print("[MCPNormalize2D]")
	Wave/D input=$inputWave
	Wave/D reference=$referenceWave
		
	//energy row information
	Variable size1=DimSize(input,0) 
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	//angle1 column information
	Variable size2=DimSize(input,1)
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
			
	Variable size3=DimSize(reference,0)
	Variable size4=DimSize(reference,1)
	
	If(size1!=size3 || size2!=size4)
		Print("Error: sizes of input and reference are different")
		Print(num2str(size1))
		abort
	Endif
	
	Make/O/D/N=(size1,size2) $outputWave
	Wave/D output=$outputWave
	
	SetScale/P x offset1, delta1, output
	SetScale/P y offset2, delta2, output

	Variable i,j
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2;j+=1)
			If(reference[i][j]<0)
				output[i][j]=0
			Else
				output[i][j]=input[i][j]/reference[i][j]
			Endif
		Endfor
	Endfor
End

//MCPReference: create reference wave for the MCP intensity correction
//Usage
//inputWave: 2D(E-k) measurement data
//threshold: intensity threshold
//outputWave: normalized intensity data (average intensity is 1)
// intensity of the position where intensity is less than threshold is set to -1 (negative)
Function MCPReference(inputWave, threshold, outputWave)
	String inputWave, outputWave
	Variable threshold
	Print("[MCPReference]")
	Wave/D input=$inputWave
		
	//energy row information
	Variable size1=DimSize(input,0) 
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	//angle1 column information
	Variable size2=DimSize(input,1)
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	
	Make/O/D/N=(size1,size2) $outputWave
	Wave/D output=$outputWave
	
	SetScale/P x offset1, delta1, output
	SetScale/P y offset2, delta2, output

	Variable i,j
	Variable counts=0
	Variable intensitySum=0
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2;j+=1)
			If(input[i][j]>threshold)
				counts+=1
				intensitySum+=input[i][j]
			Endif
		Endfor
	Endfor
	
	Variable intensityAverage=intensitySum/counts
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2;j+=1)
			If(input[i][j]>threshold)
				output[i][j]=input[i][j]/intensityAverage
			Else
				output[i][j]=-1
			Endif
		Endfor
	Endfor
End

//MCPHistogram: create histogram for MCP intensity correction in fixed mode
//Usage
//inputWave: 2D(E-k) measurement data
//bins: number of bins in the histogram
//outputWave: histogram data
Function MCPHistogram(inputWave, bins, outputWave)
	String inputWave, outputWave
	Variable bins
	Print("[MCPHistogram]")
	Wave/D input=$inputWave
	Make/O/N=(bins) $outputWave
	Wave/D output=$outputWave
	Histogram/B=1 input, output
End

//AuEfCorrect3D_2: set ef at zero, with two-dimensional ef change
//Usage
//inputWave: 3D(E-k-k) measurement data (input)
//efWave: ef data(k-k) (input)
//outputWave: corrected data (output)
Function AuEfCorrect3D_2(inputWave, efWave, outputWave)
	String inputWave, efWave, outputWave
	
	Wave/D input=$inputWave
	Wave/D ef=$efWave
	
	Print "[AuEfCorrect3D]"
	
	//energy row information
	Variable size1=DimSize(input,0) 
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	//angle1 column information
	Variable size2=DimSize(input,1)
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	//angle2 layer information
	Variable size3=DimSize(input,2)
	Variable offset3=DimOffset(input,2)
	Variable delta3=DimDelta(input,2)
	
	//ef information
	Variable size4=DimSize(ef,0)
	Variable offset4=DimOffset(ef,0)
	Variable delta4=DimDelta(ef,0)
	Variable size5=DimSize(ef,1)
	Variable offset5=DimOffset(ef,1)
	Variable delta5=DimDelta(ef,1)
	
	if(!(size2==size4))
		Print "Error: some of size, offset, delta of input and ef are different"
		abort
	Endif
	
	//print information
	Print "Energy row:"
	Print "Offset: "+num2str(offset1)
	Print "Delta: "+num2str(delta1)
	Print "Size: "+num2str(size1)
	Print "Angle1 column:"
	Print "Offset: "+num2str(offset2)
	Print "Delta: "+num2str(delta2)
	Print "Size: "+num2str(size2)
	Print "Angle2 layer:"
	Print "Offset: "+num2str(offset3)
	Print "Delta: "+num2str(delta3)
	Print "Size: "+num2str(size3)
	
	//offset shift: average of ef & negative index (in case ef is higher than average)
	Make/O/D/N=(size2,size3) $"tempShift"
	Wave/D shift=$"tempShift"
	setScale/P x offset2, delta2, shift
	setScale/P y offset3, delta3, shift
	
	Variable i,j
	Variable efAverage=0
	Variable validSize=0
	For(i=0;i<size2;i+=1)
		For(j=0;j<size3;j+=1)
			If(ef[i][j]>=0)
				efAverage+=ef[i][j]
				validSize+=1
			Endif
		Endfor
	Endfor
	efAverage/=validSize
	Print "ef average: "+num2str(efAverage)
	
	Variable minShift=0 // will be negative
	Variable maxShift=0
	For(i=0;i<size2;i+=1)
		For(j=0;j<size3;j+=1)
			If(ef[i][j]>=0)
				shift[i][j]=round((efAverage-ef[i][j])/delta1)
				if(shift[i][j]<minShift)
					minShift=shift[i][j]
				Endif
				if(shift[i][j]>maxShift)
					maxShift=shift[i][j]
				Endif
			Endif
		Endfor
	Endfor
	
	Print "minShift: "+num2str(minShift)+" maxShift: "+num2str(maxShift)
	
	Variable newSize1=size1-minShift+maxShift
	Make/O/D/N=(newSize1,size2,size3) $outputWave
	Wave/D output=$outputWave
	
	SetScale/P x (offset1-efAverage+minShift*delta1),delta1, output
	SetScale/P y offset2,delta2,output
	SetScale/P z offset3,delta3,output
	
	Variable k
	For(i=0;i<size2;i+=1)
		For(j=0;j<size3;j+=1)
			output[][i][j]=0
			If(ef[i][j]>=0)
				For(k=0;k<size1;k+=1)
					output[k+shift[i][j]-minShift][i][j]=input[k][i][j]
				Endfor
			Endif
		Endfor
	Endfor
	
	KillWaves shift
	
End

//AuEfCorrect3D: set ef at zero
//Usage
//inputWave: 3D(E-k-k) measurement data (input)
//2D slice input[][][i] is corrected
//efWave: ef data (input)
//outputWave: corrected data (output)
Function AuEfCorrect3D(inputWave, efWave, outputWave)
	String inputWave, efWave, outputWave
	
	Wave/D input=$inputWave
	Wave/D ef=$efWave
	
	Print "[AuEfCorrect3D]"
	
	//energy row information
	Variable size1=DimSize(input,0) 
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	//angle1 column information
	Variable size2=DimSize(input,1)
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	//angle2 layer information
	Variable size3=DimSize(input,2)
	Variable offset3=DimOffset(input,2)
	Variable delta3=DimDelta(input,2)
	
	//ef information
	Variable size4=DimSize(ef,0)
	Variable offset4=DimOffset(ef,0)
	Variable delta4=DimDelta(ef,0)
	
	if(!(size2==size4 && offset2==offset4 && delta2==delta4))
		Print "Error: some of size, offset, delta of input and ef are different"
		abort
	Endif
	
	//print information
	Print "Energy row:"
	Print "Offset: "+num2str(offset1)
	Print "Delta: "+num2str(delta1)
	Print "Size: "+num2str(size1)
	Print "Angle1 column:"
	Print "Offset: "+num2str(offset2)
	Print "Delta: "+num2str(delta2)
	Print "Size: "+num2str(size2)
	Print "Angle2 layer:"
	Print "Offset: "+num2str(offset3)
	Print "Delta: "+num2str(delta3)
	Print "Size: "+num2str(size3)
	
	//offset shift: average of ef & negative index (in case ef is higher than average)
	Make/O/D/N=(size2) $"tempShift"
	Wave/D shift=$"tempShift"
	setScale/P x offset2, delta2, shift
	
	Variable i
	Variable efAverage=0
	Variable validSize=0
	For(i=0;i<size2;i+=1)
		If(ef[i]>=0)
			efAverage+=ef[i]
			validSize+=1
		Endif
	Endfor
	efAverage/=validSize
	Print "ef average: "+num2str(efAverage)
	
	Variable minShift=0 // will be negative
	Variable maxShift=0
	For(i=0;i<size2;i+=1)
		If(ef[i]>=0)
			shift[i]=round((efAverage-ef[i])/delta1)
			if(shift[i]<minShift)
				minShift=shift[i]
			Endif
			if(shift[i]>maxShift)
				maxShift=shift[i]
			Endif
		Endif
	Endfor
	
	Print "minShift: "+num2str(minShift)+" maxShift: "+num2str(maxShift)
	
	Variable newSize1=size1-minShift+maxShift
	Make/O/D/N=(newSize1,size2,size3) $outputWave
	Wave/D output=$outputWave
	
	SetScale/P x (offset1-efAverage+minShift*delta1),delta1, output
	SetScale/P y offset2,delta2,output
	SetScale/P z offset3,delta3,output
	
	Variable j,k
	For(i=0;i<size2;i+=1)
		If(ef[i]>=0)
			For(k=0;k<newSize1;k+=1)
				output[k][i][]=0
			Endfor
			For(k=0;k<size1;k+=1)
				output[k+shift[i]-minShift][i][]=input[k][i][r]
			Endfor
		Else
			output[][i][]=0
		Endif
	Endfor
	
	KillWaves shift
	
End

//AuEfCorrect2D: set ef at zero
//Usage
//inputWave: 2D(E-k) measurement data (input)
//efWave: ef data (input)
//outputWave: corrected data (output)
Function AuEfCorrect2D(inputWave, efWave, outputWave)
	String inputWave, efWave, outputWave
	
	Wave/D input=$inputWave
	Wave/D ef=$efWave
	
	Print "[AuEfCorrect2D]"
	
	//energy row information
	Variable size1=DimSize(input,0) 
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	//angle column information
	Variable size2=DimSize(input,1)
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	
	//ef information
	Variable size3=DimSize(ef,0)
	Variable offset3=DimOffset(ef,0)
	Variable delta3=DimDelta(ef,0)
	
	if(!(size2==size3 && offset2==offset3 && delta2==delta3))
		Print "Error: some of size, offset, delta of input and ef are different"
		abort
	Endif
	
	//print information
	Print "Energy row:"
	Print "Offset: "+num2str(offset1)
	Print "Delta: "+num2str(delta1)
	Print "Size: "+num2str(size1)
	Print "Angle column:"
	Print "Offset: "+num2str(offset2)
	Print "Delta: "+num2str(delta2)
	Print "Size: "+num2str(size2)
	
	//offset shift: average of ef & negative index (in case ef is higher than average)
	Make/O/D/N=(size2) $"tempShift"
	Wave/D shift=$"tempShift"
	setScale/P x offset2, delta2, shift
	
	Variable i
	Variable efAverage=0
	Variable validSize=0
	For(i=0;i<size2;i+=1)
		if(ef[i]>=0)
			efAverage+=ef[i]
			validSize+=1
		Endif
	Endfor
	efAverage/=validSize
	Print "ef average: "+num2str(efAverage)
	
	Variable minShift=0 // will be negative
	Variable maxShift=0
	For(i=0;i<size2;i+=1)
		If(ef[i]>=0)
			shift[i]=round((efAverage-ef[i])/delta1)
			if(shift[i]<minShift)
				minShift=shift[i]
			Endif
			if(shift[i]>maxShift)
				maxShift=shift[i]
			Endif
		Endif
	Endfor
	
	Print "minShift: "+num2str(minShift)+" maxShift: "+num2str(maxShift)
	
	Variable newSize1=size1-minShift+maxShift
	Make/O/D/N=(newSize1,size2) $outputWave
	Wave/D output=$outputWave
	
	SetScale/P x (offset1-efAverage+minShift*delta1),delta1, output
	SetScale/P y offset2,delta2,output
	
	Variable j
	For(i=0;i<size2;i+=1)
		If(ef[i]>=0)
			For(j=0;j<newSize1;j+=1)
				output[j][i]=0
			Endfor
			For(j=0;j<size1;j+=1)
				output[j+shift[i]-minShift][i]=input[j][i]
			Endfor
		Else
			output[][i]=0
		Endif
	Endfor
	
	KillWaves shift
	
End

//AuNormalize3D: normalize intensity via Au
//Usage
//inputWave: 3D(E-k-k) measurement data (input)
//2D slice input[][][i] is normalized
//bgWave: background (calculated by AuAnalyze) 
//if coeff=0, bgWave is not used for calculation but for validation, so input the same name as intensityWave
//intensityWave (calculated by AuIntensity)
//coeff: coefficient for bg subtraction (input)
//if you want to subtract bg, enter sweepEx/sweepAu, but it doesn't work well
//sweepAu: number of sweeps in Au measurement (input)
//sweepEx: number of sweeps in input measurement (input)
//if you don't want to use bg subtraction, enter 0
//outputWave: normalized data (output)
Function AuNormalize3D(inputWave, bgWave, intensityWave, coeff, outputWave)
	String inputWave, bgWave, intensityWave, outputWave
	Variable coeff
	
	Wave/D input=$inputWave
	Wave/D bg=$bgWave
	Wave/D intensity=$intensityWave
	
	Print "[AuNormalize3D]"
	
	//energy row information
	Variable size1=DimSize(input,0) 
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	//angle1 column information
	Variable size2=DimSize(input,1)
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	//angle2 layer information
	Variable size3=DimSize(input,2)
	Variable offset3=DimOffset(input,2)
	Variable delta3=DimDelta(input,2)
	
	//print information
	Print "Energy row:"
	Print "Offset: "+num2str(offset1)
	Print "Delta: "+num2str(delta1)
	Print "Size: "+num2str(size1)
	Print "Angle1 column:"
	Print "Offset: "+num2str(offset2)
	Print "Delta: "+num2str(delta2)
	Print "Size: "+num2str(size2)
	Print "Angle2 layer:"
	Print "Offset: "+num2str(offset3)
	Print "Delta: "+num2str(delta3)
	Print "Size: "+num2str(size3)

	
	//bg information
	Variable size4=DimSize(bg,0)
	Variable offset4=DimOffset(bg,0)
	Variable delta4=DimDelta(bg,0)
	
	//intensity information
	Variable size5=DimSize(intensity,0)
	Variable offset5=DimOffset(intensity,0)
	Variable delta5=DimDelta(intensity,0)

	

	if(!(size2==size4) || !(size5==size4))
		Print "Error: some of size of input and bg and intensity are different"
		abort
	Endif

	Make/O/D/N=(size1,size2,size3) $outputWave
	Wave/D output=$outputWave
	
	SetScale/P x offset1, delta1, output
	SetScale/P y offset2, delta2, output
	SetScale/P z offset3, delta3, output
	
	Variable i,j,k
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2;j+=1)
			For(k=0;k<size3;k+=1)
				output[i][j][k]=(input[i][j][k]-bg[j]*coeff)/intensity[j]
			Endfor
		Endfor
	Endfor
	
End


//AuNormalize2D: normalize intensity via Au
//Usage
//inputWave: 2D(E-k) measurement data (input)
//bgWave: background (calculated by AuAnalyze) 
//intensityWave (calculated by AuIntensity)
//coeff: coefficient for bg subtraction (input)
//if you want to subtract bg, enter sweepEx/sweepAu, but it doesn't work well
//sweepAu: number of sweeps in Au measurement (input)
//sweepEx: number of sweeps in input measurement (input)
//if you don't want to use bg subtraction, enter 0
//outputWave: normalized data (output)
Function AuNormalize2D(inputWave, bgWave, intensityWave, coeff, outputWave)
	String inputWave, bgWave, intensityWave, outputWave
	Variable coeff
	
	Wave/D input=$inputWave
	Wave/D bg=$bgWave
	Wave/D intensity=$intensityWave
	
	Print "[AuNormalize2D]"
	
	//energy row information
	Variable size1=DimSize(input,0) 
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	//angle column information
	Variable size2=DimSize(input,1)
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	
	//print information
	Print "Energy row:"
	Print "Offset: "+num2str(offset1)
	Print "Delta: "+num2str(delta1)
	Print "Size: "+num2str(size1)
	Print "Angle column:"
	Print "Offset: "+num2str(offset2)
	Print "Delta: "+num2str(delta2)
	Print "Size: "+num2str(size2)
	
	//bg information
	Variable size3=DimSize(bg,0)
	Variable offset3=DimOffset(bg,0)
	Variable delta3=DimDelta(bg,0)
	
	//intensity information
	Variable size4=DimSize(intensity,0)
	Variable offset4=DimOffset(intensity,0)
	Variable delta4=DimDelta(intensity,0)

	if(!(size2==size3 && offset2==offset3 && delta2==delta3) || !(size3==size4 && offset3==offset4 && delta3==delta4))
		Print "Error: some of size, offset, delta of input and bg and intensity are different"
		abort
	Endif

	Make/O/D/N=(size1,size2) $outputWave
	Wave/D output=$outputWave
	
	SetScale/P x offset1, delta1, output
	SetScale/P y offset2, delta2, output
	
	Variable i,j
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2;j+=1)
			output[i][j]=(input[i][j]-bg[j]*coeff)/intensity[j]
		Endfor
	Endfor
	
End

//AuIntensity: calculate Normalized Intensity from Au
//Usage
//inputWave: Au ARPES data (input)
//bgWave: background (calculated by AuAnalyze)
//intensityWave: normalized intensity (output)
Function AuIntensity(inputWave, bgWave, intensityWave)
	String inputWave, bgWave, intensityWave
	
	Wave/D input=$inputWave
	Wave/D bg=$bgWave
	
	Print "[AuIntensity]"
	
	//energy row information
	Variable size1=DimSize(input,0) 
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	//angle column information
	Variable size2=DimSize(input,1)
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	
	//bg information
	Variable size3=DimSize(bg,0)
	Variable offset3=DimOffset(bg,0)
	Variable delta3=DimDelta(bg,0)
	
	//if(!(size2==size3 && offset2==offset3 && delta2==delta3))
	if(!(size2==size3))
		Print "Error: size of input and bg are different"
		abort
	Endif
	
	Print "Offset: "+num2str(offset2)
	Print "Delta: "+num2str(delta2)
	Print "Size: "+num2str(size2)
	
	Make/O/D/N=(size3) $intensityWave
	Wave/D intensity=$intensityWave
	SetScale/P x offset3, delta3, intensity
	
	Variable i,j

	Variable intensityTotal=0
	For(i=0;i<size3;i+=1)
		Variable intensityOne=0
		For(j=0;j<size1;j+=1)
			intensityOne+=input[j][i]-bg[i]
		Endfor
		intensity[i]=intensityOne
		intensityTotal+=intensityOne
	Endfor
	Variable intensityAverage=intensityTotal/size3
	intensity[]/=intensityAverage
End

//AuAnalyze_nearEf: calculate Ef position from ARPES data of Au polycrystal
//Usage
//inputWave: wave name of Au ARPES data (input)
//temperature: measurement tempreature (input)
//referenceWave: reference wave, by which the position where the intensity comes is determined
//width1: fitting range [eV]
// fitting range is [EfApprox-width,EfApprox+width]
// EfApprox is the position of the heighest decreasing step
//width2: for finding EfApprox
// EfApprox is found by EdgeStats in the region [averageEfApprox-width2, averageEfApprox+width2]
// if global variable "AuAnalyze_nearEf_EfApprox [eV]" doesn't exist, averageEfApprox is determined by averaging & EdgeStats (whole range in energy)
//width3: for valid region
// edge fitting is conducted if the region [EfApprox-width3, EfApprox+width3] is entirely valid
// if width3<=0, the function doesn't check the validity of the region
//angleSum: actually edge fitting is conducted to the summarized wave in the region [j-angleSum,j+angleSum]
//energySum: summation in energy direction
//efWave: wave name of the fermi energy data (output)
//fwhmWave: wave name of FWHM of fermi edge fitting (output)
//holdParams: 6-long string, the same as AuAnalyze
Function AuAnalyze_nearEf(inputWave, temperature, referenceWave, width1, width2, width3, angleSum, energySum, efWave, fwhmWave, holdParams)
	String inputWave, referenceWave, efWave, fwhmWave, holdParams
	Variable temperature, width1, width2, width3, angleSum, energySum
	
	Print("[AuAnalyze_nearEf]")
	Wave/D input=$inputWave
	Wave/D reference=$referenceWave
	
	//energy row information
	Variable size1=DimSize(input,0) 
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	//angle column information
	Variable size2=DimSize(input,1)
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	
	Make/O/D/N=(size2) $efWave
	Wave/D ef=$efWave
	SetScale/P x, offset2, delta2, ef
	
	Make/O/D/N=(size2) $fwhmWave
	Wave/D fwhm=$fwhmWave
	SetScale/P x, offset2, delta2, fwhm
	
	
	Variable i,j,k,m
	
	Make/O/D/N=(size1) average
	Wave/D average=average
	average[]=0
	For(j=0;j<size2;j+=1)
		average[]+=input[p][j]
	Endfor
	Variable averageEfIndex=-1
	NVAR averageEfApprox_NVAR=AuAnalyze_nearEf_EfApprox
	If(NVAR_Exists(averageEfApprox_NVAR))
		averageEfIndex=round((averageEfApprox_NVAR-offset1)/delta1)
	endif
	if(averageEfIndex<0 || averageEfIndex>=size1)
		Print("global variable AuAnalyze_nearEf_averageEfApprox is invalid")
		
		EdgeStats/A=5/B=5/F=0.25/P/Q/R=[size1-1,0] average
		If(V_flag==0)
			averageEfIndex=round(V_EdgeLoc2)
		Elseif(V_flag==1)
			If(numtype(V_EdgeLoc2)==0)
				averageEfIndex=V_EdgeLoc2
			Elseif(numtype(V_EdgeLoc1)==0)
				averageEfIndex=round(V_EdgeLoc1)
			Else
				averageEfIndex=round(V_EdgeLoc3)
			Endif
		Else
			Print("Error: can't find edge from average intensity")
			abort
		Endif
	endif
	
	KillWaves average
	//Print(num2str(averageEfIndex))
	
	Variable EfApproxIndex=0
	Variable width=max(width1,width2)
	Variable tempStartIndex=averageEfIndex-round(width/delta1)
	Variable tempEndIndex=averageEfIndex+round(width/delta1)
	If(tempStartIndex<energySum)
		tempStartIndex=energySum
	Endif
	If(tempEndIndex>=size1-energySum)
		tempEndIndex=size1-energySum-1
	Endif
	Variable tempSize=tempEndIndex-tempStartIndex+1
	
	Make/O/D/N=(tempSize) tempSlice
	Wave/D tempSlice=tempSlice
	SetScale/P x, (offset1+tempStartIndex*delta1), delta1, tempSlice
		
	For(j=0;j<size2;j+=1)
		If(j==100*floor(j/100))
			Print("Index "+num2str(j)+" start")
		Endif
		tempSlice[]=0
		For(i=j-angleSum;i<=j+angleSum;i+=1)
			If(0<=i && i<size2)
				For(k=-energySum;k<=energySum;k+=1)
					tempSlice[]+=input[p+tempStartIndex+energySum-k][i]
				Endfor
			Endif
		Endfor
		//edgeStats index: based on tempSlice
		Variable edgeStatsStartIndex=averageEfIndex-round(width2/delta1)-tempStartIndex
		Variable edgeStatsEndIndex=averageEfIndex+round(width2/delta1)-tempStartIndex
		If(edgeStatsStartIndex<0)
			edgeStatsStartIndex=0
		Endif
		If(edgeStatsEndIndex>=tempSize)
			edgeStatsEndIndex=tempSize-1
		Endif
		
		EdgeStats/A=5/B=5/F=0.25/P/Q/R=[edgeStatsEndIndex,edgeStatsStartIndex] tempSlice
		If(V_flag==0)
			//ok
			EfApproxIndex=round(V_EdgeLoc2)
		Elseif(V_flag==1)
			//not bad
			If(numtype(V_EdgeLoc2)==0)
				EfApproxIndex=round(V_EdgeLoc2)
			Elseif(numtype(V_EdgeLoc1)==0)
				EfApproxIndex=round(V_EdgELoc1)
			Else
				EfApproxIndex=round(V_EdgeLoc3)
			Endif
		Else
			//bad (no edge found)
			ef[j]=-1
			fwhm[j]=-1
			continue
		Endif
		//flag index: based on input or reference
		Variable flagStartIndex=EfApproxIndex-round(width3/delta1)+tempStartIndex
		Variable flagEndIndex=EfApproxIndex+round(width3/delta1)+tempStartIndex
		If(flagStartIndex<0)
			flagStartIndex=0
		Endif
		If(flagEndIndex>=size1)
			flagEndIndex=size1-1
		Endif
		Make/O/D/N=4 $"Config"
		Wave/D conf=$"Config"
		Make/O/D/N=6 $"Parameters"
		Wave/D param=$"Parameters"
		
		Variable flag=1
		If(width3>0)
			For(i=flagStartIndex;i<=flagEndIndex;i+=1)
				If(reference[i][j]<0)
					flag=0
					break
				Endif
			Endfor
		Endif
		If(flag==0)
			//[startIndex,endIndex] is not a valid region
			ef[j]=-1
			fwhm[j]=-1
			continue
		Else
			//edge fitting
			conf[0]=EfApproxIndex-round(width1/delta1)
			conf[1]=EfApproxIndex+round(width1/delta1)
			conf[2]=0 //default
			conf[3]=0 //set by function argument
			EfFitting("tempSlice",temperature,holdParams,0)
			ef[j]=param[4]
			fwhm[j]=param[5]
		Endif
	Endfor
	
	KillWaves tempSlice
End

//AuAnalyze: calculate background offset, fermi energy from ARPES data of Au polycrystal
//Usage
//inputWave: wave name of Au ARPES data (input)
//temperature: measurement temperature (input)
//bgWave: wave name of background data (output)
//efWave: wave name of fermi energy data (output)
//fwhmWave: wave name of FWHM of fermi edge fitting (output)
//holdParams: 6-long string, which determines whether param[i] is hold constant ("1") or not ("0")
//-> see "FermiEdgeFitting.ipf"

Function AuAnalyze(inputWave, temperature, bgWave, efWave, fwhmWave, holdParams)
	String inputWave, bgWave, efWave, fwhmWave, holdParams
	Variable temperature
	
	Print "[AuAnalyze]"
	
	Wave/D input=$inputWave
	//energy row information
	Variable size1=DimSize(input,0) 
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	//angle column information
	Variable size2=DimSize(input,1)
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	
	//print information
	Print "Energy row:"
	Print "Offset: "+num2str(offset1)
	Print "Delta: "+num2str(delta1)
	Print "Size: "+num2str(size1)
	Print "Angle column:"
	Print "Offset: "+num2str(offset2)
	Print "Delta: "+num2str(delta2)
	Print "Size: "+num2str(size2)
		
	//make bg wave
	Make/O/D/N=(size2) $bgWave
	Wave bg=$bgWave
	SetScale/P x, offset2, delta2, bg
	
	//make ef wave
	Make/O/D/N=(size2) $efWave
	Wave ef=$efWave
	SetScale/P x, offset2, delta2, ef
	
	//make fwhm wave
	Make/O/D/N=(size2) $fwhmWave
	Wave fwhm=$fwhmWave
	SetScale/P x, offset2, delta2, fwhm

	//Config
	Make/O/D/N=4 $"Config"
	Wave/D conf=$"Config"
	conf[]=0

	//Param
	Make/O/D/N=6 $"Parameters"
	Wave/D param=$"Parameters"

	//Fitting
	Make/O/D/N=(size1) $"tempSlice"
	Wave/D slice=$"tempSlice"
	SetScale/P x offset1, delta1, slice
	Variable i
	For(i=0;i<size2;i+=1)
		slice[]=input[p][i]
		EfFitting("tempSlice",temperature,holdParams,0)
		bg[i]=param[2]
		ef[i]=param[4]
		fwhm[i]=param[5]
	Endfor
		
End