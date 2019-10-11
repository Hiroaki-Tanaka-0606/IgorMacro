#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#include "AuNormalize"


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
	AuAnalyze_nearEf(folderName+"_cor",temperature,"root:MCP_reference",0.1,0.2,0.5,angleSum,energySum,folderName+"_ef",folderName+"_fwhm","000000")
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
