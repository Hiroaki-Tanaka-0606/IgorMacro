#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//BackGroundFilter3D: subtract background calculated from intensity above Ef
//Usage
//inputWave: 3D(E-k-k) measurement data (input)
//aboveEf: energy slightly above ef [eV] (input)
//outputWave: output data (output)
Function BackGroundFilter3D(inputWave, aboveEf, outputWave)
	String inputWave, outputWave
	Variable aboveEf
	
	Wave/D input=$inputWave
	
	Print "[BackgroundFilter3D]"
	
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
	
	Make/O/D/N=(size1,size2,size3) $outputWave
	Wave/D output=$outputWave
	
	SetScale/P x offset1, delta1, output
	SetScale/P y offset2, delta2, output
	SetScale/P z offset3, delta3, output
	
	Variable i,j,k
	Variable kstart=ceil((aboveEf-offset1)/delta1)
	Variable bgSum
		Print "Background Calculation start: "+num2str(kstart)+" end: "+num2str(size1)
	For(i=0;i<size2;i+=1)
		For(j=0;j<size3;j+=1)
			bgSum=0
			For(k=kstart;k<size1;k+=1)
				bgSum+=input[k][i][j]
			Endfor
			bgSum/=(size1-kstart)
			output[][i][j]=input[p][i][j]-bgSum
		Endfor
	Endfor
End


//BackGroundFilter2D: subtract background calculated from intensity above Ef
//Usage
//inputWave: 2D(E-k) measurement data (input)
//aboveEf: energy slightly above ef [eV] (input)
//outputWave: output data (output)
Function BackGroundFilter2D(inputWave, aboveEf, outputWave)
	String inputWave, outputWave
	Variable aboveEf
	
	Wave/D input=$inputWave
	
	Print "[BackgroundFilter2D]"
	
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
	
	Make/O/D/N=(size1,size2) $outputWave
	Wave/D output=$outputWave
	
	SetScale/P x offset1, delta1, output
	SetScale/P y offset2, delta2, output
	
	Variable i,j
	Variable jstart=ceil((aboveEf-offset1)/delta1)
	Variable bgSum
	
	Print "Background Calculation start: "+num2str(jstart)+" end: "+num2str(size1)
	For(i=0;i<size2;i+=1)
		bgSum=0
		For(j=jstart;j<size1;j+=1)
			bgSum+=input[j][i]
		Endfor
		bgSum/=(size1-jstart)
		output[][i]=input[p][i]-bgSum
	Endfor
End
