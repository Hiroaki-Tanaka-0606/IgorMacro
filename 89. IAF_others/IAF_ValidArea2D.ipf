
//Function ValidArea2D: determine valid area of 2D (theta_x-theta_y) map
Function/S IAFf_ValidArea2D_Definition()
	return "2;0;1;Wave2D;Wave2D"
End

Function IAFf_ValidArea2D(argumentList)
	String argumentList
	
	//0th argument: input
	String inputArg=StringFromList(0,argumentList)
	
	//1st argument: output, list of indices of valid area, [i][0]=x index, [i][1]=y index
	String outputArg=StringFromList(1,argumentList)
	
	Wave/D input=$inputArg
	Variable size1=DimSize(input,0)
	Variable size2=DimSize(input,1)
	Variable numPoints=size1*size2
	
	Make/O/D/N=(numPoints,2) $outputArg
	Wave/D output=$outputArg
	
	Variable index=0
	Variable i,j
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2;j+=1)
			//positive intensity -> valid, negative intensity ->invalid
			if(input[i][j]>0)
				output[index][0]=i
				output[index][1]=j
				index+=1
			endif
		endfor
	endfor
	
	Deletepoints index, numPoints-index, output
End