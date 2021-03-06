#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//cutEnergy3D: cut a 3D cube along energy direction
//Usage
//inputWave: name of the 3D input (E-k-k or E-theta-phi)
//energyMin: minimum energy of the output
//energyMax: maximum energy
//outputWave: name of the output
//energy range of the output is the smallest range including [energyMin, energyMax]
Function cutEnergy3D(inputWave, energyMin, energyMax, outputWave)
	String inputWave
	String outputWave
	Variable energyMin, energyMax
	
	Wave/D input=$inputWave
	
	Print "[cutEnergy3D]"
	
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

	Variable startIndex=ceil((energyMin-offset1)/delta1)
	if(startIndex<0)
		startIndex=0
	Endif
	
	Variable endIndex=floor((energyMax-offset1)/delta1)
	if(endIndex>=size1)
		endIndex=size1-1
	Endif
	
	if(startIndex>endIndex)
		print("Error: energyMin>energyMax")
		print("startIndex: "+num2str(startIndex))
		Print("endIndex: "+num2str(endIndex))
		abort
	Endif
	
	Make/O/D/N=(endIndex-startIndex+1,size2,size3) $outputWave
	Wave/D output=$outputWave
	SetScale/P x, (offset1+startIndex*delta1), delta1, output
	SetScale/P y, offset2, delta2, output
	SetScale/P z, offset3, delta3, output
	
	Variable i
	For(i=startIndex;i<=endIndex;i+=1)
		output[i-startIndex][][]=input[i][q][r]
	Endfor
End

//cutEnergy2D: cut a 2D cube along energy direction
//Usage
//inputWave: name of the 2D input (E-k or E-theta)
//energyMin: minimum energy of the output
//energyMax: maximum energy
//outputWave: name of the output
//energy range of the output is the smallest range including [energyMin, energyMax]
Function cutEnergy2D(inputWave, energyMin, energyMax, outputWave)
	String inputWave
	String outputWave
	Variable energyMin, energyMax
	
	Wave/D input=$inputWave
	
	Print "[cutEnergy2D]"
	
	//energy row information
	Variable size1=DimSize(input,0) 
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	//angle1 column information
	Variable size2=DimSize(input,1)
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)

	Variable startIndex=ceil((energyMin-offset1)/delta1)
	if(startIndex<0)
		startIndex=0
	Endif
	
	Variable endIndex=floor((energyMax-offset1)/delta1)
	if(endIndex>=size1)
		endIndex=size1-1
	Endif
	
	if(startIndex>endIndex)
		print("Error: energyMin>energyMax")
		print("startIndex: "+num2str(startIndex))
		Print("endIndex: "+num2str(endIndex))
		abort
	Endif
	
	Make/O/D/N=(endIndex-startIndex+1,size2) $outputWave
	Wave/D output=$outputWave
	SetScale/P x, (offset1+startIndex*delta1), delta1, output
	SetScale/P y, offset2, delta2, output
	
	Variable i
	For(i=startIndex;i<=endIndex;i+=1)
		output[i-startIndex][]=input[i][q]
	Endfor
End


//cutEnergy2D: cut a 2D cube along energy direction
//Usage
//inputWave: name of the 2D input (E-k or E-theta)
//energyMin: minimum energy of the output
//energyMax: maximum energy
//outputWave: name of the output
//energy range of the output is the smallest range including [energyMin, energyMax]
Function cutEnergy2D_2(inputWave, momentMin, momentMax, outputWave)
	String inputWave
	String outputWave
	Variable momentMin, momentMax
	
	Wave/D input=$inputWave
	
	Print "[cutEnergy2D_2]"
	
	//energy row information
	Variable size1=DimSize(input,0) 
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	//angle1 column information
	Variable size2=DimSize(input,1)
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)

	Variable startIndex=ceil((momentMin-offset2)/delta2)
	if(startIndex<0)
		startIndex=0
	Endif
	
	Variable endIndex=floor((momentMax-offset2)/delta2)
	if(endIndex>=size2)
		endIndex=size2-1
	Endif
	
	if(startIndex>endIndex)
		print("Error: momentMin>momentMax")
		print("startIndex: "+num2str(startIndex))
		Print("endIndex: "+num2str(endIndex))
		abort
	Endif
	
	Make/O/D/N=(size1,endIndex-startIndex+1) $outputWave
	Wave/D output=$outputWave
	SetScale/P x, offset1, delta1, output
	SetScale/P y, (offset2+startIndex*delta2), delta2, output
	
	Variable i
	For(i=startIndex;i<=endIndex;i+=1)
		output[][i-startIndex]=input[p][i]
	Endfor
End