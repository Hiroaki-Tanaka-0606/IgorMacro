#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//composite3D: composite 3D cube from slices of 2D data
//Usage
//mappingWave: name of text wave including mapping configuration (input)
//value in the wave corresponds folder name
//sequence: wave name in data folders (input)
//outputWave: wave name of output (output)

Function composite3D(mappingWave, sequence, outputWave)
	String mappingWave, sequence, outputWave
	
	Print "[composite3D]"
	
	Wave/D/T mapping=$mappingWave
	//mapping information
	Variable size3=DimSize(mapping,0)
	Variable offset3=DimOffset(mapping,0)
	Variable delta3=DimDelta(mapping,0)
	
	//get 2D slice information
	String wave0Name=":"+mapping[0]+":"+sequence
	
	Print wave0Name
	Wave/D wave0=$wave0Name
	
	//energy row information
	Variable size1=DimSize(wave0,0) 
	Variable offset1=DimOffset(wave0,0)
	Variable delta1=DimDelta(wave0,0)
	//angle column information
	Variable size2=DimSize(wave0,1)
	Variable offset2=DimOffset(wave0,1)
	Variable delta2=DimDelta(wave0,1)
	
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
	
	SetScale/P x offset1,delta1, output
	SetScale/P y offset2,delta2, output
	SetScale/P z offset3,delta3, output
	Variable i
	For(i=0;i<size3;i+=1)
		String wave2DName=":"+mapping[i]+":"+sequence
		Wave wave2D=$wave2DName
		output[][][i]=wave2D[p][q]
	Endfor
End