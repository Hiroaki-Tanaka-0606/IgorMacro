#pragma rtGlobals=1		// Use modern global access method.

//add menuitem
Menu "QDLoader"
	"Load QD File", loadQDFile()
	"Load QD Folder", loadQDFolder()
End


//Load QD Data File
Function loadQDFile()
	//Dialog 1: Select Data Folder
	NewPath/O/Q/M="Select Data Folder" folderPath
	If(V_flag!=0)
		//failed(or canceled)
		abort
	Endif
	
	//Dialog 2: Select File
	String fileName
	Prompt fileName, "File Name", popup, IndexedFile(folderPath, -1, ".dat")
	DoPrompt "Select .nxs File", fileName
	If(V_flag!=0)
		//canceled
		abort
	Endif
	
	//set folder path to global variable folderPath
	PathInfo folderPath
	String/G folderPath=S_Path
	
	convertQDFile(fileName)
End

//Load all QD File in the folder
Function loadQDFolder()
	//Dialog 1: Select Data Folder
	NewPath/O/Q/M="Select Data Folder" folderPath
	If(V_flag!=0)
		//failed(or canceled)
		abort
	Endif
	
	String QDFilesList=IndexedFile(folderPath, -1, ".dat")
	Variable num=ItemsInList(QDFilesList)
	//set folder path to global variable folderPath
	PathInfo folderPath
	String/G folderPath=S_Path
	
	Variable i
	For(i=0;i<num;i+=1)
		String fileName=StringFromList(i, QDFilesList)
		convertQDFile(fileName)
	Endfor
End

Function convertQDFile(fileName)
	String fileName
	String currentDataFolder=GetDataFolder(1)
	SVAR folderPath=folderPath
	String dataFolderName=replaceString("-",replaceString(".dat",fileName,""),"")
	If(DataFolderExists(dataFolderName))
		Print("Warning: Data Folder "+dataFolderName+" exists.")
		return 0
	Endif
	
	Print("Load "+fileName)
	NewDataFolder $dataFolderName
	cd $dataFolderName
	SVAR folderPath=folderPath
	Variable refNum
	Open/R/P=folderPath refNum as fileName
	
	Variable len
	Variable numLines=-1
	Variable inHeader=-1
	Variable inData=-1
	String buffer
	String commentColumnList=""
	String dataColumnList=""
	String timeColumnList=""
	String waveNameList
	Variable numWaves
	Variable numRows=0
	Variable i
	do
		numLines+=1
		FReadLine refNum, buffer
		if(strlen(buffer)==0)
			break
		endif
		buffer=replaceString("\r",buffer,"")
		buffer=replaceString("\n",buffer,"")
		if(cmpstr("[Header]",buffer)==0)
			inHeader=1
			inData=-1
			continue	
		endif
		if(cmpstr("[Data]",buffer)==0)
			inData=1
			inHeader=-1
			FReadLine refNum, buffer
			if(strlen(buffer)==0)
				Print("Error: no data")
				abort
			Endif
			buffer=replaceString("\r",buffer,"")
			buffer=replaceString("\n",buffer,"")
			waveNameList=replaceString(",",buffer,";")
			numWaves=ItemsInList(waveNameList)
			continue
		endif
		if(inHeader==1)
			buffer=replaceString(" ",buffer,"")
			buffer=replaceString(",",buffer,";")
			String command=StringFromList(0,buffer)
			String argument=StringFromList(1,buffer)
			if(cmpstr(command,"DATATYPE")==0)
				String columns=RemoveListItem(0,RemoveListItem(0,buffer))
				if(cmpstr(argument,"COMMENT")==0)
					commentColumnList=addListItem(columns,commentColumnList)
				elseif(cmpstr(argument,"DATA")==0)
					dataColumnList=addListItem(columns,dataColumnList)
				elseif(cmpstr(argument,"TIME")==0)
					timeColumnList=addListItem(columns,timeColumnList)
				endif
			Endif
			continue
		endif
		if(inData==1)
			buffer=replaceString(",",buffer,";")
			String tempWaveName="temp"+num2str(numRows)
			Make/O/T/N=(numWaves) $tempWaveName
			Wave/T temp=$tempWaveName
			For(i=0;i<numWaves;i+=1)
				temp[i]=StringFromList(i,buffer)
			Endfor
			numRows+=1
			continue
		endif
	While(1)
	
	//composite wave
	String waveName
	String physQuantity, Unit
	Variable isNumber=1
	Make/O/D/N=(numWaves) dataTypes
	Make/O/T/N=(numWaves) waveNames
	Wave/D dataTypes=dataTypes
	Wave/T waveNames=waveNames
	For(i=0;i<numWaves;i+=1)
		waveName=StringFromList(i,waveNameList)
		If(cmpstr(waveName,"Time")==0)
			waveName="_Time"
		ENdif
		waveNames[i]=waveName
		//type determination from wave name
		if(grepstring(waveName,"(?i)^COMMENT")==1)
			isNumber=0
		endif
		if(grepstring(waveName,"(?i)^TIME")==1)
			isNumber=1
		endif
		//type determination from DATATYPE
		if(whichListItem(num2str(i+1),commentColumnList)>=0)
			isNumber=0
		endif
		if(whichListItem(num2str(i+1),timeColumnList)>=0)
			isNumber=1
		endif	
		if(whichListItem(num2str(i+1),dataColumnList)>=0)
			isNumber=1
		endif
		dataTypes[i]=isNumber
		if(isNumber==1)
			Make/O/D/N=(numRows) $waveName
			Wave/D outputD=$waveName
		else
			Make/O/T/N=(numRows) $waveName
			Wave/T outputT=$waveName
		endif
	Endfor
	
	//set data to waves
	Variable j
	For(i=0;i<numRows;i+=1)
		tempWaveName="temp"+num2str(i)
		Wave/T temp=$tempWaveName
		For(j=0;j<numWaves;j+=1)
			If(dataTypes[j]==1)
				Wave/D outputD=$waveNames[j]
				outputD[i]=str2num(temp[j])
			Else
				Wave/T outputT=$waveNames[j]
				outputT[i]=temp[j]
			Endif
		Endfor
		KillWaves temp
	Endfor
	
	Print("Loaded "+num2str(numLines)+" lines, "+num2str(numWaves)+" waves, "+num2str(numRows)+" data")
	killwaves datatypes,waveNames
	cd currentDataFolder
End
