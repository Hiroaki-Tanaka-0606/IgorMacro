#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function ForLoop(argumentTable)
	String argumentTable
	Wave/T args=$argumentTable
	Variable size1=DimSize(args,0)
	
	Variable i
	For(i=0;i<size1;i+=1)
		//insert procedure here
		
		cd root:
		cd args[i]
		
		EfCorrect2D_self_dialog("Resonant",0.1,22,"000000","Resonant_corr")
		NVAR ef=ef
		EfCorrect2D_offset("Resonant",ef,"root:Au_EF_offset","Resonant_corr")
	Endfor
End