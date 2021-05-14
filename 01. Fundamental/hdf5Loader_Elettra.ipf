#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//add menuitem
Menu "HDF5Loader_Elettra"
	"Load .hdf5 File", loadHdf5File_Elettra()
	"Load .hdf5 Folder", loadHdf5Folder_Elettra()
End

//Load .nxs File
Function loadHdf5File_Elettra()
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
	
	convertHdf5File_Elettra(fileName)
End

//Load all .hdf5 File in the folder
Function loadHdf5Folder_Elettra()
	//Dialog 1: Select Data Folder
	NewPath/O/Q/M="Select Data Folder" folderPath
	If(V_flag!=0)
		//failed(or canceled)
		abort
	Endif
	
	
	String hdf5FilesList=IndexedFile(folderPath, -1, ".hdf5")
	Variable num=ItemsInList(hdf5fileslist)
	//set folder path to global variable folderPath
	PathInfo folderPath
	String/G folderPath=S_Path
	
	Variable i
	For(i=0;i<num;i+=1)
		String fileName=StringFromList(i, hdf5fileslist)
		convertHdf5File_Elettra(fileName)
	Endfor
End

//convert .hdf5 file to global variables, waves
Function convertHdf5File_Elettra(fileName)
	String fileName
	SVAR folderPath=folderPath
	String dataName=replaceString(".hdf5",fileName,"")
	Print("Load "+fileName)
	
	
	Variable fileID
	NewPath/O/Q folderPath folderPath		
	HDF5OpenFile/P=folderPath/R fileID as fileName

	//HDF5ListAttributes fileID, dataName
	//print S_HDF5listattributes
	
	Struct HDF5DataInfo di
	InitHDF5DataInfo(di)
	
	//load data
	HDF5LoadData/Q/N=$dataname/O fileID, dataname
	Wave/D loaded=$dataName
	
	//set scale
	String attributeName
	Variable dimension
	String preview
	Variable offset
	Variable delta
	String dim_name
	String dim_unit
	String dim_full
	for(dimension=0;dimension<4;dimension+=1)
		if(DimSize(loaded,dimension)>0)
			attributeName="Dim"+num2str(dimension)+" Values"
			HDF5LoadData/Q/A=attributeName/N=tempAttribute1/O fileID, dataname
			Wave/D tempAtt1=tempAttribute1
			offset=tempAtt1[0]
			delta=tempAtt1[1]
			
			attributeName="Dim"+num2str(dimension)+" Name Units"
			HDF5LoadData/Q/A=attributeName/N=tempAttribute2/O fileID, dataName
			Wave/T tempAtt2=tempAttribute2
			dim_name=tempAtt2[0]
			dim_unit=tempAtt2[1]
			dim_full=dim_name+" ("+dim_unit+")"
			if(dimension==0)
				setScale/P x, offset, delta, dim_full, loaded
			elseif(dimension==1)
				setScale/P y, offset, delta, dim_full,  loaded
			elseif(dimension==2)
				setScale/P z, offset, delta, dim_full,  loaded
			elseif(dimension==3)
				setScale/P t, offset, delta, dim_full,  loaded
			endif
		endif
	endfor
	
	//if dimension is higher than 2,
	//delete [0][][][] points
	if(DimSize(loaded,2)>0)
		Deletepoints/M=0 0,1,loaded
	endif
	
	//rescale by dividing #scans*dwell/sec
	attributeName="Dwell Time (s)"
	HDF5LoadData/Q/A=attributeName/N=tempAttribute1/O fileID, dataname
	Wave/D tempAtt1=tempAttribute1
	Variable dwell=tempAtt1[0]
	
	attributeName="N of Scans"
	HDF5LoadData/Q/A=attributeName/N=tempAttribute1/O fileID, dataname
	Wave/D tempAtt1=tempAttribute1
	Variable nScans=tempAtt1[0]
	loaded/=dwell*nScans
	
	
	HDF5closefile fileID
	KillWaves tempAtt1,tempAtt2
End