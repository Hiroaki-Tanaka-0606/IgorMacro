#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//sliceNormalize: modify intensity of each slice so that all slices have the same net intensity
//Usage
//inputWave: wave name of corrected measurement data (E-k-k) (input)
//outputWave: wave name of normalized measurement data (output)
//area of 2D slice input[][][i] is calculated
Function sliceNormalize(inputWave, outputWave)
	String inputWave, outputWave
	Wave/D input=$inputWave
	
	Print "[sliceNormalize]"
	
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
	
	Make/O/D/N=(size3) $"tempIntensity"
	Wave/D intensity=$"tempIntensity"
	
	Variable i,j,k
	Variable intensityTotal=0
	Variable intensityOne
	For(i=0;i<size3;i+=1)
		intensityOne=0
		For(j=0;j<size1;j+=1)
			For(k=0;k<size2;k+=1)
				intensityOne+=input[j][k][i]
			Endfor
		Endfor
		intensity[i]=intensityOne
		intensityTotal+=intensityOne
	Endfor
	Variable intensityAverage=intensityTotal/size3
	intensity[]/=intensityAverage
	
	Make/O/D/N=(size1,size2,size3) $outputWave
	Wave/D output=$outputWave
	
	SetScale/P x offset1, delta1, output
	SetScale/P y offset2, delta2, output
	SetScale/P z offset3, delta3, output
	
	For(i=0;i<size3;i+=1)
		For(j=0;j<size1;j+=1)
			For(k=0;k<size2;k+=1)
				output[j][k][i]=input[j][k][i]/intensity[i]
			Endfor
		Endfor
	Endfor
	
	KillWaves intensity
	
End

//sliceNormalize2D_range: modify intensity of each slice so that all slices have the same net intensity
//Usage
//inputWave: wave name of corrected measurement data (k-k) (input)
//startX, endX: kx range (input)
//startY, endY: ky range (input)
//outputWave: wave name of normalized measurement data (output)
//area of 1D slice input[][i], within the range [startX, endX] is calculated
Function sliceNormalize2D_range(inputWave, startX,endX,startY,endY,outputWave)
	String inputWave, outputWave
	Variable startX,endX,startY,endY
	Wave/D input=$inputWave
	
	Print "[sliceNormalize2D_range]"
	
	//angle row information
	Variable size1=DimSize(input,0) 
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	//angle1 column information
	Variable size2=DimSize(input,1)
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
		
	//print information
	Print "Angle1 row:"
	Print "Offset: "+num2str(offset1)
	Print "Delta: "+num2str(delta1)
	Print "Size: "+num2str(size1)
	Print "Angle2 column:"
	Print "Offset: "+num2str(offset2)
	Print "Delta: "+num2str(delta2)
	Print "Size: "+num2str(size2)
	
	Make/O/D/N=(size2) $"tempIntensity"
	Wave/D intensity=$"tempIntensity"
	
	Variable i,j
	Variable intensityTotal=0
	Variable intensityOne
	Variable intensityCount=0
	intensity[]=-1
	For(i=0;i<size2;i+=1)
		Variable y=offset2+delta2*i
		If(y<startY || y>endY)
			continue
		Endif
		intensityCount+=1
		intensityOne=0
		For(j=0;j<size1;j+=1)
			Variable x=offset1+delta1*j
			If(x<startX || x>endX)
				continue
			endif
			if(numtype(input[j][i])==0)
				intensityOne+=input[j][i]
			Endif
		Endfor
		intensity[i]=intensityOne
		intensityTotal+=intensityOne
	Endfor
	Variable intensityAverage=intensityTotal/size2
	
	For(i=0;i<size2;i+=1)
		if(intensity[i]<0)
			intensity[i]=1
		else
			intensity[i]/=intensityAverage
		endif
	Endfor
	
	Make/O/D/N=(size1,size2) $outputWave
	Wave/D output=$outputWave
	
	SetScale/P x offset1, delta1, output
	SetScale/P y offset2, delta2, output
	
	
	output[][]=input[p][q]/intensity[q]
	
	KillWaves intensity
	
End


//sliceNormalize3D_range: modify intensity of each slice so that all slices have the same net intensity
//Usage
//inputWave: wave name of measurement data (E-k-k) (input)
//startE, endE: energy range (input)
//outputWave: wave name of normalized measurement data (output)
//area of 2D slice input[][][i], within the range [startE, endE] is calculated
Function sliceNormalize3D_range(inputWave,startE,endE,outputWave)
	String inputWave, outputWave
	Variable startE,endE
	Wave/D input=$inputWave
	
	Print "[sliceNormalize3D_range]"
	
	//Energy row information
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
	
	Make/O/D/N=(size3) $"tempIntensity"
	Wave/D intensity=$"tempIntensity"
	
	Variable eStartIndex=ceil((startE-offset1)/delta1)
	Variable eEndIndex=floor((endE-offset1)/delta1)
	
	if(eStartIndex<0)
		eStartIndex=0
	Endif
	If(eEndIndex>=size1)
		eEndIndex=size1-1
	ENdif
	
	Print("Energy range ["+num2str(eStartIndex)+","+num2str(eEndIndex)+"] is used for intensity calculation")
	
	Variable i,j,k
	Variable intensityTotal=0
	Variable intensityOne
	For(i=0;i<size3;i+=1)
		intensityOne=0
		For(j=eStartIndex;j<=eEndIndex;j+=1)
			For(k=0;k<size2;k+=1)
				intensityOne+=input[j][k][i]
			Endfor
		Endfor
		intensity[i]=intensityOne
		intensityTotal+=intensityOne
	Endfor
	Variable intensityAverage=intensityTotal/size3
	intensity[]/=intensityAverage
	
	Make/O/D/N=(size1,size2,size3) $outputWave
	Wave/D output=$outputWave
	
	SetScale/P x offset1, delta1, output
	SetScale/P y offset2, delta2, output
	SetScale/P z offset3, delta3, output
	
	For(i=0;i<size3;i+=1)
		For(j=0;j<size1;j+=1)
			For(k=0;k<size2;k+=1)
				output[j][k][i]=input[j][k][i]/intensity[i]
			Endfor
		Endfor
	Endfor
	
	KillWaves intensity

	
End