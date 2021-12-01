#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later

////////////////////////////////////////////////////////////////////////
// Menu items
////////////////////////////////////////////////////////////////////////
Menu "Macros"
	"Color Tables from LUTs...", LoadLUTColorTables()
	"Detect Similar LUTs", SimilarityWorkflow()
	"Save Color Tables...", SaveColorTableWaves()
	"Load Color Table ibws into Igor...", LoadColorTables()
End

////////////////////////////////////////////////////////////////////////
// Master functions and wrappers
////////////////////////////////////////////////////////////////////////
Function LoadColorTables()
	// This will load from a folder of waves
	// rewrote some existing code to load in
	// color maps from http://peterkovesi.com/projects/colourmaps/
	String expDiskFolderName
	String FileList, ThisFile, ctName, plotName
	Variable FileLoop, pgNum
	
	NewPath/O/Q/M="Please find disk folder" ExpDiskFolder
	if (V_flag!=0)
		DoAlert 0, "Disk folder error"
		Return -1
	endif
	PathInfo /S ExpDiskFolder
	ExpDiskFolderName = S_path
	FileList=IndexedFile(expDiskFolder,-1,".csv")
	Variable nFiles=ItemsInList(FileList)
	Make/O/T/N=(nFiles) CTNameWave
	Make/O/N=(256,40) testimg=p
	
	for (FileLoop = 0; FileLoop < nFiles; FileLoop += 1)
		ThisFile = StringFromList(FileLoop, FileList)
		LoadWave/Q/A=rgb/J/D/W/O/L={0,0,0,0,3}/P=expDiskFolder ThisFile
		CTNameWave[FileLoop] = RemoveEnding(ThisFile,".csv")
		ctName = "ColorTable_" + num2str(FileLoop)
		Concatenate/O/KILL "rgb0;rgb1;rgb2;", $ctName
		Wave ctMat = $ctName
		// convert to 16-bit
		ctMat *=257
		plotName = "img" + num2str(FileLoop)
		KillWindow/Z $plotName
		NewImage/K=0/HIDE=1/N=$plotName testimg
		ModifyImage/W=$plotName testimg ctab= {*,*,ctMat,0}
		ModifyGraph/W=$plotName nticks(left)=0,noLabel(left)=2
		TextBox/C/N=text0/F=0/A=LB/X=5.00/Y=0.00/E RemoveEnding(ThisFile,".csv")
	endfor
	
	Variable TablesPerPage = 27
	MakeSummaryLayout(nFiles,TablesPerPage)
	WAVE/Z/T CTNameWave
	Make/O/FREE/N=(nFiles) tempIWave=p
	Sort CTNameWave, tempIWave
	
	for (FileLoop = 0; FileLoop < nFiles; FileLoop += 1)
		plotName = "img" + num2str(tempIWave[FileLoop])
		pgnum = 1 + floor(FileLoop / TablesPerPage)
		AppendLayoutObject/W=summaryLayout/PAGE=(pgnum) graph $plotName
	endfor
	TileLayout(nFiles,TablesPerPage)
End

Function SimilarityWorkflow()
	ClusterLuts()
	FindIdentities()
	// possibly here we can delete duplicates
	// show hierarchical clustering of colorTables
End

///	@param	nFiles	total number of TIFFs
///	@param	plotNum	number of plots per page
Function MakeSummaryLayout(nFiles,plotNum)
	Variable nFiles,plotNum
	Variable pgMax = floor((nFiles -1) / plotNum) + 1
	
	Variable i
	
	DoWindow/K SummaryLayout
	NewLayout /N=summaryLayout
	for(i = 1; i < pgMax; i += 1)
		LayoutPageAction/W=summaryLayout appendPage
	endfor
	
	LayoutPageAction size(-1)=(595, 842), margins(-1)=(18, 18, 18, 18)
	ModifyLayout units=0
	ModifyLayout frame=0,trans=1
End

///	@param	nFiles	total number of TIFFs
///	@param	plotNum	number of plots per page
Function TileLayout(nFiles,plotNum)
	Variable nFiles,plotNum
	Variable pgMax = floor((nFiles -1) / plotNum) + 1
	Variable nRow = ceil(plotNum / 3)
	
	Variable i
	
	DoWindow /F summaryLayout
	for(i = 1; i < pgMax + 1; i += 1)
		LayoutPageAction/W=summaryLayout page=(i)
		ModifyLayout/W=summaryLayout frame=0,trans=1
		Execute /Q "Tile/A=("+num2str(nRow)+",3)/O=1"
	endfor
	SavePICT/PGR=(1,-1)/E=-2/W=(0,0,0,0) as "summary.pdf"
End

Function LoadLUTColorTables()
	// This will load from a folder of waves
	// rewrote some existing code to load in
	// color maps as LUTs
	String expDiskFolderName
	String FileList, ThisFile, ctName, plotName
	Variable FileLoop, pgNum
	
	NewPath/O/Q/M="Please find disk folder" ExpDiskFolder
	if (V_flag!=0)
		DoAlert 0, "Disk folder error"
		Return -1
	endif
	PathInfo /S ExpDiskFolder
	ExpDiskFolderName = S_path
	FileList=IndexedFile(expDiskFolder,-1,".lut")
	Variable nFiles=ItemsInList(FileList)
	Make/O/T/N=(nFiles) CTNameWave
	Make/O/N=(256,40) testimg=p
	
	for (FileLoop = 0; FileLoop < nFiles; FileLoop += 1)
		ThisFile = StringFromList(FileLoop, FileList)
		LoadWave/Q/A=rgb/J/D/W/O/L={0,1,0,1,3}/P=expDiskFolder ThisFile
		CTNameWave[FileLoop] = RemoveEnding(ThisFile,".lut")
		ctName = "ColorTable_" + num2str(FileLoop)
		Concatenate/O/KILL "red;green;blue;", $ctName
		Wave ctMat = $ctName
		// convert to 16-bit
		ctMat *=257
		plotName = "img" + num2str(FileLoop)
		KillWindow/Z $plotName
		NewImage/K=0/HIDE=1/N=$plotName testimg
		ModifyImage/W=$plotName testimg ctab= {*,*,ctMat,0}
		ModifyGraph/W=$plotName nticks(left)=0,noLabel(left)=2
		TextBox/C/N=text0/F=0/A=LB/X=5.00/Y=0.00/E RemoveEnding(ThisFile,".lut")
	endfor
	
	Variable TablesPerPage = 27
	MakeSummaryLayout(nFiles,TablesPerPage)
	WAVE/Z/T CTNameWave
	Make/O/FREE/N=(nFiles) tempIWave=p
	Sort CTNameWave, tempIWave
	
	for (FileLoop = 0; FileLoop < nFiles; FileLoop += 1)
		plotName = "img" + num2str(tempIWave[FileLoop])
		pgnum = 1 + floor(FileLoop / TablesPerPage)
		AppendLayoutObject/W=summaryLayout/PAGE=(pgnum) graph $plotName
	endfor
	TileLayout(nFiles,TablesPerPage)
End

Function SaveColorTableWaves()
	String wList = WaveList("ColorTable_*",";","")
	Variable nWaves = ItemsInList(wList)
	String wName, fileName
	WAVE/Z/T CTNameWave
	if(!WaveExists(CTNameWave))
		DoAlert 0, "No Color Table Name Wave(s)."
	endif
	NewPath/O/Q/M="Save ibw file in..." SaveDiskFolder
	if (V_flag!=0)
		DoAlert 0, "Disk folder error"
		Return -1
	endif
	
	Variable i
	
	for(i = 0; i < nWaves; i += 1)
		wName = StringFromList(i, wList)
		Wave w0 = $wName
		fileName = CTNameWave[i] + ".ibw"
		Save/C/O/P=SaveDiskFolder w0 as fileName
	endfor
End

// finds average Euclidean distance between different LUTS in RGB space
Function ClusterLuts()
	String wList = WaveList("ColorTable_*",";","")
	Variable nWaves = ItemsInList(wList)
	
	Make/O/N=(nWaves,nWaves) distMat
	
	distMat[][] = GetDistance(p,q)
End

STATIC Function GetDistance(pNum,qNum)
	Variable pNum, qNum
	Wave wp = $("ColorTable_" + num2str(pNum))
	Wave wq = $("ColorTable_" + num2str(qNum))
	
	MatrixOp/O/FREE sqDiffW = (wp - wq) * (wp - wq)
	MatrixOp/O/FREE distW = sqrt(sumcols(sqDiffW))
	
	return sum(distW) / 256
End

// right now this function just flags the identical LUTs and does not remove them
Function FindIdentities()
	WAVE/Z distMat
	Duplicate/O/FREE distMat, dMat, pMat, qMat
	pMat[][] = p
	qMat[][] = q
	WAVE/Z/T CTNameWave
	
	Variable nRow = numpnts(distMat)
	Redimension/N=(nRow) dMat, pMat, qMat
	Variable i
	
	for(i = 0; i < nRow; i += 1)
		if(dMat[i] == 0)
			if(pMat[i] != qMat[i] && pMat[i] < qMat[i])
				Print pMat[i], qMat[i], "--->",CTNameWave[pMat[i]],"matches",CTNameWave[qMat[i]]
			endif
		else
			continue
		endif
	endfor
End

// Because the names given are too long for igor waves
// I made a corrected version of the textwave containing names
Function RenameCTs()
	WAVE/Z/T CorrNameWave
	if(!WaveExists(CorrNameWave))
		abort "To use this, you need a list of corrected wave names"
	endif
	
	String wList = WaveList("ColorTable_*",";","")
	Variable nWaves = ItemsInList(wList)
	String wName, newName
	
	Variable i
	
	for(i = 0; i < nWaves; i += 1)
		wName = "ColorTable_" + num2str(i)
		Wave w0 = $wName
		newName = CorrNameWave[i]
		Rename w0, $newName
	endfor
End