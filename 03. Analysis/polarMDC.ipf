#pragma rtGlobals=3		// Use modern global access method and strict wave access.


//input: k-k map
//theta in unit of degree
Function createPolarMDC(inputWave, centerX, centerY, rMin, rMax, thetaOffset, thetaDelta, thetaSize, mode, outputWave)
	Variable rMin, rMax, thetaOffset,thetaDelta,thetaSize, centerX, centerY, mode
	String inputWave, outputWave
	
	print("[createPolarMDC]")
	
	Wave/D input=$inputWave
	
	//row(x)
	Variable size1=DimSize(input,0)
	Variable delta1=DimDelta(input,0)
	Variable offset1=DimOffset(input,0)
	//column(y)
	Variable size2=DimSize(input,1)
	Variable delta2=DimDelta(input,1)
	Variable offset2=DimOffset(input,1)
	
	Variable rDelta=min(abs(delta1),abs(delta2))
	Variable rMinIndex=floor(rMin/rDelta)
	Variable rMaxIndex=ceil(rMax/rDelta)
	Variable rSize=rMaxIndex-rMinIndex+1
	
	Make/O/D/N=(rSize,thetaSize) $outputWave
	Wave/D output=$outputWave
	SetScale/P x, (rMinIndex*rDelta), rDelta, output
	SetScale/P y, thetaOffset, thetaDelta, output
	
	Variable i,j
	For(i=0;i<rSize;i+=1)
		Variable r=rDelta*(rMinIndex+i)
		For(j=0;j<thetaSize;j+=1)
			Variable theta=(thetaOffset+thetaDelta*j)*PI/180
			Variable x=r*cos(theta)+centerX
			Variable y=r*sin(theta)+centerY
			Variable xIndex_double=(x-offset1)/delta1
			Variable yIndex_double=(y-offset2)/delta2
			if(mode==0)
				//nearest neighbor
				Variable xIndex=round(xIndex_double)
				Variable yIndex=round(yIndex_double)
				if(0<=xIndex && xIndex<size1 && 0<=yIndex && yIndex<size2)
					output[i][j]=input[xIndex][yIndex]
				else
					output[i][j]=NaN
				endif
			elseif(mode==1)
				//linear interpolation
				if(0<=xIndex_double && xIndex_double<=size1-1 && 0<=yIndex_double && yIndex_double<=size2-1)
					Variable x0=floor(xIndex_double)
					Variable x1=xIndex_double
					Variable x2=ceil(xIndex_double)
					Variable y0=floor(yIndex_double)
					Variable y1=yIndex_double
					Variable y2=ceil(yIndex_double)
					output[i][j]=input[x0][y0]*(x2-x1)*(y2-y1)
					output[i][j]+=input[x1][y0]*(x1-x0)*(y2-y1)
					output[i][j]+=input[x1][y1]*(x1-x0)*(y1-y0)
					output[i][j]+=input[x0][y1]*(x2-x1)*(y1-y0)
				else
					output[i][j]=NaN
				endif
			Else
				output[i][j]=NaN
			Endif
		Endfor
	Endfor
	
	
End

