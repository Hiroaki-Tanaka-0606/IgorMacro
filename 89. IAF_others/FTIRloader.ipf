#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Menu "FTIRloader"
	"Load folder", FTIR_loadFolder()
End

// load all csv files as matrices in the selected folder
// [0] -> X wavenumber [cm^-1]
// [1] -> Y reflectance [%]
Function FTIR_loadFolder()
	// Prompt window to select the folder
	NewPath/O/Q/M="Select data folder" dataFolder
	If(V_flag!=0)
		abort
	Endif
	
	PathInfo dataFolder
	String folderPath=S_path
	
	// List of csv files
	String csvFileList=IndexedFile(dataFolder, -1, ".csv")
	Variable numFiles=ItemsInList(csvFileList)
	
	Make/O/T/N=(numFiles) List_files
	
	Wave/T fList=List_files
	// load files
	Variable i
	For(i=0; i<numFiles; i+=1)
		String fileName=StringFromList(i, csvFileList)
		FTIR_loadFile(folderPath, fileName)
		fList[i]=ReplaceString(".csv", fileName, "")
	Endfor
End

Function FTIR_loadFile(folderPath_str, fileName)
	String folderPath_str, fileName
	
	NewPath/Q/O folderPath, folderPath_str	
	LoadWave/D/Q/G/M/P=folderPath fileName
	
	String loadedName=S_waveNames
	Wave/D loaded=$(StringFromList(0, loadedName))
	Duplicate/O loaded, $(ReplaceString(".csv", fileName, ""))
	
	KillWaves loaded
End