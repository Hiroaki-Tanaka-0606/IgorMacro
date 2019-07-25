#pragma rtGlobals=1		// Use modern global access method.

//EfFitting: Fermi edge (with temperature & noise fluctuation) fitting 

//Fitting function (same as InoMacro Ver3.124)
//=p[0]*convolve((1+p[1]x)/(exp(beta(p[6])*x)+1),gaussian(p[5]))+p[2]+p[3]*x
//x=energy-p[4]

//Fitting Parameters: stored in "Parameters" wave
//param[0]: Scale of Intensity
//param[1]: Slope of Intensity [/eV]
//param[2]: Background
//param[3]: Slope of Background [/eV]
//param[4]: ef [eV]
//param[5]: sigma(FWHM) [eV]

//Fitting Configuration: stored in "Config" wave
//conf[0]: fitting range (min, including itself) [index], 0 if the value is the same as or smaller than 0
//conf[1]: fitting range (max, not including itself) [index], DimSize(wave,0) if the value is larger than that value
//range: [conf[0],conf[1])
//conf[2]: range to calculate gaussian [*sigma], default 5
//conf[3]: temperature [K]

//Usage
//waveName: wave name to fit
//temperature: measurement temperature
//holdParams: 6-long string, which determines whether param[i] is hold constant ("1") or not ("0")
//setting flags other than second and fourth to "1" is not reasonable, because estimated values are set to them in initialization.
//displayFlag: display data & fitting curve when 1, verbose

Function EfFitting(waveName, temperature, holdParams, displayFlag)
	String waveName, holdParams
	Variable temperature, displayFlag
	
	Wave/D input=$waveName
	
	//energy information
	Variable size=DimSize(input,0)
	Variable offset=DimOffset(input,0)
	Variable delta=DimDelta(input,0)
	If(displayFlag==1)
		Print "Offset: "+num2str(offset)
		Print "Delta: "+num2str(delta)
		Print "Size: "+num2str(size)
	Endif
	
	//set default value in configuration
	Wave/D conf=$"Config"
	if(!WaveExists(conf))
		Make/O/D/N=4 $"Config"
	Endif
	Wave/D conf=$"Config"
	conf[0]=max(0,conf[0])
	if(conf[1]==0)
		conf[1]=size
	Else
		conf[1]=min(size,conf[1])
	Endif
	if(conf[2]<1)
		conf[2]=5
	Endif
	conf[3]=temperature
	
	Variable fitRange=conf[1]-conf[0]
	
	//get initial value from edgestat
	EdgeStats/A=5/B=5/F=0.25/P/Q input
	
	//set initial value
	Make/O/D/N=6 $"Parameters"
	Wave/D param=$"Parameters"
	
	param[0]=abs(V_EdgeAmp4_0)
	param[1]=0
	param[2]=V_EdgeLvl4
	param[3]=0
	if(V_Flag==0)
		param[4]=V_EdgeLoc2*delta+offset
	elseif(V_Flag==1)
		print("EfFitting warning: cant't find all three level crossings.\n")
		if(numtype(V_EdgeLoc1)==0)
			param[4]=V_EdgeLoc1*delta+offset
		elseif(numtype(V_EdgeLoc2)==0)
			param[4]=V_EdgeLoc2*delta+offset
		else
			param[4]=V_EdgeLoc2*delta+offset
		endif
	else
		print("EfFitting error: can't find edge.\n")
		abort
	endif
	if(V_Flag==0)
		param[5]=1.5*abs(V_EdgeLoc3-V_EdgeLoc1)*delta //1.5 is some experimental parameter
	else
		param[5]=delta
	endif
	
	Duplicate/O/R=[conf[0],conf[1]-1] input yTemp
	
	FuncFit/H=(holdParams)/Q/W=2 EfTrialFunc param yTemp
	//Beep
	
	If(displayflag==1)
		Display input
		ModifyGraph mode=3,marker=19
		Make/O/D/N=(size) $"FitEdge"
		SetScale/P x offset, delta, $"FitEdge"
		Wave/D FitEdge=$"FitEdge"
		EfTrialFunc(param, FitEdge, FitEdge)
	
		AppendToGraph FitEdge
	Endif
	
End

Function EfTrialFunc(param, ywave, xwave): FitFunc
	Wave/D param, ywave, xwave
	Wave/D conf=$"Config"

	Variable delta=DimDelta(ywave,0)
	Variable size=DimSize(ywave,0)
	Variable offset=DimOffset(ywave,0)
	Variable beta=11604.53/conf[3] //1/k_B T
	
	param[5]=abs(param[5])
	Variable gaussianWidth=GaussianWave(param[5]/(2*sqrt(2*ln(2))*delta),conf[2],"tempGaussian")
	Variable xStart=offset-gaussianWidth*delta
	Make/O/D/N=(size+2*gaussianWidth) $"tempTrial"
	SetScale/P x xStart,delta,$"tempTrial"
	
	Wave/D tempTrial=$"tempTrial"
	tempTrial=(1+(x-param[4])*param[1])/(1+exp(beta*(x-param[4])))
	Convolve/A $"tempGaussian" tempTrial
	tempTrial*=param[0]
	tempTrial+=param[2]+param[3]*(x-param[4])
	
	//set to ywave
	ywave[]=tempTrial[gaussianWidth+p]
	
	KillWaves tempTrial
End

Function GaussianWave(sigma, maxRange, waveName)
	//sigma: standard deviation [index]
	Variable sigma, maxRange
	String waveName
	//hwpoints: half number of points
	Variable hwpoints=ceil(sigma*maxRange)
	Variable xrange=hwpoints/sigma
	Make/O/D/N=(2*hwpoints+1) $waveName
	Wave/D gaussian=$waveName
	SetScale/I x -hwpoints, hwpoints, $waveName
	Make/O/D gaussianParams={0,1/(sqrt(2*pi)*sigma),0,sqrt(2)*sigma}
	
	gaussian=Gauss1D(gaussianParams,x)
	
	return hwpoints
	
End