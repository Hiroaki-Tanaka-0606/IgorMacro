#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//invertAxes3D: invert k axes
//Usage
//inputWave: wave name of measurement data (E-kx-ky) (input)
//invertSecond: 1 when invert kx axis (input)
//invertThird: 1 when invert ky axis (input)
//outputWave: wave name of output data (output)
Function invertAxes3D(inputWave, invertSecond, invertThird, outputWave)
	String inputWave, outputWave
	Variable invertSecond, invertThird
	
		
	Wave/D input=$inputWave
	
	Print "[invertAxes3D]"
	
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

	Duplicate/O input $outputWave
	Wave/D output=$outputWave
	
	output[][][]=input[p][q][r]
	
	Variable i,j
	Variable newI, newJ
	For(i=0;i<size2;i+=1)
		For(j=0;j<size3;j+=1)
			If(invertSecond==1)
				newI=size2-i-1
			Else
				newI=i
			Endif
			If(invertThird==1)
				newJ=size3-j-1
			Else
				newJ=j
			Endif
			output[][i][j]=input[p][newI][newJ]
		Endfor
	Endfor
	If(invertSecond==1)
		Variable newOffset2=-(offset2+(size2-1)*delta2)
		SetScale/P y, newOffset2, delta2, output
	Endif
	
	
	If(invertThird==1)
		Variable newOffset3=-(offset3+(size3-1)*delta3)
		SetScale/P z, newOffset3, delta3, output
	Endif

End