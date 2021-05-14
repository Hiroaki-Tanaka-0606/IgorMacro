#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#include "AuNormalize"

//create offset wave (average of offset is set to zero)
Function createOffsetWave(inputWave, outputWave)
	String inputWave,outputWave
	
	Wave/D input=$inputWave
	
	Print("[createOffsetWave]")
	//energy row information
	Variable size1=DimSize(input,0) 
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	
	Make/O/D/N=(size1) $outputWave
	Wave/D output=$outputWave
	SetScale/P x, offset1, delta1, output
	
	Variable sum=0
	Variable i
	For(i=0;i<size1;i+=1)
		sum+=input[i]
	Endfor
	Variable average=sum/size1
	
	output[]=input[p]-average
	
End


//correct ef with offset
Function EfCorrect3D_offset(inputWave, ef, offsetWave, outputWave)
	String inputWave,offsetWave,outputWave
	Variable ef
	Wave/D input=$inputWave
	Wave/D offset=$offsetWave
	
	Print("[EfCorrect3D_offset]")
	//angle column information
	Variable size1=DimSize(input,1) 
	Variable offset1=DimOffset(input,1)
	Variable delta1=DimDelta(input,1)
	
	Make/O/D/N=(size1) tempEf
	Wave/D temp=tempEf
	setScale/P x, offset1, delta1, temp
	
	temp[]=offset[p]+ef
	
	AuEfCorrect3D(inputWave,"tempEf",outputWave)
	
	KillWaves temp

End

//correct ef with offset
Function EfCorrect2D_offset(inputWave, ef, offsetWave, outputWave)
	String inputWave,offsetWave,outputWave
	Variable ef
	Wave/D input=$inputWave
	Wave/D offset=$offsetWave
	
	Print("[EfCorrect2D_offset]")
	//angle column information
	Variable size1=DimSize(input,1) 
	Variable offset1=DimOffset(input,1)
	Variable delta1=DimDelta(input,1)
	
	Make/O/D/N=(size1) tempEf
	Wave/D temp=tempEf
	setScale/P x, offset1, delta1, temp
	
	temp[]=offset[p]+ef
	
	AuEfCorrect2D(inputWave,"tempEf",outputWave)
	
	KillWaves temp

End