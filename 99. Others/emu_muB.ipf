#pragma rtGlobals=1		// Use modern global access method.

//emu_muB: convert [emu] to [muB/f.u.]
//Usage
//waveName: wave name of measurement data (input)
//waveName2: wave name of rescaled data (output)
//mass: weight of the sample [g]
//formulaWeight: formula weight of the sample [g/mol]

Function emu_muB(waveName, waveName2, mass, formulaWeight)
	String waveName,waveName2
	Variable mass, formulaWeight
	
	Wave/D momentWave=$waveName
	Variable size=DimSize(momentWave,0)
	
	Make/O/D/N=(size) $waveName2
	Wave/D momentWave2=$waveName2
	
	print("[emu_muB]")
	Variable me=9.1094e-28 // mass of electron [g]
	Variable hbar=1.0546e-27 // Dirac constant [g cm^2 s^-1]
	Variable ec=1.6022e-20 // elementary charge / speed of light [esu cm^-1 s]
	Variable avogadro=6.0221e23 //Avogadro constant [mol^-1]
	//muB=e hbar / 2 m c
	
	momentWave2[]=momentWave[p]/(mass/formulaWeight*avogadro)/(ec*hbar/(2*me))
End

//subtractBackground: subtract background magnetic moment
//Usage
//inputWave: wave name of measument data (input)
//backgroundWave: wave name of background data (input)
//size of inputWave, backgroundWave must be the same
//outputWave: wave name of output data (input)
//output[]=input[]-background[]
Function  subtractBackground(inputWave, backgroundWave, outputWave)
	String inputWave, backgroundWave, outputWave
	
	Wave/D input=$inputWave
	Wave/D background=$backgroundWave

	Variable size1=DimSize(input,0)
	Variable size2=DimSize(background,0)
	
	print("[subtractBackground]")
	if(size1!=size2)
		print("error: size of input and background is different")
		abort
	endif
	Make/O/D/N=(size1) $outputWave
	Wave/D output=$outputWave
	
	output[]=input[p]-background[p]

End
