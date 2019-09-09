#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//slopeFilter2D: filter by linear slope
//Usage
//inputWave: wave name of the 2D input wave
//xslope: slope in x direction
// filtering: f(x) -> f(x)*(1+x*xslope)
//yslope: slope in y direction
//outputWave: wave name of the output
Function slopeFilter2D(inputWave, xslope, yslope, outputWave)
	String inputWave, outputWave
	Variable xslope, yslope
	
	Print("[slopeFilter2D]")
	
	Wave/D input=$inputWave
	Duplicate/O input $outputWave
	Wave/D output=$outputWave
	
	output[][]=input[p][q]*(1+x*xslope)*(1+y*yslope)
	
End

//polygonalPattern: make polygonal pattern with gaussian broadening
//Usage
//n: number of edges of polygonal
//r: radius of the circle in which the polygonal inscribes
//sigma: gaussian broadening
//intensity: gaussian intensity
//offset: start value of x,y
//delta: delta x,y
//size: number of points in x,y direction
//outputWave: wave name of the output (2D)
Function polygonalPattern(n,r,sigma,intensity,offset,delta,size,outputWave)
	Variable n,r,sigma,intensity,offset,delta,size
	String outputWave
	
	Print("[polygonalPattern]")
	
	Make/O/D/N=(size,size) $outputWave
	SetScale/P x, offset, delta, $outputWave
	SetScale/P y, offset, delta, $outputWave
	Wave/D output=$outputWave
	
	output[][]=polygonalPatternIntensity(n,r,sigma,intensity,x,y)
End

//calculate the intensity of polygonal pattern
//Usage
//n,r,sigma,intensity: the same as polygonalPattern
//x,y: coordinates
//return value=intensity*gauss(distance from nearest point on the edges of polygonal/sigma)
Function polygonalPatternIntensity(n,r,sigma,intensity,x,y)
	Variable n,r,sigma,intensity,x,y
		
	Variable theta=arg(x,y)
	
	Variable m, thetaMax
	Variable d
	For(m=1;m<=n;m+=1)
		thetaMax=2*pi*m/n
		if(theta<thetaMax)
			//rotate (x,y) by -2pi (m-1/2)/n
			Variable rot=-2*pi*(m-0.5)/n
			Variable xrot=cos(rot)*x-sin(rot)*y
			Variable yrot=sin(rot)*x+cos(rot)*y
			if(abs(yrot)>r*sin(pi/n))
				d=sqrt((xrot-r*cos(pi/n))^2+(abs(yrot)-r*sin(pi/n))^2)
			else
				d=(cos(rot)*x-sin(rot)*y)-r*cos(pi/n)
			endif
			break
		Endif
	Endfor
	
	return	intensity*Gauss(d,0,sigma)
End

//return the argument of the vector (x,y) [0,2pi)
Function arg(x,y)
	Variable x,y
	
	Variable r=sqrt(x^2+y^2)
	If(r==0)
		return 0
	Endif
	Variable costheta=x/r
	Variable theta=acos(costheta)
	
	if(y<0)
		theta=2*pi-theta
	Endif
	
	return theta
	
End