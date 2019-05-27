#pragma rtGlobals=1		// Use modern global access method.

//AuAnalyze: calculate offset, fermi energy, intensity from ARPES data of Au polycrystal
//Usage
//inputWave: wave name of Au ARPES data (input)
//offsetWave: wave name of offset data (output)
//efWave_raw: wave name of raw fermi energy data (output)
//efWave_delta: wave name of FWHM of fermi edge fitting (output)
//efWave_curve: wave name of fermi energy data (fitting by curve) (output)
//intensityWave: wave name of intensity data (output)

Function AuAnalyze(inputWave, offsetWave, efWave_raw, efWave_delta, efWave_curve, intensityWave)
	String inputWave, offsetWave, efWave_raw, efWave_delta, efWave_curve, intensityWave
	
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
		
	//make offset wave
	Make/O/D/N=(size2) $offsetWave
	Wave offset=$offsetWave
	SetScale/P x, offset2, delta2, offset
	
	//make ef_raw wave
	Make/O/D/N=(size2) $efWave_raw
	Wave ef_raw=$efWave_raw
	SetScale/P x, offset2, delta2, ef_raw
	
	//make ef_delta wave
	Make/O/D/N=(size2) $efWave_delta
	Wave ef_delta=$efWave_delta
	SetScale/P x, offset2, delta2, ef_delta
	
	
	//ef calculation
	
	
End