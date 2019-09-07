#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//correctMPMS: correction using Pd reference
//input_prefix: prefix of the input wave name
// moment: prefix+"moment"
// field: prefix+"field" [Oe] decrease -> increase
//folderName: name of the folder in which Pd reference data is (relative path or absolute path including "root:")
// NVAR Pd_slope, Pd_offset_decrease, Pd_offset_increase are used
//turning_point: flag by which where the turning point is stored is determined
// positive when the point is included in decrease part
// negative when the point is included in increase part
// zero when the point is included in both part  
//output_prefix: prefix of the output wave name
// moment: prefix+"moment_increase","moment_decrease"
// field: prefix+"field_increase","field_decrease"
Function correctMPMS(input_prefix,folderName,turning_point,output_prefix)
	String input_prefix,folderName,output_prefix
	Variable turning_point
	
	//from http://www.fizika.si/magnetism/MagSusceptibilities.pdf
	Variable Pd_chi=540e-6 //[cm^3/mol]
	
	print("[correctMPMS]")
	
	String currentDataFolder=getDataFolder(1)
	cd $folderName
	
	NVAR Pd_slope=Pd_slope
	NVAR Pd_offset_decrease=Pd_offset_decrease
	NVAR Pd_offset_increase=Pd_offset_increase
	
	cd currentDataFolder
	Wave/D field=$(input_prefix+"field")
	Wave/D moment=$(input_prefix+"moment")
	
	Variable size=DimSize(field,0)
	Variable turning_index=-1
	Variable i
	For(i=0;i<size-1;i+=1)
		if(field[i]<field[i+1])
			//turning point was found
			if(turning_index<0)
				turning_index=i
			endif
		else
			if(turning_index>0)
				//multiple turning point, error
				print("Error: multiple turning points in field data")
				abort
			endif
		endif
	endfor
	
	Variable decrease_end
	Variable increase_start
	
	if(turning_point>=0)
		//turning point is included in decrease part
		Make/O/D/N=(turning_index+1) $(output_prefix+"moment_decrease")
		Make/O/D/N=(turning_index+1) $(output_prefix+"field_decrease")
		decrease_end=turning_index
	else
		//turning point is not included in decrease part
		Make/O/D/N=(turning_index) $(output_prefix+"moment_decrease")
		Make/O/D/N=(turning_index) $(output_prefix+"field_decrease")
		decrease_end=turning_index-1
	endif
	
	if(turning_point<=0)
		//turning point is included in increase part
		Make/O/D/N=(size-turning_index) $(output_prefix+"moment_increase")
		Make/O/D/N=(size-turning_index) $(output_prefix+"field_increase")
		increase_start=turning_index
	else
		//turning point is not included in increase part
		Make/O/D/N=(size-turning_index-1) $(output_prefix+"moment_increase")
		Make/O/D/N=(size-turning_index-1) $(output_prefix+"field_increase")
		increase_start=turning_index+1
	endif
	
	Wave/D moment_decrease=$(output_prefix+"moment_decrease")
	Wave/D moment_increase=$(output_prefix+"moment_increase")
	Wave/D field_decrease=$(output_prefix+"field_decrease")
	Wave/D field_increase=$(output_prefix+"field_increase")

	For(i=0;i<=decrease_end;i+=1)
		moment_decrease[i]=moment[i]*Pd_chi/Pd_slope
		field_decrease[i]=field[i]-Pd_offset_decrease
	Endfor
	For(i=increase_start;i<size;i+=1)
		moment_increase[i-increase_start]=moment[i]*Pd_chi/Pd_slope
		field_increase[i-increase_start]=field[i]-Pd_offset_increase
	Endfor
	
	cd currentDataFolder
End


//analysis_Pd: analysis reference(Pd) data
//prefix: prefix of the input wave name
// moment: prefix+"moment" [emu]
// field: prefix+"field" [Oe] decrease -> increase
// regfit: prefix+"regfit" [a.u.]
//folderName: folder name in which the result is stored (created in "root")
//mass: weight of the sample [g]
//minRegFit: min value of regfit of accepted data
Function analysis_Pd(prefix, folderName, mass, minRegFit)
	String prefix,folderName
	Variable minRegFit, mass
	
	//from https://www.sigmaaldrich.com/technical-documents/articles/biology/periodic-table-of-elements-names.html
	Variable formulaWeight=106.42
	print "[analysis_Pd]"
	
	String currentDataFolder=getDataFolder(1)
	
	Wave/D field=$(prefix+"field")
	Wave/D moment_emu=$(prefix+"moment")
	Wave/D regfit=$(prefix+"regfit")
	
	Variable size1=dimSize(field,0)
	Variable size2=dimSize(moment_emu,0)
	Variable size3=dimSize(regfit,0)
		
	if(size1!=size2 || size2!=size3 || size3!=size1)
		print "Error: wave sizes of field, moment and regfit are different"
		abort
	endif
	
	cd root:
	NewDataFolder/O $folderName
	cd currentDataFolder
	
	//convert [emu] to [emu/mol]
	emu_emumol(prefix+"moment","root:"+folderName+":Pd_moment_emumol",mass,formulaWeight)
	
	cd root:
	cd $folderName
	Wave/D moment=$"Pd_moment_emumol"

	Variable i
	Variable number_total=0
	Variable turned=0
	For(i=0;i<size1;i+=1)
		if(regfit[i]>minRegFit)
			number_total+=1
		endif
	endfor
	
	Make/O/D/N=(number_total) $"Pd_field"
	Wave/D Pd_field=$"Pd_field"
	Make/O/D/N=(number_total) $"Pd_moment"
	Wave/D Pd_moment=$"Pd_moment"
	
	Variable index=0
	For(i=0;i<size1;i+=1)
		if(regfit[i]>minRegFit)
			Pd_field[index]=field[i]
			Pd_moment[index]=moment[i]
			index+=1
		endif
	endfor
	
	Variable number_decrease=0 //not including the turning point
	Variable number_increase=0 //including the turning point but not including the end point
	Variable turning_index=-1
	For(i=0;i<number_total-1;i+=1)
		if(Pd_field[i]>Pd_field[i+1])
			//decreasing
			if(turning_index<0)
				number_decrease+=1
			else
				//already turned, error
				print "Error: field already increasing but now decreasing again"
				abort
			endif
		else
			//increasing
			if(turning_index<0)
				//i is turning point
				turning_index=i
			endif
			number_increase+=1
		endif
	Endfor
	
	
	//decreasing part
	Make/O/D/N=(number_decrease+1) $"Pd_field_decrease"
	Wave/D Pd_field_decrease=$"Pd_field_decrease"
	Make/O/D/N=(number_decrease+1) $"Pd_moment_decrease"
	Wave/D Pd_moment_decrease=$"Pd_moment_decrease"
	
	For(i=0;i<number_decrease+1;i+=1)
		Pd_field_decrease[i]=Pd_field[i]
		Pd_moment_decrease[i]=Pd_moment[i]
	Endfor

	//increasing part
	Make/O/D/N=(number_increase+1) $"Pd_field_increase"
	Wave/D Pd_field_increase=$"Pd_field_increase"
	Make/O/D/N=(number_increase+1) $"Pd_moment_increase"
	Wave/D Pd_moment_increase=$"Pd_moment_increase"
	
	For(i=0;i<number_increase+1;i+=1)
		Pd_field_increase[i]=Pd_field[i+turning_index]
		Pd_moment_increase[i]=Pd_moment[i+turning_index]
	Endfor
	
	//fitting
	Wave/D coef=$"W_coef"
	//y=coef[0]+coef[1]*x
	CurveFit/N line Pd_moment /X=Pd_field
	Variable/G Pd_slope=coef[1]
	
	CurveFit/N line Pd_moment_increase /X=Pd_field_increase
	Variable/G Pd_offset_increase=-coef[0]/coef[1]
	Make/O/D/N=(number_increase+1) $"Pd_fit_increase"
	Wave/D Pd_fit_increase=$"Pd_fit_increase"
	Pd_fit_increase[]=coef[0]+coef[1]*Pd_field_increase[p]
	
	CurveFit/N line Pd_moment_decrease /X=Pd_field_decrease
	Variable/G Pd_offset_decrease=-coef[0]/coef[1]
	Make/O/D/N=(number_decrease+1) $"Pd_fit_decrease"
	Wave/D Pd_fit_decrease=$"Pd_fit_decrease"
	Pd_fit_decrease[]=coef[0]+coef[1]*Pd_field_decrease[p]

	cd currentDataFolder
End