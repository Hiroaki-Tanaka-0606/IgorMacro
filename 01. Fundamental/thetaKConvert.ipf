#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//convert_E2k: convert energy [eV] to wavevector length [A^-1]
Function convert_E2k(energy)
	Variable energy
	
	Variable hbar_e34=1.054571 //Dirac constant
	Variable me_e31=9.109383 // electron mass
	Variable ec_e19=1.602176 // elementary charge
	Variable coeff_energy2WaveVector=sqrt(2*me_e31*ec_e19)/(hbar_e34*10)

	return sqrt(energy)*coeff_energy2WaveVector
End

//convert_k2E: convert wavevector length [A^-1] to energy [eV]
Function convert_k2E(k)
	Variable k
	
	Variable hbar_e34=1.054571 //Dirac constant
	Variable me_e31=9.109383 // electron mass
	Variable ec_e19=1.602176 // elementary charge
	Variable coeff_energy2WaveVector=sqrt(2*me_e31*ec_e19)/(hbar_e34*10)

	return (k/coeff_energy2WaveVector)^2
End

Function convert_deg2rad(theta)
	Variable theta
	return theta*PI/180
End

Function convert_rad2deg(theta)
	Variable theta
	return theta*180/PI
End

Function oneDigitFloor(n)
	Variable n
	Variable exponent=floor(log(n))
	return floor(n/(10^exponent))*(10^exponent)
End

//convert_EA2Ek: energy-angle(theta) map to energy-momentum map
//Usage
//inputWave: energy-angle map (Ef is set to zero)
//hn: photon energy [eV]
//W: work function [eV]
//theta0: theta offset [deg]
//outputWave: energy-momentum map
Function convert_EA2Ek(inputWave,hn,W,theta0,outputWave)
	Variable hn, W, theta0
	String inputWave, outputWave
	
	Wave/D input=$inputWave
	
	//Energy row
	Variable size1=DimSize(input,0)
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	//Angle column
	Variable size2=DimSize(input,1)
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	
	//map of k(E,theta)
	Make/O/D/N=(size1,size2) kMap
	Wave/D kMap=kMap
	SetScale/P x, offset1, delta1, kMap
	SetScale/P y, offset2, delta2, kMap
	
	kMap[][]=convert_E2k(x+hn-W)*sin(convert_deg2rad(y-theta0))
	
	//find minimum delta_k, maximum k, minimum k
	Variable minDeltaK=NaN
	Variable maxK=NaN
	Variable minK=NaN
	Variable i,j
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2-1;j+=1)
			Variable deltaK=abs(kMap[i][j+1]-kMap[i][j])
			If(numtype(minDeltaK)!=0 || deltaK<minDeltaK)
				minDeltaK=deltaK
			Endif
		Endfor
		For(j=0;j<size2;j+=1)
			If(numtype(maxK)!=0 || kMap[i][j]>maxK)
				maxK=kMap[i][j]
			Endif
			If(numtype(minK)!=0 || kMap[i][j]<minK)
				minK=kMap[i][j]
			Endif
		Endfor
	Endfor
	Print("minimum delta_k: "+num2str(minDeltaK))
	Print("k range: "+num2str(minK)+" to "+num2str(maxK))
	
	Variable deltaK_floor=OneDigitFloor(minDeltaK)
	Print("floored delta_k: "+num2str(deltaK_floor))
	
	Variable minIndex=floor(minK/deltaK_floor)
	Variable maxIndex=ceil(maxK/deltaK_floor)
	Print("floored k range: "+num2str(minIndex*deltaK_floor)+" to "+num2str(maxIndex*deltaK_floor))

	Variable kSize=maxIndex-minIndex+1
	Make/O/D/N=(size1,kSize) $outputWave
	Wave/D output=$outputWave
	SetScale/P x, offset1, delta1, output
	SetScale/P y, minIndex*deltaK_floor, deltaK_floor, output
	
	Variable e_i
	Variable k_j
	Variable k_length
	Variable theta_ij
	Variable theta_index
	For(i=0;i<size1;i+=1)
		e_i=offset1+delta1*i
		k_length=convert_E2k(e_i+hn-W)
		For(j=0;j<kSize;j+=1)
			k_j=deltaK_floor*(j+minIndex)
			theta_ij=convert_rad2deg(asin(k_j/k_length))+theta0
			theta_index=round((theta_ij-offset2)/delta2)
			If(0<=theta_index && theta_index<size2)
				output[i][j]=input[i][theta_index]
			Else
				output[i][j]=0
			Endif
		Endfor
	ENdfor
End


//convert_EAhn2Ekk: energy-angle(theta)-hn(photon energy) map to energy-momentum(kx)-momentum(kz) map
//Usage
//inputWave: energy-angle map (Ef is set to zero)
//W: work function [eV]
//theta0: theta offset [deg]
//V0: inner potential
//outputWave: energy-momentum map
Function convert_EAhn2Ekk(inputWave,W,theta0,V0,outputWave)
	Variable W, theta0, V0
	String inputWave, outputWave
	
	Wave/D input=$inputWave
	
	//Energy row
	Variable size1=DimSize(input,0)
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	//Angle column
	Variable size2=DimSize(input,1)
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	//hn layer
	Variable size3=DimSize(input,2)
	Variable offset3=DimOffset(input,2)
	Variable delta3=DimDelta(input,2)
	
	//map of kx(E,theta,hn)
	Make/O/D/N=(size1,size2,size3) kxMap
	Wave/D kxMap=kxMap
	SetScale/P x, offset1, delta1, kxMap
	SetScale/P y, offset2, delta2, kxMap
	SetScale/P z, offset3, delta3, kxMap
	
	kxMap[][][]=convert_E2k(x+z-W)*sin(convert_deg2rad(y-theta0))
	
	//find minimum delta_kx, maximum kx, minimum kx
	Variable minDeltaKx=NaN
	Variable maxKx=NaN
	Variable minKx=NaN
	Variable i,j,k
	For(i=0;i<size1;i+=1)
		For(k=0;k<size3;k+=1)
			For(j=0;j<size2-1;j+=1)
				Variable deltaKx=abs(kxMap[i][j+1][k]-kxMap[i][j][k])
				If(numtype(minDeltaKx)!=0 || deltaKx<minDeltaKx)
					minDeltaKx=deltaKx
				Endif
			Endfor
			For(j=0;j<size2;j+=1)
				If(numtype(maxKx)!=0 || kxMap[i][j][k]>maxKx)
					maxKx=kxMap[i][j][k]
				Endif
				If(numtype(minKx)!=0 || kxMap[i][j][k]<minKx)
					minKx=kxMap[i][j][k]
				Endif
			Endfor
		Endfor
	Endfor
	Print("minimum delta_kx: "+num2str(minDeltaKx))
	Print("kx range: "+num2str(minKx)+" to "+num2str(maxKx))
	
	Variable deltaKx_floor=OneDigitFloor(minDeltaKx)
	Print("floored delta_kx: "+num2str(deltaKx_floor))
	
	Variable minXIndex=floor(minKx/deltaKx_floor)
	Variable maxXIndex=ceil(maxKx/deltaKx_floor)
	Print("floored kx range: "+num2str(minXIndex*deltaKx_floor)+" to "+num2str(maxXIndex*deltaKx_floor))

	Variable kxSize=maxXIndex-minXIndex+1
		
	//map of kz(E,theta,hn)
	Make/O/D/N=(size1,size2,size3) kzMap
	Wave/D kzMap=kzMap
	SetScale/P x, offset1, delta1, kzMap
	SetScale/P y, offset2, delta2, kzMap
	SetScale/P z, offset3, delta3, kzMap
	
	Variable k_crystal
	Variable hn_k
	Variable e_i
	For(i=0;i<size1;i+=1)
		e_i=offset1+delta1*i
		For(k=0;k<size3;k+=1)
			hn_k=offset3+delta3*k
			k_crystal=convert_E2k(e_i+hn_k-W+V0)
			kzMap[i][][k]=sqrt(k_crystal^2-kxMap[i][q][k]^2)
		Endfor
	Endfor
	
	//find minimum delta_kz, maximum kz, minimum kz
	Variable minDeltaKz=NaN
	Variable maxKz=NaN
	Variable minKz=NaN
	For(i=0;i<size1;i+=1)
		For(j=0;j<size2;j+=1)
			For(k=0;k<size3-1;k+=1)
				Variable deltaKz=abs(kzMap[i][j][k+1]-kzMap[i][j][k])
				If(numtype(minDeltaKz)!=0 || deltaKz<minDeltaKz)
					minDeltaKz=deltaKz
				Endif
			Endfor
			For(k=0;k<size3;k+=1)
				If(numtype(maxKz)!=0 || kzMap[i][j][k]>maxKz)
					maxKz=kzMap[i][j][k]
				Endif
				If(numtype(minKz)!=0 || kzMap[i][j][k]<minKz)
					minKz=kzMap[i][j][k]
				Endif
			Endfor
		Endfor
	Endfor
	Print("minimum delta_kz: "+num2str(minDeltaKz))
	Print("kz range: "+num2str(minKz)+" to "+num2str(maxKz))
	
	Variable deltaKz_floor=OneDigitFloor(minDeltaKz)
	Print("floored delta_kz: "+num2str(deltaKz_floor))
	
	Variable minZIndex=floor(minKz/deltaKz_floor)
	Variable maxZIndex=ceil(maxKz/deltaKz_floor)
	Print("floored kz range: "+num2str(minZIndex*deltaKz_floor)+" to "+num2str(maxZIndex*deltaKz_floor))

	Variable kzSize=maxZIndex-minZIndex+1
	
	KillWaves kzMap, kxMap
	
	convert_EAhn2Ekk_main(inputWave,W,theta0,V0,outputWave,minXIndex,deltaKx_floor,kxSize,minZIndex,deltaKz_floor,kzSize)

End


Function convert_EAhn2Ekk_main(inputWave,W,theta0,V0,outputWave,minXIndex,deltaKx_floor,kxSize,minZIndex,deltaKz_floor,kzSize)
	String inputWave,outputWave
	Variable W,theta0,V0,minXIndex,deltaKx_floor,kxSize,minZIndex,deltaKz_floor,kzSize
	

	Wave/D input=$inputWave
	
	//Energy row
	Variable size1=DimSize(input,0)
	Variable offset1=DimOffset(input,0)
	Variable delta1=DimDelta(input,0)
	//Angle column
	Variable size2=DimSize(input,1)
	Variable offset2=DimOffset(input,1)
	Variable delta2=DimDelta(input,1)
	//hn layer
	Variable size3=DimSize(input,2)
	Variable offset3=DimOffset(input,2)
	Variable delta3=DimDelta(input,2)
	
	Make/O/D/N=(size1,kxSize,kzSize) $outputWave
	Wave/D output=$outputWave
	
	SetScale/P x, offset1, delta1, output
	SetScale/P y, minXIndex*deltaKx_floor, deltaKx_floor, output
	SetScale/P z, minZIndex*deltaKz_floor, deltaKz_floor, output
	
	Variable kx_j,kz_k
	Variable hn_ijk,theta_ijk,k_vacuum
	Variable hn_index, theta_index
	Variable i,j,k,e_i,k_crystal
	For(i=0;i<size1;i+=1)
		e_i=offset1+delta1*i
		For(j=0;j<kxSize;j+=1)
			kx_j=deltaKx_floor*(j+minXIndex)
			For(k=0;k<kzSize;k+=1)
				kz_k=deltaKz_floor*(k+minZIndex)
				k_crystal=sqrt(kx_j^2+kz_k^2)
				//convert_k2E(k_crystal)=e_i+hn_k-W+V0
				hn_ijk=convert_k2E(k_crystal)-e_i+W-V0
				k_vacuum=convert_E2k(hn_ijk+e_i-W)
				theta_ijk=convert_rad2deg(asin(kx_j/k_vacuum))+theta0
				theta_index=round((theta_ijk-offset2)/delta2)
				hn_index=round((hn_ijk-offset3)/delta3)
				
				If(0<=theta_index && theta_index<size2 && 0<=hn_index && hn_index<size3)
					output[i][j][k]=input[i][theta_index][hn_index]
				Else
					output[i][j][k]=0
				Endif
			Endfor
		Endfor
	Endfor
	
End