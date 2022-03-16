#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//add menuitem
Menu "hdf5Loader_PAD"
	"Load .hdf5 File", loadHDF5File_PAD()
	"Load .hdf5 Folder", loadHDF5Folder_PAD()
End

//Load .hdf5 File
Function loadHDF5File_PAD()
	Variable flag
	//Dialog 1: Select Data Folder
	NewPath/O/Q/M="Select Data Folder" folderPath
	If(V_flag!=0)
		//failed(or canceled)
		abort
	Endif
	
	//Dialog 2: Select File
	String fileName
	Prompt fileName, "File Name", popup, IndexedFile(folderPath, -1, ".hdf5")
	DoPrompt "Select .hdf5 File", fileName
	If(V_flag!=0)
		//canceled
		abort
	Endif
	
	//set folder path to global variable folderPath
	PathInfo folderPath
	String/G folderPath=S_Path
	
	convertHDF5File_PAD(fileName)
End

//Load all .hdf5 File in the folder
Function loadHDF5Folder_PAD()
	Variable flag
	//Dialog 1: Select Data Folder
	NewPath/O/Q/M="Select Data Folder" folderPath
	If(V_flag!=0)
		//failed(or canceled)
		abort
	Endif
	
	
	String hdf5FilesList=IndexedFile(folderPath, -1, ".hdf5")
	Variable num=ItemsInList(hdf5FilesList)
	//set folder path to global variable folderPath
	PathInfo folderPath
	String/G folderPath=S_Path
	
	Variable i
	For(i=0;i<num;i+=1)
		String fileName=StringFromList(i, hdf5FilesList)
		convertHDF5File_PAD(fileName)
	Endfor
End

//convert .hdf5 file to global variables, waves
Function convertHDF5File_PAD(fileName)
	String fileName
	Variable au_ang=0.529177
	
	SVAR folderPath=folderPath
	String dataName=replaceString("-",replaceString(".hdf5",fileName,""),"")
	Print("Load "+fileName)
	
	Variable fileID
	NewPath/O/Q folderPath folderPath
	
	HDF5OpenFile/P=folderPath fileID as fileName

	String dataPath="Dispersion"
	String rootGroup="/"
	
	// get dimension of reciprocal space (1 or 2)
	HDF5LoadData/Q/O/N=tempAttribute/A="Dimension"/TYPE=1 fileID, rootGroup
	Wave/D tempAtt=tempAttribute
	Variable dimension=tempAtt[0]
		
	// data
	HDF5LoadData/Q/O/N=tempCube fileID, dataPath
	If(V_Flag!=0)
		Print("Error: data (count) not found")
		return 0
	Endif
	Wave/D tempCube=tempCube
	
	// offset
	HDF5LoadData/Q/O/N=tempAttribute/A="Offset"/TYPE=1 fileID, rootGroup
	Wave/D tempAtt=tempAttribute
	Variable offsetKx, offsetKy, offsetE
	offsetKx=tempAtt[0]/au_ang
	if(dimension==2)
		offsetKy=tempAtt[1]/au_ang
		offsetE=tempAtt[2]
	else
		offsetE=tempAtt[1]
	endif
	
	// delta
	HDF5LoadData/Q/O/N=tempAttribute/A="Delta"/TYPE=1 fileID, rootGroup
	Wave/D tempAtt=tempAttribute
	Variable deltaKx, deltaKy, deltaE
	deltaKx=tempAtt[0]/au_ang
	if(dimension==2)
		deltaKy=tempAtt[1]/au_ang
		deltaE=tempAtt[2]	
	else
		deltaE=tempAtt[1]
	endif
	
	// size
	HDF5LoadData/Q/O/N=tempAttribute/A="Size"/TYPE=1 fileID, rootGroup
	Variable sizeKx, sizeKy, sizeE
	sizeKx=tempAtt[0]
	if(dimension==2)
		sizeKy=tempAtt[1]
		sizeE=tempAtt[2]
	else
		sizeE=tempAtt[1]
	endif
	
	if(dimension==2)
		Make/O/D/N=(sizeE, sizeKx, sizeKy) $dataName
		Wave/D data=$dataName
		data[][][]=tempCube[q][r][p]
		setScale/P x, offsetE, deltaE, data
		setScale/P y, offsetKx, deltaKx, data
		setScale/P z, offsetKy, deltaKy, data
	else
		Make/O/D/N=(sizeE, sizeKx) $dataName
		Wave/D data=$dataName
		data[][]=tempCube[q][p]
		setScale/P x, offsetE, deltaE, data
		setScale/P y, offsetKx, deltaKx, data
	endif	
	killWaves tempCube, tempAtt


End
