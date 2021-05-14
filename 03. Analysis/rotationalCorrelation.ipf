#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//rotationAnalysis3D_dd: calculate second derivative of rotational correlation as a function of theta
//Usage
//dTheta: delta theta used in differential approximation
//the others: the same as rotationAnalysis3D
Function rotationAnalysis3D_dd(inputWave, centerX, centerY, radiusMin, radiusMax, thetaOffset, thetaDelta, thetaSize, dTheta, outputWave)

	String inputWave, outputWave
	Variable centerX, centerY, thetaOffset, thetaDelta, thetaSize, radiusMin, radiusMax, dTheta
	
	Wave/D input=$inputWave
	
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	Variable size1=DimSize(input,0)
	
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	Variable size2=DimSize(input,1)
	
	Variable offset3=DimOffset(input,2)
	Variable delta3=DimDelta(input,2)
	Variable size3=DimSize(input,2)
	
	Make/O/D/N=(thetaSize,size1) $outputWave
	Wave/D output=$outputWave
	setScale/P x, thetaOffset, thetaDelta, output
	setScale/P y, offset1, delta1, output
	Variable i,j
	
	Make/O/D/N=(size2,size3) $"temp2D"
	Wave/D temp2D=$"temp2D"
	SetScale/P x, offset2, delta2, temp2D
	SetScale/P y, offset3, delta3, temp2D
	For(i=0;i<size1;i+=1)
		temp2D[][]=input[i][p][q]
		For(j=0;j<thetaSize;j+=1)
			Variable theta=thetaOffset+j*thetaDelta
			Variable plus=rotationalCorrelation2D("temp2D", centerX, centerY, radiusMin, radiusMax, theta+dTheta)
			Variable zero=rotationalCorrelation2D("temp2D", centerX, centerY, radiusMin, radiusMax, theta)
			Variable minus=rotationalCorrelation2D("temp2D", centerX, centerY, radiusMin, radiusMax, theta-dTheta)
			output[j][i]=(plus-2*zero+minus)/(dTheta^2)
		Endfor
	Endfor
	KillWaves temp2D
End	

//rotationAnalysis3D: calculate rotational correlation as a function of theta
//Usage
//inputWave: name of the 3D (E-k-k) input wave
//centerX, centerY: rotational center
//radiusMin: minimum distance of the center and the points which are used in calculation
//radiusMax: maximum distance of the center and the points which are used in calculation
//thetaOffset, thetaDelta, thetaSize: theta range
//outputWave: name of the output wave
Function rotationAnalysis3D(inputWave, centerX, centerY, radiusMin, radiusMax, thetaOffset, thetaDelta, thetaSize, outputWave)
	String inputWave, outputWave
	Variable centerX, centerY, thetaOffset, thetaDelta, thetaSize, radiusMin, radiusMax
	
	Wave/D input=$inputWave
	
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	Variable size1=DimSize(input,0)
	
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	Variable size2=DimSize(input,1)
	
	Variable offset3=DimOffset(input,2)
	Variable delta3=DimDelta(input,2)
	Variable size3=DimSize(input,2)
	
	Make/O/D/N=(thetaSize,size1) $outputWave
	Wave/D output=$outputWave
	setScale/P x, thetaOffset, thetaDelta, output
	setScale/P y, offset1, delta1, output
	Variable i
	
	Make/O/D/N=(size2,size3) $"temp2D"
	Wave/D temp2D=$"temp2D"
	SetScale/P x, offset2, delta2, temp2D
	SetScale/P y, offset3, delta3, temp2D
	For(i=0;i<size1;i+=1)
		temp2D[][]=input[i][p][q]
		output[][i]=rotationalCorrelation2D("temp2D", centerX, centerY, radiusMin, radiusMax, x)
	Endfor
	KillWaves temp2D
end

//rotationAnalysis2D_dd: calculate second derivative of rotational correlation as a function of theta
//Usage
//dTheta: delta theta used in differential approximation
//the others: the same as rotationAnalysis2D
Function rotationAnalysis2D_dd(inputWave, centerX, centerY, radiusMin, radiusMax, thetaOffset, thetaDelta, thetaSize, dTheta, outputWave)
	String inputWave, outputWave
	Variable centerX, centerY, thetaOffset, thetaDelta, thetaSize, radiusMin, radiusMax, dTheta
	print("[rotationAnalysis2D_dd]")
	Make/O/D/N=(thetaSize) $outputWave
	Wave/D output=$outputWave
	setScale/P x, thetaOffset, thetaDelta, output
	Variable i
	For(i=0;i<thetaSize;i+=1)
		Variable theta=thetaOffset+i*thetaDelta
		Variable plus=rotationalCorrelation2D(inputWave, centerX, centerY, radiusMin, radiusMax, theta+dTheta)
		Variable zero=rotationalCorrelation2D(inputWave, centerX, centerY, radiusMin, radiusMax, theta)
		Variable minus=rotationalCorrelation2D(inputWave, centerX, centerY, radiusMin, radiusMax, theta-dTheta)
		output[i]=(plus-2*zero+minus)/(dTheta^2)
	Endfor
end

//rotationAnalysis2D: calculate rotational correlation as a function of theta
//Usage
//inputWave: name of the 2D input wave
//centerX, centerY: rotational center
//radiusMin: minimum distance of the center and the points which are used in calculation
//radiusMax: maximum distance of the center and the points which are used in calculation
//thetaOffset, thetaDelta, thetaSize: theta range
//outputWave: name of the output wave
Function rotationAnalysis2D(inputWave, centerX, centerY, radiusMin, radiusMax, thetaOffset, thetaDelta, thetaSize, outputWave)
	String inputWave, outputWave
	Variable centerX, centerY, thetaOffset, thetaDelta, thetaSize, radiusMin, radiusMax
	print("[rotationAnalysis2D]")
	Make/O/D/N=(thetaSize) $outputWave
	Wave/D output=$outputWave
	setScale/P x, thetaOffset, thetaDelta, output
	output[]=rotationalCorrelation2D(inputWave, centerX, centerY, radiusMin, radiusMax, x)
end

//findCenter3D_sum: calculate sum (in energy direction) of rotational correlation
//Usage
//inputWave: output average wave name of findCenter3D
//eMin: energy min
//eMax: energy max
//outputWave: prefix of the output wave
Function findCenter3D_sum(inputWave, eMin, eMax, outputWave)
	String inputWave, outputWave
	Variable eMin, eMax
	
	Print("[findCenter3D_sum]")
	Wave/D input=$inputWave
	
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	Variable size1=DimSize(input,0)
	
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	Variable size2=DimSize(input,1)
	
	Variable offset3=DimOffset(input,2)
	Variable delta3=DimDelta(input,2)
	Variable size3=DimSize(input,2)
	
	Make/O/D/N=(size2,size3) $outputWave
	Wave/D output=$outputWave
	SetScale/P x, offset2, delta2, output
	SetScale/P y, offset3, delta3, output
	
	Variable i
	output[][]=0
	For(i=0;i<size1;i+=1)
		Variable ene=offset1+delta1*i
		if(eMin<=ene && ene<=eMax)
			output[][]+=input[i][p][q]
		endif
	endfor
End


//findCenter3D: find the rotational center from rotational correlation
//Usage
//inputWave: name of the 3D (E-k-k) input wave
//xOffset, xDelta, xSize: search region in x direction
//yOffset, yDelta, ySize: search region in y direction
//radiusMin: minimum distance of the center and the points which are used in calculation
//radiusMax: maximum distance of the center and the points which are used in calculation
//symmetry: n-fold rotational symmetry (n = 2,3,4,6)
//prefix: prefix of the output wave
// names of the output waves are prefix+num2str(i) (i=1,...,n-1), prefix+"ave", prefix+"stdev", prefix+"allave", prefix+"allstdev"
Function findCenter3D(inputWave, xOffset, xDelta, xSize, yOffset, yDelta, ySize, radiusMin, radiusMax, symmetry, prefix)
	String inputWave, prefix
	Variable xOffset, xDelta, xSize, yOffset, yDelta, ySize, radiusMin, radiusMax, symmetry
	
	print("[findCenter3D]")
	if(symmetry!=2 && symmetry!=3 && symmetry!=4 && symmetry!=6)
		print("Error: symmetry must be 2, 3, 4, or 6")
		abort
	endif
	Wave/D input=$inputWave
	
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	Variable size1=DimSize(input,0)
	
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	Variable size2=DimSize(input,1)
	
	Variable offset3=DimOffset(input,2)
	Variable delta3=DimDelta(input,2)
	Variable size3=DimSize(input,2)
	
	Variable i,j
	
	Make/O/D/N=(size1,xSize,ySize) $(prefix+"ave")
	Wave/D average=$(prefix+"ave")
	Make/O/D/N=(size1,xSize,ySize) $(prefix+"stdev")
	Wave/D stdev=$(prefix+"stdev")
	SetScale/P x, offset1, delta1, average
	SetScale/P y, xOffset, xDelta, average
	SetScale/P z, yOffset, yDelta, average
	SetScale/P x, offset1, delta1, stdev
	SetScale/P x, xOffset, xDelta, stdev
	SetScale/P y, yOffset, yDelta, stdev
	average[][][]=0
	stdev[][][]=0
	Make/O/D/N=(size2,size3) $"temp2D"
	Wave/D temp2D=$"temp2D"
	SetScale/P x, offset2, delta2, temp2D
	SetScale/P y, offset3, delta3, temp2D
	For(i=1;i<symmetry;i+=1)
		Make/O/D/N=(size1,xSize,ySize) $(prefix+num2str(i))
		Wave/D output=$(prefix+num2str(i))
		SetScale/P x, offset1, delta1, output
		SetScale/P y, xOffset, xDelta, output
		SetScale/P z, yOffset, yDelta, output
		Variable theta=360*i/round(symmetry)
		For(j=0;j<size1;j+=1)
			temp2D[][]=input[j][p][q]
			output[j][][]=rotationalCorrelation2D("temp2D", y, z, radiusMin, radiusMax, theta)
		Endfor
		average[][][]+=output[p][q][r]
		stdev[][][]+=output[p][q][r]^2
	Endfor
	average[][][]/=(round(symmetry)-1)
	stdev[][][]=sqrt((stdev[p][q][r]/(round(symmetry)-1))-average[p][q][r]^2)
	KillWaves temp2D
End



//findCenter2D: find the rotational center from rotational correlation
//Usage
//inputWave: name of the 2D input wave
//xOffset, xDelta, xSize: search region in x direction
//yOffset, yDelta, ySize: search region in y direction
//radiusMin: minimum distance of the center and the points which are used in calculation
//radiusMax: maximum distance of the center and the points which are used in calculation
//symmetry: n-fold rotational symmetry (n = 2,3,4,6)
//prefix: prefix of the output wave
// names of the output waves are prefix+num2str(i) (i=1,...,n-1), prefix+"ave", prefix+"stdev"
Function findCenter2D(inputWave, xOffset, xDelta, xSize, yOffset, yDelta, ySize, radiusMin, radiusMax, symmetry, prefix)
	String inputWave, prefix
	Variable xOffset, xDelta, xSize, yOffset, yDelta, ySize, radiusMin, radiusMax, symmetry
	
	print("[findCenter2D]")
	if(symmetry!=2 && symmetry!=3 && symmetry!=4 && symmetry!=6)
		print("Error: symmetry must be 2, 3, 4, or 6")
		abort
	endif
	
	Variable i
	
	Make/O/D/N=(xSize,ySize) $(prefix+"ave")
	Wave/D average=$(prefix+"ave")
	Make/O/D/N=(xSize,ySize) $(prefix+"stdev")
	Wave/D stdev=$(prefix+"stdev")
	SetScale/P x, xOffset, xDelta, average
	SetScale/P y, yOffset, yDelta, average
	SetScale/P x, xOffset, xDelta, stdev
	SetScale/P y, yOffset, yDelta, stdev
	average[][]=0
	stdev[][]=0
	For(i=1;i<symmetry;i+=1)
		Make/O/D/N=(xSize,ySize) $(prefix+num2str(i))
		Wave/D output=$(prefix+num2str(i))
		SetScale/P x, xOffset, xDelta, output
		SetScale/P y, yOffset, yDelta, output
		Variable theta=360*i/round(symmetry)
		output[][]=rotationalCorrelation2D(inputWave, x, y, radiusMin, radiusMax, theta)
		average[][]+=output[p][q]
		stdev[][]+=output[p][q]^2
	Endfor
	average[][]/=(round(symmetry)-1)
	stdev[][]=sqrt((stdev[p][q]/(round(symmetry)-1))-average[p][q]^2)
End

//rotationalCorrelation2D: calculate correlation between input wave and rotated input wave
// within the region where the distance between the point and (centerX, centerY) is
// larger than radiusMin and smaller than radiusMax
//Usage
//inputWave: name of the 2D input wave
//centerX, centerY: rotational center coordinates
//radiusMin: minimum distance of the center and the points which are used in calculation
//radiusMax: maximum distance of the center and the points which are used in calculation
//theta: rotational angle [deg]
Function rotationalCorrelation2D(inputWave, centerX, centerY, radiusMin, radiusMax, theta)
	String inputWave
	Variable centerX, centerY, radiusMin, radiusMax, theta
	
	Variable thetaRad=theta*Pi/180.0
		
	Wave/D input=$inputWave
	Variable offsetX=DimOffset(input,0)
	Variable deltaX=DimDelta(input,0)
	Variable sizeX=DimSize(input,0)
	Variable minX=offsetX
	Variable maxX=offsetX+deltaX*(sizeX-1)
	
	Variable offsetY=DimOffset(input,1)
	Variable deltaY=DimDelta(input,1)
	Variable sizeY=DimSize(input,1)
	Variable minY=offsetY
	Variable maxY=offsetY+deltaY*(sizeY-1)
	
	//check if the radiusMax is small enough to fit in the input wave region
	if(centerX+radiusMax > maxX || centerX-radiusMax < minX || centerY+radiusMax > maxY || centerY-radiusMax < minY)
		print("Error: radiusMax is too large to fit in the input wave region")
		print("centerX: "+num2str(centerX)+" centerY: "+num2str(centerY))
		abort
	endif
	
	//index to coordinate: coordinate = offset + index * delta
	Variable minXIndex=floor((centerX-radiusMax-offsetX)/deltaX)
	Variable maxXIndex=ceil((centerX+radiusMax-offsetX)/deltaX)
	Variable minYIndex=floor((centerY-radiusMax-offsetY)/deltaY)
	Variable maxYIndex=ceil((centerY+radiusMax-offsetY)/deltaY)
	
	Variable i,j
	
	//calculate correlation (without subtracting the average)
	//corr=\sum(input*rotatedInput)/sqrt(\sum(input^2)*\sum(rotatedInput^2))
	Variable norm=0 //\sum(input*rotatedInput)
	Variable inputSquare=0 //\sum(input^2)
	Variable rInputSquare=0 //\sum(rotatedInput^2)
	Variable numPoints=0 //number of points used in calculation
	Variable xCoord, yCoord //coordinates of the point
	Variable rXCoord, rYCoord //coordinates of the rotated point
	Variable rXIndex, rYIndex //(real number) indices corresponding to (rXCoord, rYCoord)
	Variable floorRXIndex //largest integer smaller than rXIndex
	Variable floorRYIndex //largest integer smaller than rYIndex
	Variable rValue //value of the rotated point
	For(i=minXIndex;i<=maxXIndex;i+=1)
		xCoord=offsetX+deltaX*i
		For(j=minYIndex;j<=maxYIndex;j+=1)
			yCoord=offsetY+deltaY*j
			Variable d=sqrt((xCoord-centerX)^2+(yCoord-centerY)^2)
			if(d>=radiusMin && d<=radiusMax)
				numPoints+=1
				rXCoord=cos(thetaRad)*(xCoord-centerX)-sin(thetaRad)*(yCoord-centerY)+centerX
				rYCoord=sin(thetaRad)*(xCoord-centerX)+cos(thetaRad)*(yCoord-centerY)+centerY
				rXIndex=(rXCoord-offsetX)/deltaX
				rYIndex=(rYCoord-offsetY)/deltaY
				floorRXIndex=floor(rXIndex)
				floorRYIndex=floor(rYIndex)
				rValue=input[floorRXIndex][floorRYIndex]*(1-(rXIndex-floorRXIndex))*(1-(rYIndex-floorRYIndex))
				rValue+=input[floorRXIndex][floorRYIndex+1]*(1-(rXIndex-floorRXIndex))*(rYIndex-floorRYIndex)
				rValue+=input[floorRXIndex+1][floorRYIndex]*(rXIndex-floorRXIndex)*(1-(rYIndex-floorRYIndex))
				rValue+=input[floorRXIndex+1][floorRYIndex+1]*(rXIndex-floorRXIndex)*(rYIndex-floorRYIndex)
				inputSquare+=input[i][j]^2
				rInputSquare+=rValue^2
				norm+=input[i][j]*rValue
			endif
		endfor
	endfor
	Variable corr=norm/sqrt(inputSquare*rInputSquare)
	return corr
end