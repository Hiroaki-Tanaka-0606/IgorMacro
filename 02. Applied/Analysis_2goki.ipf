#pragma rtGlobals=3		// Use modern global access method and strict wave access.

#include "AuNormalize"
#include "BackGroundFilter"
#include "SliceNormalize"
#include "Composite3D"

//correct3D_2goki: correct ef & normalize 3D measurement data
//Usage
//inputWave: wave name of measurement data (E-k-k) (input)
//outputWave: wave name of corrected measurement data (output)
//2D slice input[][][i] is corrected
Function correct3D_2goki(inputWave, outputWave)
	String inputWave, outputWave
	String currentDataFolderName=GetDataFolder(0)
	String currentDataFolderPath=GetDataFolder(1)
	
	String filteredWave="tempFiltered"
	String normalizedWave="tempNormalized"
	
	cd root:
	SVAR efWave=efWave, intensityWave=intensityWave
	NVAR aboveEf=aboveEf
	cd currentDataFolderPath
	//BackgroundFilter
	BackGroundFilter3D(inputWave,aboveEf,filteredWave)
	//Normalize
	AuNormalize3D(filteredWave, intensityWave, intensityWave, 0, normalizedWave)
	//Ef correction
	AuEfCorrect3D(normalizedWave,efWave,outputWave)
	
	Wave/D filtered=$filteredWave
	Wave/D normalized=$normalizedWave
	KillWaves filtered, normalized
End


//correct2D_2goki: correct ef & normalize 2D measurement data
//Usage
//inputWave: wave name of measurement data (E-k) (input)
//folder: folder name for corrected measurement data (input)
//suffix: suffix of wave name of corrected measurement data (input)
//folder should be already created
//corrected measurement data is created in folder "root:"+prefix, named currentDataFolder+suffix

Function correct2D_2goki(inputWave, folder, suffix)
	String inputWave, folder,suffix
	String currentDataFolderName=GetDataFolder(0)
	String currentDataFolderPath=GetDataFolder(1)
	
	String filteredWave,normalizedWave,outputWave
	
	If(cmpstr(folder,"")!=0)
		filteredWave="root:"+folder+":tempFiltered"
		normalizedWave="root:"+folder+":tempNormalized"
		outputWave="root:"+folder+":"+currentDataFolderName+suffix
	Else
		filteredWave="root:tempFiltered"
		normalizedWave="root:tempNormalized"
		outputWave="root:"+currentDataFolderName+suffix
	Endif
	
	cd root:	
	SVAR efWave=efWave, intensityWave=intensityWave
	NVAR aboveEf=aboveEf
	cd currentDataFolderPath
	//BackgroundFilter
	BackGroundFilter2D(inputWave,aboveEf,filteredWave)
	//Normalize
	AuNormalize2D(filteredWave, intensityWave, intensityWave, 0, normalizedWave)
	//Ef correction
	AuEfCorrect2D(normalizedWave,efWave,outputWave)
	
	Wave/D filtered=$filteredWave
	Wave/D normalized=$normalizedWave
	KillWaves filtered, normalized
End

//Au_2goki: analyze Au measurement data for correction
//Usage
//inputWave: wave name of Au ARPES data (input)
//temp: measurement temperature [K]

//folder "root:Au" is created, data for correction is created in the folder

Function Au_2goki(inputWave,temp)
	Variable temp
	String inputWave
	String currentDataFolder=GetDataFolder(1)
	
	NewDataFolder/O root:Au
	Wave/D input=$inputWave
	String duplicateInput="root:Au:Au"
	Duplicate/O input, $duplicateInput
	
	cd root:
	String/G bgWave="root:Au:Au_bg"
	String/G efWave="root:Au:Au_ef"
	String/G fwhmWave="root:Au:Au_fwhm"
	String/G intensityWave="root:Au:Au_intensity"
	Variable/G temperature=temp
	Variable/G aboveEf=2.67

	AuAnalyze(duplicateInput,temperature,bgWave,efWave,fwhmWave,"000000")
	AuIntensity(duplicateInput,bgWave,intensityWave)
	
	cd currentDataFolder
End