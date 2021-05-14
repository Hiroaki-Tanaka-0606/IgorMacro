#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//add menuitem
Menu "h5Loader_SSRL"
	"Load .h5 File", loadH5File_SSRL()
	"Load .h5 Folder", loadH5Folder_SSRL()
End

//Load .h5 File
Function loadH5File_SSRL()
	Variable flag
	//Dialog 1: Select Data Folder
	NewPath/O/Q/M="Select Data Folder" folderPath
	If(V_flag!=0)
		//failed(or canceled)
		abort
	Endif
	
	//Dialog 2: Select File
	String fileName
	Prompt fileName, "File Name", popup, IndexedFile(folderPath, -1, ".h5")
	DoPrompt "Select .h5 File", fileName
	If(V_flag!=0)
		//canceled
		abort
	Endif
	
	//set folder path to global variable folderPath
	PathInfo folderPath
	String/G folderPath=S_Path
	
	convertH5File_SSRL(fileName)
End

//Load all .h5 File in the folder
Function loadH5Folder_SSRL()
	Variable flag
	//Dialog 1: Select Data Folder
	NewPath/O/Q/M="Select Data Folder" folderPath
	If(V_flag!=0)
		//failed(or canceled)
		abort
	Endif
	
	
	String h5FilesList=IndexedFile(folderPath, -1, ".h5")
	Variable num=ItemsInList(h5FilesList)
	//set folder path to global variable folderPath
	PathInfo folderPath
	String/G folderPath=S_Path
	
	Variable i
	For(i=0;i<num;i+=1)
		String fileName=StringFromList(i, h5FilesList)
		converth5File_SSRL(fileName)
	Endfor
End

//convert .h5 file to global variables, waves
Function convertH5File_SSRL(fileName)
	String fileName
	SVAR folderPath=folderPath
	String dataName=replaceString("-",replaceString(".h5",fileName,""),"")
	Print("Load "+fileName)
	
	Variable fileID
	NewPath/O/Q folderPath folderPath
	
	HDF5OpenFile/P=folderPath fileID as fileName

	String dataGroup="Data"
	String dataName1=dataGroup+"/Count"
	String dataName2=dataGroup+"/Time"
	
	//get dimension
	HDF5LoadData/Q/O/N=tempAttribute/A="Dimension"/TYPE=1 fileID, dataGroup
	Wave/D tempAtt=tempAttribute
	Variable dimension=tempAtt[0]
	
	//necessary data
	HDF5LoadData/Q/O/N=$dataName fileID, dataName1
	If(V_Flag!=0)
		Print("Error: data (count) not found")
		return 0
	Endif
	
	//necessary for 2D and 3D data
	if(dimension<4)
		HDF5LoadData/Q/O/N=data2 fileID, dataName2
		If(V_Flag!=0)
			Print("Error: data2 (Time) not found")
			return 0
		Endif
	endif
	
	Wave/D data=$dataname
	Wave/D data2=data2
	
	switch(dimension)
		case 2:
			data[][]/=(data2[p][q]==0?1:data2[p][q])
			break
		case 3:
			data[][][]/=(data2[p][q][r]==0?1:data2[p][q][r])
			break
		case 4:
			break
	endswitch
	
	//scale
	Variable i
	Variable offset,delta
	for(i=0;i<dimension;i+=1)	
		HDF5LoadData/Q/O/N=tempAttribute/A="Offset"/TYPE=1 fileID, dataGroup+"/Axes"+num2str(i)
		Wave/D tempAtt=tempAttribute
		offset=tempAtt[0]
		HDF5LoadData/Q/O/N=tempAttribute/A="Delta"/TYPE=1 fileID, dataGroup+"/Axes"+num2str(i)
		Wave/D tempAtt=tempAttribute
		delta=tempAtt[0]
		switch(i)
			case 0:
				SetScale/P x, offset, delta, data
				break
			case 1:
				SetScale/P y, offset, delta, data
				break
			case 2:
				SetScale/P z, offset, delta, data
				break
			case 3:
				SetScale/P t, offset, delta, data
				break
		endswitch
	endfor
	
	KillWaves data2,tempAtt
	
	//set scale

End
