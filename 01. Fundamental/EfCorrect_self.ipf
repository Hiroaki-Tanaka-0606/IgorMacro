#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#include "FermiEdgeFitting"

//with dialog for threshold
Function EfCorrect3D_self_dialog(inputWave, width,temperature, holdParams, outputWave)
	Variable width, temperature
	String inputWave, outputWave, holdParams
	
	EfCorrect3D_self(inputWave,-1,width,temperature,holdParams,outputWave)
	Wave/D temp=tempSlice
	Display temp
	String windowName=S_name
	
	Variable threshold
	Prompt threshold, "Threshold"
	DoPrompt "Input threshold", threshold
	If(V_flag==0)
		EfCorrect3D_self(inputWave,threshold,width,temperature,holdParams,outputWave)
	Endif
	KillWindow $windowName
	
End

//with dialog for threshold
Function EfCorrect2D_self_dialog(inputWave, width,temperature, holdParams, outputWave)
	Variable width, temperature
	String inputWave, outputWave, holdParams
	
	EfCorrect2D_self(inputWave,-1,width,temperature,holdParams,outputWave)
	Wave/D temp=tempSlice
	Display temp
	String windowName=S_name
	
	Variable threshold
	Prompt threshold, "Threshold"
	DoPrompt "Input threshold", threshold
	If(V_flag==0)
		EfCorrect2D_self(inputWave,threshold,width,temperature,holdParams,outputWave)
	Endif
	KillWindow $windowName
	
End


//EfCorrect3D_self: correct Fermi edge from the integrated EDC of itself
Function EfCorrect3D_self(inputWave, threshold, width, temperature, holdParams, outputWave)
	Variable width, threshold, temperature
	String inputWave, outputWave, holdParams
	
	Wave/D input=$inputWave	


	Print("[EfCorrect3D_self]")
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
	

	
	Make/O/D/N=(size1) tempSlice
	Wave/D tempSlice=tempSlice
	SetScale/P x, offset1, delta1, tempSlice
	tempSlice[]=0
	
	Variable i,j
	For(i=0;i<size2;i+=1)
		For(j=0;j<size3;j+=1)
			tempSlice[]+=input[p][i][j]
		Endfor
	Endfor
	
	If(threshold<0)
		return 0
	Endif
	
	Variable EdgeApprox=-1
	For(i=size1-1;i>=0;i-=1)
		If(tempSlice[i]>threshold)
			EdgeApprox=i
			break
		Endif
	Endfor
	
	If(EdgeApprox<0)
		Print("Error: cant'find the approxmiate edge")
		abort
	Endif
	
	Variable startIndex=EdgeApprox-round(width/delta1)
	Variable endIndex=EdgeApprox+round(width/delta1)
	Make/O/D/N=(endIndex-startIndex+1) tempSlice2
	Wave/D tempSlice2=tempSlice2
	SetScale/P x, (offset1+startIndex*delta1),delta1, tempSlice2
	For(i=startIndex;i<=endIndex;i+=1)
		tempSlice2[i-startIndex]=tempSlice[i]
	Endfor
	
	//Config
	Make/O/D/N=4 $"Config"
	Wave/D conf=$"Config"
	conf[]=0

	//Param
	Make/O/D/N=6 $"Parameters"
	Wave/D param=$"Parameters"

	EfFitting("tempslice2",temperature,holdParams,0)
	
	Variable/G ef=param[4]
	Variable/G fwhm=param[5]

	Duplicate/O $inputWave $outputWave
	Wave/D output=$outputWave
	SetScale/P x, (offset1-ef), delta1, output
End

//EfCorrect2D_self: correct Fermi edge from the integrated EDC of itself
Function EfCorrect2D_self(inputWave, threshold, width, temperature, holdParams, outputWave)
	Variable width, threshold, temperature
	String inputWave, outputWave, holdParams
	
	Wave/D input=$inputWave	


	Print("[EfCorrect2D_self]")
	//energy row information
	Variable size1=DimSize(input,0) 
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	//angle column information
	Variable size2=DimSize(input,1)
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	

	
	Make/O/D/N=(size1) tempSlice
	Wave/D tempSlice=tempSlice
	SetScale/P x, offset1, delta1, tempSlice
	tempSlice[]=0
	
	Variable i
	For(i=0;i<size2;i+=1)
		tempSlice[]+=input[p][i]
	Endfor
	
	If(threshold<0)
		return 0
	Endif
	
	Variable EdgeApprox=-1
	For(i=size1-1;i>=0;i-=1)
		If(tempSlice[i]>threshold)
			EdgeApprox=i
			break
		Endif
	Endfor
	
	If(EdgeApprox<0)
		Print("Error: cant'find the approxmiate edge")
		abort
	Endif
	
	Variable startIndex=EdgeApprox-round(width/delta1)
	Variable endIndex=EdgeApprox+round(width/delta1)
	if(startIndex<0)
		startIndex=0
	endif
	if(endIndex>=size1)
		endIndex=size1-1
	endif
	Make/O/D/N=(endIndex-startIndex+1) tempSlice2
	Wave/D tempSlice2=tempSlice2
	SetScale/P x, (offset1+startIndex*delta1),delta1, tempSlice2
	For(i=startIndex;i<=endIndex;i+=1)
		tempSlice2[i-startIndex]=tempSlice[i]
	Endfor
	
	//Config
	Make/O/D/N=4 $"Config"
	Wave/D conf=$"Config"
	conf[]=0

	//Param
	Make/O/D/N=6 $"Parameters"
	Wave/D param=$"Parameters"

	EfFitting("tempslice2",temperature,holdParams,0)
	
	Variable/G ef=param[4]
	Variable/G fwhm=param[5]

	Duplicate/O $inputWave $outputWave
	Wave/D output=$outputWave
	SetScale/P x, (offset1-ef), delta1, output
End