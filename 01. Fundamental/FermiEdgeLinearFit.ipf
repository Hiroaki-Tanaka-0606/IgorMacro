#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//AnalyzeFermiEdge: analyze kz dependence of Fermi edge
//Usage
//inputWave: Fermi edge list (hn-ef)
//fitting condition: x=hn, y=ef
//slopeWave: slope of linear fit
//sectionWave: y section of linear fit
Function AnalyzeFermiEdge(inputWave, slopeWave, sectionWave)
	String inputWave, slopeWave, sectionWave
	
	Print("[AnalyzeFermiEdge]")
	Wave/D input=$inputWave
			
	//hn row information
	Variable size1=DimSize(input,0) 
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	//angle column information
	Variable size2=DimSize(input,1)
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
			
	Make/O/D/N=(size2) $slopeWave
	Wave/D slope=$slopeWave
	SetScale/P x, offset2, delta2, slope
	
	Make/O/D/N=(size2) $sectionWave
	Wave/D section=$sectionWave
	SetScale/P x, offset2, delta2, section
	
	Make/O/D/N=(size1) tempSlice
	Wave/D tempSlice=tempSlice
	SEtScale/P x, offset1, delta1, tempSlice
	
	Variable i
	For(i=0;i<size2;i+=1)
		If(input[0][i]<0)
			slope[i]=-1
			section[i]=+1
		Else
			tempSlice[]=input[p][i]
			CurveFit/N/Q line tempSlice
			Wave/D coef=W_coef
			section[i]=coef[0]
			slope[i]=coef[1]
		Endif
	Endfor
End

//GenerateFermiEdge: generate Fermi edge from linear fit
//Usage
//slopeWave: slope of linear fit
//sectionWave: section of linear fit
//hn: photon energy [eV]
//outputWave: generated Fermi edge
Function GenerateFermiEdge(slopeWave, sectionWave, hn, outputWave)
	String slopeWave, sectionWave, outputWave
	Variable hn
	
	Print("[GenerateFermiEdge]")
	
	Wave/D slope=$slopeWave
	Wave/D section=$sectionWave
	
	//angle row information
	Variable size1=DimSize(slope,0)
	Variable offset1=DimOffset(slope,0)
	Variable delta1=DimDelta(slope,0)
	
	Make/O/D/N=(size1) $outputWave
	Wave/D output=$outputWave
	SetScale/P x, offset1, delta1, output
	
	Variable i
	For(i=0;i<size1;i+=1)
		If(slope[i]<0)
			output[i]=-1
		Else
			output[i]=section[i]+slope[i]*hn
		Endif
	Endfor
End