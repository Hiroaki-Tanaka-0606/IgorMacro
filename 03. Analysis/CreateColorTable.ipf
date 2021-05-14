#pragma rtGlobals=3		// Use modern global access method and strict wave access.

Function createLinearColorTable(inputWave,startR,startG,startB,endR,endG,endB,steps,outputWave)
	String inputWave,outputWave
	Variable startR,startG,startB,endR,endG,endB
	Variable steps
	
	Wave/D input=$inputWave
	Variable size1=DimSize(input,0)
	Variable size2=DimSize(input,1)
	Variable min=NaN
	Variable max=NaN
	
	Variable i,j
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2;j+=1)
			if(numtype(min)!=0 || (numtype(input[i][j])==0 && input[i][j]<min))
				min=input[i][j]
			Endif
			if(numtype(max)!=0 || (numtype(input[i][j])==0 && input[i][j]>max))
				max=input[i][j]
			Endif
		Endfor
	Endfor
	
	Print("Min: "+num2str(min)+", Max: "+num2str(max))
	
	Make/O/D/N=(steps,3) $outputWave
	Wave/D output=$outputWave
	SetScale/I x, min, max, output
	For(i=0;i<steps;i+=1)	
		Variable t=(i/(steps-1))
		output[i][0]=(startR*(1-t)+endR*t)	
		output[i][1]=(startG*(1-t)+endG*t)
		output[i][2]=(startB*(1-t)+endB*t)
	Endfor
End


Function createParabolaColorTable(inputWave,startR,startG,startB,endR,endG,endB,steps,outputWave)
	String inputWave,outputWave
	Variable startR,startG,startB,endR,endG,endB
	Variable steps
	
	Wave/D input=$inputWave
	Variable size1=DimSize(input,0)
	Variable size2=DimSize(input,1)
	Variable min=NaN
	Variable max=NaN
	
	Variable i,j
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2;j+=1)
			if(numtype(min)!=0 || (numtype(input[i][j])==0 && input[i][j]<min))
				min=input[i][j]
			Endif
			if(numtype(max)!=0 || (numtype(input[i][j])==0 && input[i][j]>max))
				max=input[i][j]
			Endif
		Endfor
	Endfor
	
	Print("Min: "+num2str(min)+", Max: "+num2str(max))
	
	
	Make/O/D/N=(steps,3) $outputWave
	Wave/D output=$outputWave
	SetScale/I x, min, max, output
	For(i=0;i<steps;i+=1)	
		Variable t=-(i/(steps-1)-1)^2+1
		output[i][0]=(startR*(1-t)+endR*t)	
		output[i][1]=(startG*(1-t)+endG*t)
		output[i][2]=(startB*(1-t)+endB*t)
	Endfor
End

Function createParabolaColorTable_range(inputWave,startR,startG,startB,endR,endG,endB,startX,endX,startY,endY,steps,outputWave)
	String inputWave,outputWave
	Variable startR,startG,startB,endR,endG,endB,startX,startY,endX,endY
	Variable steps
	
	Wave/D input=$inputWave
	Variable size1=DimSize(input,0)
	Variable size2=DimSize(input,1)
	Variable offset1=Dimoffset(input,0)
	Variable offset2=Dimoffset(input,1)
	Variable delta1=Dimdelta(input,0)
	Variable delta2=Dimdelta(input,1)
	Variable min=NaN
	Variable max=NaN
	
	Variable i,j
	For(i=0;i<size1;i+=1)
		Variable x=offset1+i*delta1
		if(x<startX || x>endX)
			continue
		endif
		For(j=0;j<size2;j+=1)
			Variable y=offset2+j*delta2
			if(y<startY || y>endY)
				continue
			Endif
			if(numtype(min)!=0 || (numtype(input[i][j])==0 && input[i][j]<min))
				min=input[i][j]
			Endif
			if(numtype(max)!=0 || (numtype(input[i][j])==0 && input[i][j]>max))
				max=input[i][j]
			Endif
		Endfor
	Endfor
	
	Print("Min: "+num2str(min)+", Max: "+num2str(max))
	Make/O/D/N=(steps,3) $outputWave
	Wave/D output=$outputWave
	SetScale/I x, min, max, output
	For(i=0;i<steps;i+=1)	
		Variable t=-(i/(steps-1)-1)^2+1
		output[i][0]=(startR*(1-t)+endR*t)	
		output[i][1]=(startG*(1-t)+endG*t)
		output[i][2]=(startB*(1-t)+endB*t)
	Endfor
End


Function createParabola2ColorTable_range(inputWave,startR,startG,startB,endR,endG,endB,startX,endX,startY,endY,steps,outputWave)
	String inputWave,outputWave
	Variable startR,startG,startB,endR,endG,endB,startX,startY,endX,endY
	Variable steps
	
	Wave/D input=$inputWave
	Variable size1=DimSize(input,0)
	Variable size2=DimSize(input,1)
	Variable offset1=Dimoffset(input,0)
	Variable offset2=Dimoffset(input,1)
	Variable delta1=Dimdelta(input,0)
	Variable delta2=Dimdelta(input,1)
	Variable min=NaN
	Variable max=NaN
	
	Variable i,j
	For(i=0;i<size1;i+=1)
		Variable x=offset1+i*delta1
		if(x<startX || x>endX)
			continue
		endif
		For(j=0;j<size2;j+=1)
			Variable y=offset2+j*delta2
			if(y<startY || y>endY)
				continue
			Endif
			if(numtype(min)!=0 || (numtype(input[i][j])==0 && input[i][j]<min))
				min=input[i][j]
			Endif
			if(numtype(max)!=0 || (numtype(input[i][j])==0 && input[i][j]>max))
				max=input[i][j]
			Endif
		Endfor
	Endfor
	
	Print("Min: "+num2str(min)+", Max: "+num2str(max))
	Make/O/D/N=(steps,3) $outputWave
	Wave/D output=$outputWave
	SetScale/I x, min, max, output
	For(i=0;i<steps;i+=1)	
		Variable t=(i/(steps-1))^2
		output[i][0]=(startR*(1-t)+endR*t)	
		output[i][1]=(startG*(1-t)+endG*t)
		output[i][2]=(startB*(1-t)+endB*t)
	Endfor
End