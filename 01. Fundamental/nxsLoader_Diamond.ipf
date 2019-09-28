#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//add menuitem
Menu "nxsLoader_Diamond"
	"Load .nxs File", loadNxsFile_Diamond()
	"Load .nxs Folder", loadNxsFolder_Diamond()
End

//Load .nxs File
Function loadNxsFile_Diamond()
	//Dialog 1: Select Data Folder
	NewPath/O/Q/M="Select Data Folder" folderPath
	If(V_flag!=0)
		//failed(or canceled)
		abort
	Endif
	
	//Dialog 2: Select File
	String fileName
	Prompt fileName, "File Name", popup, IndexedFile(folderPath, -1, ".nxs")
	DoPrompt "Select .nxs File", fileName
	If(V_flag!=0)
		//canceled
		abort
	Endif
	
	//set folder path to global variable folderPath
	PathInfo folderPath
	String/G folderPath=S_Path
	
	convertNxsFile_Diamond(fileName)
End

//Load all .nxs File in the folder
Function loadNxsFolder_Diamond()
	//Dialog 1: Select Data Folder
	NewPath/O/Q/M="Select Data Folder" folderPath
	If(V_flag!=0)
		//failed(or canceled)
		abort
	Endif
	
	
	String nxsFilesList=IndexedFile(folderPath, -1, ".nxs")
	Variable num=ItemsInList(nxsFilesList)
	//set folder path to global variable folderPath
	PathInfo folderPath
	String/G folderPath=S_Path
	
	Variable i
	For(i=0;i<num;i+=1)
		String fileName=StringFromList(i, nxsFilesList)
		convertNxsFile_Diamond(fileName)
	Endfor
End

//convert .nxs file to global variables, waves
Function convertNxsFile_Diamond(fileName)
	String fileName
	String currentDataFolder=GetDataFolder(1)
	SVAR folderPath=folderPath
	String dataFolderName=replaceString("-",replaceString(".nxs",fileName,""),"")
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

	String dataGroup="entry1/analyser/"
	String dataName=dataGroup+"data"
	String angleName=dataGroup+"angles"
	String sapolarName=dataGroup+"sapolar"
	String energiesName=dataGroup+"energies"
	String energyName=dataGroup+"energy"
	String startName="entry1/start_time"
	String endName="entry1/end_time"
	String temperatureName="entry1/sample/temperature"
	String energyName2="entry1/instrument/monochromator/energy"
	String polarizationName="entry1/instrument/insertion_device/beam/final_polarisation_label"
	
	Variable threeDMapping=0
	Variable kzMapping=0
	
	HDF5ListGroup fileID, dataGroup
	String dataNameList=S_HDF5ListGroup
	//Print(dataNameList)
	
	//necessary data
	HDF5LoadData/Q/O/N=data fileID, dataName
	If(V_Flag!=0)
		Print("Error: data not found")
		return 0
	Endif
	
	HDF5LoadData/Q/O/N=angles fileID, angleName
	If(V_Flag!=0)
		Print("Error: angles not found")
	Endif
	
	HDF5LoadData/Q/O/N=energies fileID, energiesName
	If(V_Flag!=0)
		Print("Error: energies not found")
	Endif

	//sapolar -> 3D mapping
	If(FindListItem("sapolar",dataNameList)!=-1)
		Print("3D mapping")
		threeDMapping=1
		HDF5LoadData/Q/O/N=sapolar fileID, sapolarName
		If(V_Flag!=0)
			Print("Error: sapolar not found")
		Endif
	Endif
	//energy -> kz mapping
	If(FindListItem("energy",dataNameList)!=-1)
		Print("kz mapping")
		kzMapping=1
		HDF5LoadData/Q/O/N=photon_energy fileID, energyName
		If(V_Flag!=0)
			Print("Error: energy not found")
		Endif
	Endif
	If(threeDMapping==kzMapping)
		If(threeDMapping==1)
			//3D & kz ?
			Print("Error: both sapolar and energy exist")
			return 0
		Else
			//2D
			Print("2D mapping")
		Endif
	Endif
	
	//environment data (not abort even if not found)
	HDF5LoadData/Q/O/N=start_time fileID, startName
	If(V_Flag!=0)
		Print("Error: start_time not found")
	Else
		Wave/T startWave=start_time
		String/G start_time=startWave[0]
		KillWaves startWave
	Endif
	
	HDF5LoadData/Q/O/N=end_time fileID, endName
	If(V_Flag!=0)
		Print("Error: end_time not found")
	Else
		Wave/T endWave=end_time
		String/G end_time=endWave[0]
		KillWaves endWave
	Endif
	
	HDF5LoadData/Q/O/N=temperature fileID, temperatureName
	If(V_Flag!=0)
		Print("Error: temperature not found")
	Else
		Wave/D temperatureWave=temperature
		Variable/G temperature=temperatureWave[0]
		KillWaves temperatureWave
	Endif
	
	If(kzMapping!=1)
		HDF5LoadData/Q/O/N=photon_energy fileID, energyName2
		If(V_Flag!=0)
			Print("Error: energy not found")
		Else
			Wave/D photon_energyWave=photon_energy
			Variable/G single_photon_energy=photon_energyWave[0]
			KillWaves photon_energyWave
		Endif
	Endif
	
	HDF5LoadData/Q/O/N=polarization fileID, polarizationName
	If(V_Flag!=0)
		Print("Error: polarization not found")
	Else
		Wave/T polarizationWave=polarization
		String/G polarization=polarizationWave[0]
		KillWaves polarizationWave
	Endif
	
	HDF5CloseFile fileID
	
	//set scale & transform
	Wave/D angles=angles
	Wave/D energies=energies
	Wave/D data=data
	If(threeDMapping==1)
		Wave/D sapolar=sapolar
		//polar-angle-energy -> energy-angle-polar
		MatrixOp/O $dataFolderName=transposeVol(data, 3)
		Wave/D transformedData=$dataFolderName
		SetScale/I x, energies[0], energies[dimSize(energies,0)-1], transformedData
		SetScale/I y, angles[0], angles[dimSize(angles,0)-1], transformedData
		SetScale/I z, sapolar[0], sapolar[dimSize(sapolar,0)-1], transformedData
		KillWaves sapolar
	Elseif(kzMapping==1)
		//photon_energy-angle-energy -> energy-angle (split into 2D waves)
		Variable numSlices=dimSize(data,0)
		Variable numAngles=dimSize(data,1)
		Variable numEnergies=dimSize(data,2)
		Variable i
		For(i=0;i<numSlices;i+=1)
			Make/O/D/N=(numEnergies,numAngles) $(dataFolderName+"_"+num2str(i))
			Wave/D transformedSlice=$(dataFolderName+"_"+num2str(i))
			SetScale/I x, energies[i][0], energies[i][dimSize(energies,1)-1], transformedSlice
			SetScale/I y, angles[0], angles[dimSize(angles,0)-1], transformedSlice
			transformedSlice[][]=data[i][q][p]
		Endfor
	Else
		//[0]-angle-energy -> energy-angle
		MatrixOp/O $dataFolderName=transposeVol(data, 3)
		Wave/D transformedData=$dataFolderName
		SetScale/I x, energies[0], energies[dimSize(energies,0)-1], transformedData
		SetScale/I y, angles[0], angles[dimSize(angles,0)-1], transformedData
	Endif
	
	KillWaves angles, energies, data
	cd $currentDataFolder
End