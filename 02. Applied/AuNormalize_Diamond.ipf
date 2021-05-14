#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include "AuNormalize"
#include "FermiEdgeLinearFit"


//MCPHistogram_Diamond: create histogram in the current folder
//histogram is created in root:MCP_histogram
Function MCPHistogram_Diamond()
	String folderName=GetDataFolder(0)
	MCPHistogram(folderName, 1000, "root:MCP_histogram")
End

//MCPReference: create reference wave
//reference wave is created in root:MCP_reference
Function MCPReference_Diamond(threshold)
	Variable threshold
	String folderName=GetDataFolder(0)
	MCPReference(folderName,threshold,"root:MCP_reference")
End

//AuAnalyze_Diamond: analyze Au data
Function AuAnalyze_Diamond(angleSum,energySum)
	Variable angleSum, energySum
	String folderName=GetDataFolder(0)
	NVAR temperature=temperature
	MCPNormalize2D(folderName,"root:MCP_reference",folderName+"_cor")
	AuAnalyze_nearEf(folderName+"_cor",temperature,"root:MCP_reference",0.05,0.2,0.5,angleSum,energySum,folderName+"_ef",folderName+"_fwhm","000000")
	AuEfCorrect2D(folderName+"_cor",folderName+"_ef",folderName+"_corrected")
	
	Wave/D a=$(folderName+"_cor")
	KillWaves a
End

//AuAnalyze_Diamond_kz: analyze Au data with kz dependence
Function AuAnalyze_Diamond_kz(angleSum,energySum)
	Variable angleSum, energySum
	String folderName=GetDataFolder(0)
	Wave/D photon_energy=photon_energy
	Variable numSlices=DimSize(photon_energy,0)
	NVAR temperature=temperature
	
	Wave/D firstWave=$(folderName+"_0")
	Variable size1=DimSize(firstWave,1)
	Variable offset1=DimOffset(firstWave,1)
	Variable delta1=DimDelta(firstWave,1)
	
	Make/O/D/N=(numSlices,size1) $(folderName+"_ef")
	Wave/D ef=$(folderName+"_ef")
	SetScale/I x, photon_energy[0], photon_energy[numSlices-1], ef
	SetScale/P y, offset1, delta1, ef
	
	Make/O/D/N=(numSlices,size1) $(folderName+"_fwhm")
	Wave/D fwhm=$(folderName+"_fwhm")
	SetScale/I x, photon_energy[0], photon_energy[numSlices-1], fwhm
	SetScale/P y, offset1, delta1, fwhm
	
	Variable i
	For(i=0;i<numSlices;i+=1)
		MCPNormalize2D(folderName+"_"+num2str(i),"root:MCP_reference",folderName+"_"+num2str(i)+"_cor")
		AuAnalyze_nearEf(folderName+"_"+num2str(i)+"_cor",temperature,"root:MCP_reference",0.05,0.1,0.5,angleSum,energySum,folderName+"_efSlice",folderName+"_fwhmSlice","000000")
		AuEfCorrect2D(folderName+"_"+num2str(i)+"_cor",folderName+"_efSlice",folderName+"_"+num2str(i)+"_corrected")
		Wave/D efSlice=$(folderName+"_efSlice")
		Wave/D fwhmSlice=$(folderName+"_fwhmSlice")
		ef[i][]=efSlice[q]
		fwhm[i][]=fwhmSlice[q]
		Wave/D a=$(folderName+"_"+num2str(i)+"_cor")
		KillWaves a
	Endfor
	Wave/D efSlice=$(folderName+"_efSlice")
	Wave/D fwhmSlice=$(folderName+"_fwhmSlice")
	KillWaves efSlice, fwhmSlice
End

//AnalyzeFermiEdge_Diamond: analyze kz dependence of Fermi edge
Function AnalyzeFermiEdge_Diamond()
	String folderName=GetDataFolder(0)
	AnalyzeFermiEdge(folderName+"_ef",folderName+"_slope",folderName+"_section")
End

//Correct2D_Diamond_kz: correct intensity and Fermi edge of kz dependent waves
//efWave: Fermi edge name
//offset: index offset
//delta: index delta
// (folderName)_(i) is corrected by efWave[i*delta+offset]
Function Correct2D_Diamond_kz(efWave,offset,delta)
	String efWave
	Variable offset, delta
	
	Print("[AuEfCorrect2D_Diamond_kz]")
	Wave/D ef=$efWave
	Variable size1=DimSize(ef,1)
	Variable offset1=DimOffset(ef,1)
	Variable delta1=DimDelta(ef,1)
	
	Make/O/D/N=(size1) tempSlice
	Wave/D tempSlice=tempSlice
	SetScale/P x, offset1, delta1, tempSlice
	
	String folderName=GetDataFolder(0)
	Wave/D photon_energy=photon_energy
	
	Variable i
	For(i=0;i<DimSize(photon_energy,0);i+=1)
		tempSlice[]=ef[i*delta+offset][p]
		MCPNormalize2D(folderName+"_"+num2str(i),"root:MCP_reference",folderName+"_cor")
		AuEfCorrect2D(folderName+"_cor","tempSlice",folderName+"_"+num2str(i)+"_corrected")
	Endfor
	Wave/D a=$(folderName+"_cor")
	
	KillWaves tempSlice,a
End

//Correct3D_Diamond: correct intensity and Fermi edge of 3D waves
//Usage
//efWave: Fermi edge name
Function Correct3D_Diamond(efWave)
	String efWave
	String folderName=GetDataFolder(0)
	Print("[Correct3D_Diamond]")
	MCPNormalize3D(folderName,"root:MCP_reference",folderName+"_cor")
	AuEfCorrect3D(folderName+"_cor",efWave,folderName+"_corrected")
	Wave/D a=$(folderName+"_cor")
	
	KillWaves a
End

//Correct3D_Diamond_lowMemory: correct intensity and Fermi edge of 3D waves
//Usage
//efWave: Fermi edge name
Function Correct3D_Diamond_lowMemory(efWave)
	String efWave
	String folderName=GetDataFolder(0)
	Print("[Correct3D_Diamond_lowMemory]")
	MCPNormalize3D(folderName,"root:MCP_reference",folderName+"_cor")
	Wave/D b=$(folderName)
	KillWaves b
	AuEfCorrect3D(folderName+"_cor",efWave,folderName+"_corrected")
	Wave/D a=$(folderName+"_cor")
	
	KillWaves a
End

//Correct3D_Diamond_LinearFit: correct intensity and Fermi edge of 3D waves from linear fit
//Usage
//AuFolder: folder name of Fermi edge list
Function Correct3D_Diamond_LinearFit(AuFolder)
	String AuFolder
	NVAR photon_energy=single_photon_energy
	String folderName=GetDataFolder(0)
	String folderPath=GetDataFolder(1) //include ":" at the end
	Print(folderPath)
	Print("[Correct3D_Diamond_LinearFit]")
	MCPNormalize3D(folderName,"root:MCP_reference",folderName+"_cor")
	cd AuFolder
	String auFolderName=GetDataFolder(0)
	GenerateFermiEdge(auFolderName+"_slope",auFolderName+"_section",photon_energy,folderPath+folderName+"_ef")
	cd folderPath
	AuEfCorrect3D(folderName+"_cor",folderName+"_ef",folderName+"_corrected")
	Wave/D a=$(folderName+"_cor")
	KillWaves a
End

//Correct2D_Diamond: correct intensity and Fermi edge
//efWave: Fermi edge name
//offset: index offset
//delta: index delta
// (folderName)_(i) is corrected by efWave[i*delta+offset]
Function Correct2D_Diamond(efWave)
	String efWave
	
	Print("[AuEfCorrect2D_Diamond]")
		
	String folderName=GetDataFolder(0)
	
	MCPNormalize2D(folderName,"root:MCP_reference",folderName+"_cor")
	AuEfCorrect2D(folderName+"_cor",efWave,folderName+"_corrected")
	Wave/D a=$(folderName+"_cor")
	KillWaves a
End

Function Correct2D_Diamond_linearFit(AuFolder)
	String AuFolder
	NVAR photon_energy=single_photon_energy
	String folderName=GetDataFolder(0)
	String folderPath=GetDataFolder(1) //include ":" at the end
	Print(folderPath)
	Print("[Correct2D_Diamond_LinearFit]")
	MCPNormalize2D(folderName,"root:MCP_reference",folderName+"_cor")
	cd AuFolder
	String auFolderName=GetDataFolder(0)
	GenerateFermiEdge(auFolderName+"_slope",auFolderName+"_section",photon_energy,folderPath+folderName+"_ef")
	cd folderPath
	AuEfCorrect2D(folderName+"_cor",folderName+"_ef",folderName+"_corrected")
	Wave/D a=$(folderName+"_cor")
	KillWaves a

End


//Correct2D_Diamond_kz: correct intensity and Fermi edge obtained by linear fitting
Function Correct2D_Diamond_kz_linearfit(aufolder)
	String aufolder
	
	Print("[AuEfCorrect2D_Diamond_kz_linearfit]")
	
	
	String folderName=GetDataFolder(0)
	String folderPath=GetDataFolder(1)
	Wave/D photon_energy=photon_energy
	
	cd AuFolder
	String auFolderName=getDatafolder(0)
	cd folderPath
	
	Variable i
	For(i=0;i<DimSize(photon_energy,0);i+=1)
		cd AuFolder
		generatefermiedge(aufoldername+"_slope",aufolderName+"_section",photon_energy[i],folderPath+folderName+"_"+num2str(i)+"_ef")
		cd folderpath			
		MCPNormalize2D(folderName+"_"+num2str(i),"root:MCP_reference",folderName+"_cor")
		AuEfCorrect2D(folderName+"_cor",folderName+"_"+num2str(i)+"_ef",folderName+"_"+num2str(i)+"_corrected")
	Endfor
	Wave/D a=$(folderName+"_cor")
	
	KillWaves a
End
