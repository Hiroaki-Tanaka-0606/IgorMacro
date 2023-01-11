#pragma rtGlobals=3		// Use modern global access method and strict wave access.

//Template Socket3DViewer
//argumentList:
//[0]: name of the panel(=name of the Diagram wave)
//[1]: Coordinate3D socket to use
//[2]: E waveInfo
//[3]: x waveInfo
//[4]: y waveInfo
//[5]: xLabel
//[6]: yLabel
Function IAFt_Socket3DViewer(argumentList)
	String argumentList
	If(ItemsInList(argumentList)<4)
		Print("Error: Template 3DViewer need four arguments")
		return 0
	ENdif
	String PanelName=stringfromlist(0,argumentList)
	String socketName=StringFromList(1,argumentList)
	String EInfoName=StringFromList(2,argumentList)
	String xInfoName=StringFromList(3,argumentList)
	String yInfoName=StringFromList(4,argumentList)
	String xLabelName=StringFromList(5,argumentList)
	String yLabelName=StringFromList(6,argumentList)
	Make/O/T/N=(38,29) $PanelName
	
	//diagram wave
	Wave/T D=$PanelName
	//suffix
	String S="_"+PanelName
	
	//Ex
	D[0][0]="Data";      D[0][1]="Variable";     D[0][2]="_Ex_start"+S
	D[1][0]="Data";      D[1][1]="Variable";     D[1][2]="_Ex_end"+S
	D[2][0]="Data";      D[2][1]="Wave2D";       D[2][2]="ExCut"+S
	D[3][0]="Function";  D[3][1]="MakeEx_Coord"; D[3][2]="MExC"+S; D[3][3]=EInfoName; D[3][4]=xInfoName; D[3][5]=yInfoName; D[3][6]=D[0][2]; D[3][7]=D[1][2]; D[3][8]=socketName; D[3][9]=D[2][2]
	//Ey	
	D[4][0]="Data";      D[4][1]="Variable";     D[4][2]="_Ey_start"+S
	D[5][0]="Data";      D[5][1]="Variable";     D[5][2]="_Ey_end"+S
	D[6][0]="Data";      D[6][1]="Wave2D";       D[6][2]="EyCut"+S
	D[7][0]="Function";  D[7][1]="MakeEy_Coord"; D[7][2]="MEyC"+S;  D[7][3]=EInfoName; D[7][4]=xInfoName; D[7][5]=yInfoName; D[7][6]=D[4][2]; D[7][7]=D[5][2]; D[7][8]=socketName; D[7][9]=D[6][2]
	//xy
	D[8][0]="Data";      D[8][1]="Variable";     D[8][2]="_xy_start"+S
	D[9][0]="Data";      D[9][1]="Variable";     D[9][2]="_xy_end"+S
	D[10][0]="Data";     D[10][1]="Wave2D";      D[10][2]="xyCut"+S
	D[11][0]="Function"; D[11][1]="Makexy_Coord";D[11][2]="MxyC"+S; D[11][3]=EInfoName; D[11][4]=xInfoName; D[11][5]=yInfoName; D[11][6]=D[8][2]; D[11][7]=D[9][2]; D[11][8]=socketName; D[11][9]=D[10][2]
	//cut lines
	D[12][0]="Data";     D[12][1]="Wave2D";      D[12][2]="_ECut"+S;
	D[13][0]="Data";     D[13][1]="Wave2D";      D[13][2]="_xCut"+S;
	D[14][0]="Data";     D[14][1]="Wave2D";      D[14][2]="_yCut"+S;
	D[15][0]="Function"; D[15][1]="CutLines3D2";  D[15][2]="_CL3"+S; D[15][3]=EInfoName; D[15][4]=xInfoName; D[15][5]=yInfoName; D[15][6]=D[8][2]; D[15][7]=D[9][2]; D[15][8]=D[4][2]; D[15][9]=D[5][2]; D[15][10]=D[0][2]; D[15][11]=D[1][2]; D[15][12]=D[12][2]; D[15][13]=D[13][2]; D[15][14]=D[14][2]
	//Ex value2index
	D[16][0]="Data";     D[16][1]="Variable";    D[16][2]="_ExCenter"+S	
	D[17][0]="Data";     D[17][1]="Variable";    D[17][2]="_ExWidth"+S
	D[18][0]="Function"; D[18][1]="Value2Index"; D[18][2]="_yI"+S; D[18][3]=yInfoName; D[18][4]=D[16][2]; D[18][5]=D[17][2]; D[18][6]=D[0][2]; D[18][7]=D[1][2]
	//Ey value2index
	D[19][0]="Data";     D[19][1]="Variable";    D[19][2]="_EyCenter"+S	
	D[20][0]="Data";     D[20][1]="Variable";    D[20][2]="_EyWidth"+S
	D[21][0]="Function"; D[21][1]="Value2Index"; D[21][2]="_xI"+S; D[21][3]=xInfoName; D[21][4]=D[19][2]; D[21][5]=D[20][2]; D[21][6]=D[4][2]; D[21][7]=D[5][2]
	//xy value2index
	D[22][0]="Data";     D[22][1]="Variable";    D[22][2]="_xyCenter"+S	
	D[23][0]="Data";     D[23][1]="Variable";    D[23][2]="_xyWidth"+S
	D[24][0]="Function"; D[24][1]="Value2Index"; D[24][2]="_EI"+S; D[24][3]=EInfoName; D[24][4]=D[22][2]; D[24][5]=D[23][2]; D[24][6]=D[8][2]; D[24][7]=D[9][2]
	//Ex centerdelta
	D[25][0]="Data";     D[25][1]="Variable";    D[25][2]="_ExCenterDelta"+S
	D[26][0]="Function"; D[26][1]="DeltaChange"; D[26][2]="_ExCC"+S; D[26][3]=yInfoName; D[26][4]=D[25][2]; D[26][5]=D[16][2]
	//Ex widthdelta
	D[27][0]="Data";     D[27][1]="Variable";    D[27][2]="_ExWidthDelta"+S
	D[28][0]="Function"; D[28][1]="DeltaChange"; D[28][2]="_ExWC"+S; D[28][3]=yInfoName; D[28][4]=D[27][2]; D[28][5]=D[17][2]
	//Ey centerdelta
	D[29][0]="Data";     D[29][1]="Variable";    D[29][2]="_EyCenterDelta"+S
	D[30][0]="Function"; D[30][1]="DeltaChange"; D[30][2]="_EyCC"+S; D[30][3]=xInfoName; D[30][4]=D[29][2]; D[30][5]=D[19][2]
	//Ey widthdelta
	D[31][0]="Data";     D[31][1]="Variable";    D[31][2]="_EyWidthDelta"+S
	D[32][0]="Function"; D[32][1]="DeltaChange"; D[32][2]="_EyWC"+S; D[32][3]=xInfoName; D[32][4]=D[31][2]; D[32][5]=D[20][2]
	//xy centerdelta
	D[33][0]="Data";     D[33][1]="Variable";    D[33][2]="_xyCenterDelta"+S
	D[34][0]="Function"; D[34][1]="DeltaChange"; D[34][2]="_xyCC"+S; D[34][3]=EInfoName; D[34][4]=D[33][2]; D[34][5]=D[22][2]
	//xy widthdelta
	D[35][0]="Data";     D[35][1]="Variable";    D[35][2]="_xyWidthDelta"+S
	D[36][0]="Function"; D[36][1]="DeltaChange"; D[36][2]="_xyWC"+S; D[36][3]=EInfoName; D[36][4]=D[35][2]; D[36][5]=D[23][2]
	//Panel
	D[37][0]="Panel";    D[37][1]="3DViewer";    D[37][2]=PanelName;
	D[37][3]=D[2][2];    D[37][4]=D[6][2];       D[37][5]=D[10][2];
	D[37][6]=D[0][2];    D[37][7]=D[1][2];       D[37][8]=D[4][2];
	D[37][9]=D[5][2];    D[37][10]=D[8][2];      D[37][11]=D[9][2];
	D[37][12]=D[16][2];  D[37][13]=D[17][2];     D[37][14]=D[19][2];
	D[37][15]=D[20][2];  D[37][16]=D[22][2];     D[37][17]=D[23][2];
	D[37][18]=xLabelName;D[37][19]=yLabelName;   D[37][20]=D[12][2];
	D[37][21]=D[13][2];  D[37][22]=D[14][2];     D[37][23]=D[25][2];
	D[37][24]=D[29][2];  D[37][25]=D[33][2];     D[37][26]=D[27][2];
	D[37][27]=D[31][2];  D[37][28]=D[35][2];
	
	return 1

End
	

//Function CutLines3D2: second version to create Energy and momentum-x and momentum-y cut lines 
Function/S IAFf_CutLines3D2_Definition()
	return "12;0;0;0;0;0;0;0;0;0;1;1;1;Wave1D;Wave1D;Wave1D;Variable;Variable;Variable;Variable;Variable;Variable;Wave2D;Wave2D;Wave2D"
End

Function IAFf_CutLines3D2(argumentList)
	String argumentList
	
	//0th argument: E waveInfo
	String EWaveInfoArg=StringFromList(0,argumentList)
	
	//1st argument: x waveInfo
	String xWaveInfoArg=StringFromList(1,argumentList)
	
	//2nd argument: y waveInfo
	String yWaveInfoArg=StringFromList(2,argumentList)
	
	//3rd argument: E start index (energy axis)
	String EStartIndexArg=StringFromList(3,argumentList)
	
	//4th argument: E end index (energy axis)
	String EEndIndexArg=StringFromList(4,argumentList)
	
	//5th argument: x start index (momentum-x axis)
	String xStartIndexArg=StringFromList(5,argumentList)
	
	//6th argument: x end index (momentum-x axis)
	String xEndIndexArg=StringFromList(6,argumentList)
	
	//7th argument: y start index (momentum-y axis)
	String yStartIndexArg=StringFromList(7,argumentList)
	
	//8th argument: y end index (momentum-y axis)
	String yEndIndexArg=StringFromList(8,argumentList)
	
	//9th argument: E cut (appear on Ex and Ey map)
	String EWaveArg=StringFromList(9,argumentList)
	
	//10th argument: x cut (appear on Ex and xy map)
	String xWaveArg=StringFromList(10,argumentList)
	
	//11th argument: y cut (appear on Ey and xy map)
	String yWaveArg=StringFromList(11,argumentList)
	
	NVAR EStartIndex=$EStartIndexArg
	NVAR EEndIndex=$EEndIndexArg
	NVAR xStartIndex=$xStartIndexArg
	NVAR xEndIndex=$xEndIndexArg
	NVAR yStartIndex=$yStartIndexArg
	NVAR yEndIndex=$yEndIndexArg
	
	Wave/D EWaveInfo=$EWaveInfoArg
	Variable offset1=EWaveInfo[0]
	Variable delta1=EWaveInfo[1]
	
	Wave/D xWaveInfo=$xWaveInfoArg
	Variable offset2=xWaveInfo[0]
	Variable delta2=xWaveInfo[1]
	
	Wave/D yWaveInfo=$yWaveInfoArg
	Variable offset3=yWaveInfo[0]
	Variable delta3=yWaveInfo[1]
	
	Variable EStartValue=offset1+delta1*(EStartIndex-0.5)
	Variable EEndValue=offset1+delta1*(EEndIndex+0.5)
	
	Variable xStartValue=offset2+delta2*(xStartIndex-0.5)
	Variable xEndValue=offset2+delta2*(xEndIndex+0.5)
	
	Variable yStartValue=offset3+delta3*(yStartIndex-0.5)
	Variable yEndValue=offset3+delta3*(yEndIndex+0.5)
	
	Make/O/D/N=(4,2) $EWaveArg
	Wave/D ECut=$EWaveArg
	ECut[0][0]=EStartValue
	ECut[0][1]=-inf
	ECut[1][0]=EStartValue
	ECut[1][1]=inf
	ECut[2][0]=EEndValue
	ECut[2][1]=inf
	ECut[3][0]=EEndValue
	ECut[3][1]=-inf
	
	Make/O/D/N=(4,2) $xWaveArg
	Wave/D xCut=$xWaveArg
	xCut[0][0]=xStartValue
	xCut[0][1]=-inf
	xCut[1][0]=xStartValue
	xCut[1][1]=inf
	xCut[2][0]=xEndValue
	xCut[2][1]=inf
	xCut[3][0]=xEndValue
	xCut[3][1]=-inf
	
	Make/O/D/N=(4,2) $yWaveArg
	Wave/D yCut=$yWaveArg
	yCut[0][0]=yStartValue
	yCut[0][1]=-inf
	yCut[1][0]=yStartValue
	yCut[1][1]=inf
	yCut[2][0]=yEndValue
	yCut[2][1]=inf
	yCut[3][0]=yEndValue
	yCut[3][1]=-inf
End
