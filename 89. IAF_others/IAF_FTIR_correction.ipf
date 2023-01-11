#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Function RemoveCO2: remove co2 peak
Function/S IAFf_RemoveCO2_Definition()
	return "4;0;0;0;1;Wave2D;Variable;Variable;Wave2D"
End

Function IAFf_RemoveCO2(argumentList)
	String argumentList
	
	//0th argument: 2D wave, X=wavenumber, Y=reflectance
	String wavePathArg=StringFromList(0, argumentList)
	
	//1st and 2nd argument: start and end wavenumber of CO2 peak
	String CO2StartArg=StringFromList(1, argumentList)
	String CO2EndArg=StringFromList(2,argumentList)
	
	//3rd argument: output (corrected) wave
	String outputArg=StringFromList(3,argumentList)
	
	Wave/D input=$wavePathArg
	Duplicate/O input $outputArg
	Wave/D output=$outputArg
	
	NVAR CO2Start=$CO2StartArg
	NVAR CO2End=$CO2EndArg
	
	if(CO2Start>=CO2End)
		print("RemoveCO2 error: CO2Start is larger than CO2End")
		abort
	endif
	
	Variable num_points=DimSize(output, 0)
	Variable i
	//~~~Left_max < CO2Start ~~ < CO2End < Right_min~~~
	Variable Left_max=-1
	Variable Right_min=-1
	For(i=0; i<num_points; i+=1)
		if(output[i][0]>CO2Start && Left_max==-1)
			Left_max=i-1
		Endif
		if(output[i][0]>Co2End && Right_min==-1)
			Right_min=i
		Endif
		if(Left_max>=0 && Right_min>=0)
			break
		Endif
	Endfor
	
	Variable Left_X=output[Left_max][0]
	Variable Left_Y=output[Left_max][1]
	Variable Right_X=output[Right_min][0]
	Variable Right_Y=output[Right_min][1]
	
	For(i=Left_max+1; i<Right_Min; i+=1)
		Variable X=output[i][0]
		output[i][1]=(Left_Y*(Right_X-X)+Right_Y*(X-Left_X))/(Right_X-Left_X)
	Endfor
End


//Function DivideSpectrum: calculate A[][1] / B[][1]
//output[][0] is the same as A[][0]
Function/S IAFf_DivideSpectrum_Definition()
	return "3;0;0;1;Wave2D;Wave2D;Wave2D"
End

Function IAFf_DivideSpectrum(argumentList)
	String argumentList
	
	//0th argument: 2D wave A, X=wavenumber, Y=reflectance
	String AArg=StringFromList(0, argumentList)
	
	//1st argument: 2D wave B
	String BArg=StringFromList(1, argumentList)
	
	//2nd argument: output
	String outputArg=StringFromList(2, argumentList)
	
	Wave/D inputA=$AArg
	Wave/D inputB=$BArg
	
	if(DimSize(inputA,0)!=DimSize(inputB,0))
		print("DivideSpectrum error: size mismatch")
		abort
	Endif
	
	Duplicate/O inputA $outputArg
	Wave/D output=$outputArg
	
	output[][1]/=inputB[p][1]
	
End

//Function SmoothingSpectrum
Function/S IAFf_SmoothingSpectrum_Definition()
	return "3;0;0;1;Wave2D;Variable;Wave2D"
End

Function IAFf_SmoothingSpectrum(argumentList)
	String argumentList
	
	//0th argument: input
	String inputArg=StringFromList(0, argumentList)
	
	//1st argument: smoothing width
	String widthArg=StringFromList(1, argumentList)
	
	//2nd argument: output
	String outputArg=StringFromList(2,argumentList)
	
	Wave/D input=$inputArg
	NVAR width=$widthArg
	
	Variable num_points=Dimsize(input, 0)
	Make/O/D/N=(num_points-width,2) $outputArg
	Wave/D output=$outputArg
	
	Variable i,j
	For(i=0; i<num_points-width; i++)
		output[i][]=0
		For(j=0; j<=width; j++)
			output[i][]+=input[i+j][q]
		Endfor
		output[i][]/=(width+1)
		//output[i][1]-=30
		//output[i][1]*=10
	Endfor
End

//Function KK_phase: calculate the phase difference for the reflected light
//by Kramers-Kronig conversion and Maclaurin's method
Function/S IAFf_KK_phase_Definition()
	return "2;0;1;Wave2D;Wave2D"
End

Function IAFf_KK_phase(argumentList)
	String argumentList
	
	//0th argument: input (squared reflectance (%))
	String RArg=StringFromList(0,argumentList)
	
	//1st argument: output (phase (rad))
	String PArg=StringFromList(1,argumentList)
	
	Wave/D Reflectance=$RArg
	Duplicate/O Reflectance $PArg
	Wave/D Phase=$PArg
	
	Variable num_points=DimSize(Reflectance, 0)
	Variable i,j
	Variable start_j
	For(i=0; i<num_points; i+=1)
		Phase[i][1]=0
		If(mod(i,2)==0)
			//even
			start_j=1
		Else
			//odd
			start_j=2
		Endif
		//print(start_j)
		For(j=start_j; j<num_points-1; j+=2)
			Phase[i][1]+=(Phase[j+1][0]-Phase[j][0])*ln(sqrt(Reflectance[j][1]/100))/(Phase[j][0]^2-Phase[i][0]^2)
			//print((Phase[j+1][0]-Phase[j][0])*ln(sqrt(Reflectance[j][1])/10)/(Phase[j][0]^2-Phase[i][0]^2))
		Endfor
		Phase[i][1]*=(-4)*Phase[i][0]/Pi
	Endfor
	
End

//Function Refractive_index: calculate complex refractive index n+ik from reflectance and phase
Function/S IAFf_Refractive_index_Definition()
	return "3;0;0;1;Wave2D;Wave2D;Wave2D"
End

Function IAFf_Refractive_index(argumentList)
	String argumentList
	
	//0th argument: input (reflectance (%))
	String RArg=StringFromList(0,argumentList)
	
	//1st argument: input (phase (rad))
	String PArg=StringFromList(1,argumentList)
	
	//2nd argument: output (complex refractive index)
	String nArg=StringFromList(2,argumentList)
	
	Wave/D Reflectance=$RArg
	Wave/D Phase=$PArg

	if(DimSize(Reflectance,0)!=DimSize(Phase,0))
		print("Refractive_index error: Reflectance and Phase have different numbers of data")
		abort
	Endif
	
	Duplicate/O Reflectance $nArg
	Wave/D RefIndex=$nArg
	Redimension/N=(-1,3) RefIndex
	
	Variable i
	Variable num_points=DimSize(Reflectance,0)
	Variable R, phi
	For(i=0; i<num_points; i+=1)
		R=Reflectance[i][1]/100
		//print(R)
		phi=Phase[i][1]
		RefIndex[i][1]=(1-R)/(1+R+2*sqrt(R)*cos(phi))
		RefIndex[i][2]=(-2*sqrt(R)*sin(phi))/(1+R+2*sqrt(R)*cos(phi))
	Endfor
End

//Function Permittivity: calculate complex permittivity from complex refractive index
Function/S IAFf_Permittivity_Definition()
	return "2;0;1;Wave2D;Wave2D"
End

Function IAFf_Permittivity(argumentList)
	String argumentList
	
	//0th: input (complex refractive index)
	String nArg=StringFromList(0,argumentList)
	
	//1st: output (complex permittivity)
	String eArg=StringFromList(1,argumentList)
	
	Wave/D RefIndex=$nArg
	Duplicate/O RefIndex $eArg
	Wave/D Permit=$eArg
	
	Permit[][1]=RefIndex[p][1]^2-RefIndex[p][2]^2
	Permit[][2]=2*RefIndex[p][1]*RefIndex[p][2]
End

//Function DXFormat: convert the spectrum to DX format
Function/S IAFf_DXFormat_Definition()
	return "2;0;1;Wave2D;Wave2D"
End

Function IAFf_DXFormat(argumentList)
	String argumentList
	
	//0th: input
	String inputArg=StringFromList(0,argumentList)
	
	//1st: output
	String outputArg=StringFromList(1,argumentList)
	
	Wave/D input=$inputArg
	Variable size=DimSize(input,0)
	
	Variable dataPerRow=11
	Variable numRows=Ceil(size/dataPerRow)
	
	Make/O/D/N=(numRows, dataPerRow+1) $outputArg
	Wave/D output=$outputArg
	
	Variable i
	Variable row=0, column=0
	For(i=0; i<size; i+=1)
		if(column==0)
			output[row][0]=input[i][0]
		Endif
		output[row][column+1]=round(input[i][1]*1000)
		column+=1
		if(column==dataPerRow)
			column=0
			row+=1
		Endif
	Endfor
End

//Function joinNK: join n and k waves into complex refractive index
Function/S IAFf_joinNK_Definition()
	return "3;0;0;1;Wave2D;Wave2D;Wave2D"
End

Function IAFf_joinNK(argumentList)
	String argumentList
	
	//0th: n
	String nArg=StringFromList(0,argumentList)
	
	//1st: k
	String kArg=StringFromList(1,argumentList)
	
	//2nd: output
	String outputArg=StringFromList(2,argumentList)
	
	Wave/D n=$nArg
	Wave/D k=$kArg
	
	Duplicate/O n $outputArg
	Wave/D output=$outputArg
	Redimension/N=(-1,3) output
	output[][2]=k[p][1]
End
	
	
//Function OneDimensionalize: Convert 2D ([][0]=x, [][1]=y) to 1D ([]=y, x in offset, delta, size)
Function/S IAFf_OneDimensionalize_Definition()
	return "2;0;1;Wave2D;Wave1D"
End

Function IAFf_OneDimensionalize(argumentList)
	String argumentList
	
	//0th: input
	String inArg=StringFromList(0, argumentList)
	
	//1st: output
	String outArg=StringFromList(1, argumentList)
	
	Wave/D in=$inArg
	
	Variable size=DimSize(in, 0)
	
	Variable xOffset=in[0][0]
	Variable xLast=in[size-1][0]
	
	Make/O/D/N=(size) $outArg
	Wave/D out=$outArg
	SetScale/I x, xOffset, xLast, out
	out[]=in[p][1]
	
End