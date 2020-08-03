#pragma rtGlobals=3		// Use modern global access method and strict wave access.

// Data load macros for MBS A1 analyzer

// Process
// MBSA1_setPath(): select the folder from which measurement data are loaded, store the path of the folder to root:MBSA1_path (global text)

// MBSA1_load2D(fileName): load the data file named filename+".txt"
// MBSA1_load3D(filePrefix, numFiles, yOffset, yDelta, ySize): load the data files named filePrefix+"_"+i+".txt" (i=0,1, ... ySize), combine them to one 3D cube

// in MBSA1_load2D and MBSA1_load3D, if root:MBSA1_path does not exist they call MBSA1_setPath().

Function MBSA1_setPath()
	// current folder
	String currentDataFolder=GetDataFolder(1)
	// Prompt window to select the folder to be used
	NewPath/O/Q/M="Select data folder" path
	If(V_flag!=0)
		// Prompt failed or canceled
		abort
	Endif
	// Store path to root:MBSA1_path
	PathInfo path
	if(V_flag==0)
		Print("MBSA1_setPath Error: symbolic path does not exist")
		abort
	endif
		cd root:
	String/G MBSA1_path=S_path
	cd $currentDataFolder
End

Function MBSA1_load2D(fileName)
	String fileName
	
	// get folder path from root:MBSA1_path
	SVAR folderPath_String=root:MBSA1_path
	// if root:MBSA1_path does not exist, call MBSA1_setPath()
	if(!SVAR_exists(folderPath_String))
		MBSA1_setPath()
	Endif
	SVAR folderPath_String=root:MBSA1_path
	NewPath/Q/O folderPath, folderPath_String
	
	// create new folder to store wave and move to the folder
	NewDataFolder/O/S $fileName
	
	// Load wave
	String NoteName=fileName+"_Note"
	String MatrixName=fileName+"_Matrix"
	String fileName_full=fileName+".txt"
	// delimited text (tab)
	// Note0: first column, Note1: second column
	LoadWave/J/Q/K=2/N=$NoteName/P=folderPath fileName_full
	If(V_flag!=2)
		Print("MBSA1_load2D Error: LoadWave failed")
		cd ::
		abort
	Endif
	// general text (format information rows are neglected)
	// Matrix0: matrix data
	LoadWave/Q/G/M/N=$MatrixName/P=folderPath fileName_full
	If(V_flag!=1)
		Print("MBSA1_load2D Error: LoadWave failed")
		cd ::
		abort
	Endif
	
	Wave/T note0=$(NoteName+"0")
	Wave/T note1=$(NoteName+"1")
	Wave/D matrix0=$(MatrixName+"0")
	// find "DATA:" row in Note0
	Variable i
	Variable numNotes=-1
	For(i=0;i<DimSize(note0,0);i+=1)
		If(GrepString(note0[i], "(?i)^DATA:"))
			numNotes=i
			break
		Endif
	Endfor
	If(numNotes>0)
		// Delete rows after "DATA:" in Note0 and Note1
		Redimension/N=(numNotes) note0
		Redimension/N=(i) note1
	Endif
	
	// Add notes from note0 and note1
	For(i=0;i<numNotes;i+=1)
		Note matrix0 note0[i]+"\t"+note1[i]
	Endfor
	
	// Get EOffset ("Start K.E."), EDelta ("Step Size"), ThetaOffset("ScaleMin"), ThetaDelta("ScaleMult")
	Variable EOffset=NaN, EDelta=NaN, ThetaOffset=NaN, ThetaDelta=NaN
	For(i=0;i<numNotes;i+=1)
		If(GrepString(note0[i], "(?i)^Start K\.E\."))
			EOffset=str2num(note1[i])
		Endif
		If(GrepString(note0[i], "(?i)^Step Size"))
			EDelta=str2num(note1[i])
		Endif
		If(GrepString(note0[i], "(?i)^ScaleMin"))
			ThetaOffset=str2num(note1[i])
		Endif
		If(GrepString(note0[i], "(?i)^ScaleMult"))
			ThetaDelta=str2num(note1[i])
		Endif
	Endfor
	
	If(numtype(EOffset)!=0 || numtype(EDelta)!=0)
		Print("MBSA1_load2D Error: can't get information about Energy range")
	Else
		SetScale/P x, EOffset, EDelta, matrix0
	Endif
	
	If(numtype(ThetaOffset)!=0 || numtype(ThetaDelta)!=0)
		Print("MBSA1_load2D Error: can't get information about theta range")
	Else
		SetScale/P y, ThetaOffset, ThetaDelta, matrix0
	Endif			
	
	// remove note0 and note1
	KillWaves note0, note1
	
	// rename matrix0 to fileName
	// if a wave named fileName exists, it is removed
	Wave/D temp=$fileName
	If(WaveExists(temp))
		KillWaves temp
	Endif
	Rename matrix0 $fileName
	
	// go back to the current folder
	cd ::
End

Function MBSA1_load3D(filePrefix, yOffset, yDelta, ySize)
	String filePrefix
	Variable yOffset, yDelta, ySize
	
	// create new folder and move
	NewDataFolder/O/S $filePrefix
	
	// load 2D waves using MBSA1_load2D
	Variable i
	For(i=0;i<ySize;i+=1)
		String fileName=filePrefix+"_"+num2str(i)
		MBSA1_load2D(fileName)
	Endfor
	
	// use i=0 as reference
	Wave/D firstCut=$(":"+filePrefix+"_0:"+filePrefix+"_0")
	// 1st index (Energy)
	Variable EOffset=DimOffset(firstCut,0)
	Variable EDelta=DimDelta(firstCut,0)
	Variable ESize=DimSize(firstCut,0)
	// 2nd index (Theta_x)
	Variable xOffset=DimOffset(firstCut,1)
	Variable xDelta=DimDelta(firstCut,1)
	Variable xSize=DimSize(firstCut,1)
	// Make 3D cube
	Make/O/D/N=(ESize, xSize, ySize) $filePrefix
	Wave/D cube=$filePrefix
	SetScale/P x, EOffset, EDelta, cube
	SetScale/P y, xOffset, xDelta, cube
	SetScale/P z, yOffset, yDelta, cube
	
	// load 2D waves into the cube
	For(i=0;i<ySize;i+=1)
		fileName=filePrefix+"_"+num2str(i)
		Wave/D TwoDimCut=$(":"+fileName+":"+fileName)
		cube[][][i]=TwoDimCut[p][q]
	Endfor
	
	cd ::
End