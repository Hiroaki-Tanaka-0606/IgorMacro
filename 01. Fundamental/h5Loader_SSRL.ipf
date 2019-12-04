#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//add menuitem
Menu "h5Loader_SSRL"
	"Load .h5 File", loadH5File_SSRL(0)
	"Load .h5 Folder", loadH5Folder_SSRL(0)
End

//Load .h5 File
Function loadH5File_SSRL(flag)
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
	
	convertH5File_SSRL(fileName,flag)
End

//Load all .h5 File in the folder
Function loadH5Folder_SSRL(flag)
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
		converth5File_SSRL(fileName,flag)
	Endfor
End

//convert .h5 file to global variables, waves
Function convertH5File_SSRL(fileName,flag)
	Variable flag
	String fileName
	String currentDataFolder=GetDataFolder(1)
	SVAR folderPath=folderPath
	String dataFolderName=replaceString("-",replaceString(".h5",fileName,""),"")
	If(DataFolderExists(dataFolderName))
		Print("Warning: Data Folder "+dataFolderName+" exists.")
		return 0
	Endif
	Print("Load "+fileName)
	NewDataFolder $dataFolderName
	cd $dataFolderName
	
	Variable fileID
	NewPath/O/Q folderPath folderPath
	
	HDF5OpenFile/P=folderPath fileID as fileName

	String dataGroup="Data"
	String dataName=dataGroup+"/Count"
	String xGroup=dataGroup+"/Axes0"
	String yGroup=dataGroup+"/Axes1"
	String zGroup=dataGroup+"/Axes2"
	String loadAttributeGroupList="Beamline;Measurement"
	
	//necessary data
	HDF5LoadData/Q/O/N=data fileID, dataName
	If(V_Flag!=0)
		Print("Error: data not found")
		return 0
	Endif

	
	Variable i,j
	Struct HDF5DataInfo di
	InitHDF5DataInfo(di)
	String preview
	Variable numAttributeGroups=ItemsInList(loadAttributeGroupList)
	For(i=0;i<numAttributeGroups;i+=1)
		String attributeGroup=StringFromList(i,loadAttributeGroupList)
		HDF5ListAttributes/TYPE=1 fileID, attributeGroup
		String attributes=S_HDF5ListAttributes
		Variable numAttributes=ItemsInList(attributes)
		For(j=0;j<numAttributes;j+=1)
			String attribute=StringFromList(j,attributes)
			HDF5AttributeInfo(fileID,attributeGroup,1,attribute,0,di)
			preview=GetPreviewString(fileID,1,di,attributeGroup,attribute)
			strswitch(di.datatype_class_str)
				case "H5T_INTEGER":
				case "H5T_FLOAT":
				case "H5T_ENUM":
				case "H5T_OPAQUE":
				case "H5T_BITFIELD":
					Variable/G $attribute=str2num(preview)
					break
				case "H5T_REFERENCE":
				case "H5T_STRING":
					String/G $attribute=preview
					break
				case "H5T_TIME":
				case "H5T_COMPOUND":
				case "H5T_VLEN":
				case "H5T_ARRAY":
					continue
					break
			endswitch
		Endfor
	Endfor
	//dimension of the data
	HDF5AttributeInfo(fileID,dataGroup,1,"Dimension",0,di)
	preview=GetPreviewString(fileID,1,di,dataGroup,"Dimension")
	Variable dimension=str2num(preview)
	
	Wave/D data=data
	
	If(dimension>2)
		//transpose x and z
		If(flag==1)
			Variable numPolars=dimSize(data,0)
			Variable numAngles=dimSize(data,1)
			Variable numEnergies=dimSize(data,2)
			Make/O/D/N=(numEnergies,numAngles,numPolars) $dataFolderName
			Wave/D newData=$dataFolderName
			newData[][][]=data[r][q][p]
		else
			MatrixOp/O $dataFolderName=transposeVol(data,3)
			Wave/D newData=$dataFolderName
		Endif
	Else
		//duplicate
		Duplicate/O data $dataFolderName
		Wave/D newData=$dataFolderName
	Endif
	
	
	KillWaves data
	
	//first dimension
	HDF5AttributeInfo(fileID,xGroup,1,"Offset",0,di)
	preview=GetPreviewString(fileID,1,di,xGroup,"Offset")
	Variable offset1=str2num(preview)
	HDF5AttributeInfo(fileID,xGroup,1,"Delta",0,di)
	preview=GetPreviewString(fileID,1,di,xGroup,"Delta")
	Variable delta1=str2num(preview)
	SetScale/P x, offset1, delta1, newData
	
	//second dimension
	HDF5AttributeInfo(fileID,yGroup,1,"Offset",0,di)
	preview=GetPreviewString(fileID,1,di,yGroup,"Offset")
	Variable offset2=str2num(preview)
	HDF5AttributeInfo(fileID,yGroup,1,"Delta",0,di)
	preview=GetPreviewString(fileID,1,di,yGroup,"Delta")
	Variable delta2=str2num(preview)
	SetScale/P y, offset2, delta2, newData
	
	If(dimension>2)
		//third dimension
		HDF5AttributeInfo(fileID,zGroup,1,"Offset",0,di)
		preview=GetPreviewString(fileID,1,di,zGroup,"Offset")
		Variable offset3=str2num(preview)
		HDF5AttributeInfo(fileID,zGroup,1,"Delta",0,di)
		preview=GetPreviewString(fileID,1,di,zGroup,"Delta")
		Variable delta3=str2num(preview)
		SetScale/P z, offset3, delta3, newData
	Endif
	
	cd $currentDataFolder
End
