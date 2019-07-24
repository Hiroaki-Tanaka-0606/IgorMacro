#pragma rtGlobals=1		// Use modern global access method.

#include "FermiEdgeFitting"


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
	For(i=0;i<size2;i+=1)
		efAverage+=ef[i]
	Endfor
	efAverage/=size2
	Print "ef average: "+num2str(efAverage)
	
	Variable minShift=0 // will be negative
	Variable maxShift=0
	For(i=0;i<size2;i+=1)
		shift[i]=round((efAverage-ef[i])/delta1)
		if(shift[i]<minShift)
			minShift=shift[i]
		Endif
		if(shift[i]>maxShift)
			maxShift=shift[i]
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
		For(j=0;j<size3;j+=1)
			For(k=0;k<newSize1;k+=1)
				output[k][i][j]=0
			Endfor
			For(k=0;k<size1;k+=1)
				output[k+shift[i]-minShift][i][j]=input[k][i][j]
			Endfor
		Endfor
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
	For(i=0;i<size2;i+=1)
		efAverage+=ef[i]
	Endfor
	efAverage/=size2
	Print "ef average: "+num2str(efAverage)
	
	Variable minShift=0 // will be negative
	Variable maxShift=0
	For(i=0;i<size2;i+=1)
		shift[i]=round((efAverage-ef[i])/delta1)
		if(shift[i]<minShift)
			minShift=shift[i]
		Endif
		if(shift[i]>maxShift)
			maxShift=shift[i]
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
		For(j=0;j<newSize1;j+=1)
			output[j][i]=0
		Endfor
		For(j=0;j<size1;j+=1)
			output[j+shift[i]-minShift][i]=input[j][i]
		Endfor
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

	

	if(!(size2==size4 && offset2==offset4 && delta2==delta4) || !(size5==size4 && offset5==offset4 && delta5==delta4))
		Print "Error: some of size, offset, delta of input and bg and intensity are different"
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
	
	if(!(size2==size3 && offset2==offset3 && delta2==delta3))
		Print "Error: some of size, offset, delta of input and bg are different"
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