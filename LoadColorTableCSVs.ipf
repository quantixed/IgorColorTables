#pragma TextEncoding = "UTF-8"
#pragma rtGlobals=3		// Use modern global access method and strict wave access.
#pragma DefaultTab={3,20,4}		// Set default tab width in Igor Pro 9 and later

//To work with an expanded set of color tables in Igor.
//
//Easy loading of all the extra (non-standard) Igor color tables that ship with Igor.
//Easy loading of user-defined color tables from User Color Tables in Igor User Files directory.
//Color tables from each folder are placed in root:Packages:ColorTables:NameOfFolder: and can be used from there.
//
//Color table import from LUTs or CSV
//Bring in LUTs from ImageJ (exported as tab-separated text file, using luts2tsv.ijm)
//or bring in a CSV file from another source.
//Color tables are converted to 16-bit during load.
//16-bit ibw color tables can be saved to disk for use in other Igor experiments.

////////////////////////////////////////////////////////////////////////
// Menu items
////////////////////////////////////////////////////////////////////////
Menu "Colors"
	Submenu "More Color Tables"
		"Add Additional Igor Color Tables", /Q, LoadIBWColorTables(1)
		"Add Additional User Color Tables", /Q, LoadIBWColorTables(2)
		"Add All Color Tables", /Q, LoadIBWColorTables(3)
	End
	Submenu "Load Color Tables"
		"Load LUTs into Igor...", /Q, LoadExternalColorTables()
		"Save Imported Color Tables...", /Q, SaveColorTableWaves()
	End
	"Display All Color Tables", /Q, ShowAllColorTables()
//	"Detect Similar LUTs", SimilarityWorkflow()
End

////////////////////////////////////////////////////////////////////////
// Loading Igor Color Tables as ibw
////////////////////////////////////////////////////////////////////////
Function LoadIBWColorTables(optVar)
	Variable optVar

	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:ColorTables
	
	String pathToIBWs, dirList, ibwList, pathString, folderName
	
	Variable i
	
	if ((optVar & 2^0) != 0) // bit 0 is set
		pathToIBWs = SpecialDirPath("Igor Application",0,0,0) + "Color Tables"
		TreeLoad(pathToIBWs, "IgorExtra")
	endif
	
	if ((optVar & 2^1) != 0) // bit 1 is set
		pathToIBWs = SpecialDirPath("Igor Pro User Files",0,0,0) + "User Color Tables"
		TreeLoad(pathToIBWs, "UserExtra")
	endif
	SetDataFolder root:
End

STATIC Function TreeLoad(dirPath, folderName)
	String dirPath, folderName
	
	NewPath/O/Q/Z path1, dirPath
	if(V_Flag == -1)
		return -1
	endif
	String ibwList = IndexedFile(path1,-1,".ibw")
	if (strlen(ibwList) > 0)
		FindAndLoad(folderName,ibwList)
	endif
	String dirList = IndexedDir(path1,-1,1) // full file paths
	String pathString
	Variable i
	
	for(i = 0; i < ItemsInList(dirList); i += 1)
		pathString = StringFromList(i, dirList)
		folderName = ParseFilePath(0,pathstring,":",1,0)
		NewPath/O/Q path1, pathString
		ibwList = IndexedFile(path1,-1,".ibw")
		FindAndLoad(folderName,ibwList)
	endfor
End

STATIC Function FindAndLoad(folderName, fList)
	String folderName, fList
	fList = SortList(fList, ";", 16)
	NewDataFolder/O/S $("root:Packages:ColorTables:" + folderName)
	Variable i
	
	for(i = 0; i < ItemsInList(fList); i += 1)
		LoadWave/H/O/P=path1/Q ":" + StringFromList(i,fList)
	endfor
	KillStrings/A/Z
	KillVariables/Z V_flag
End

////////////////////////////////////////////////////////////////////////
// Loading External (8-bit) Color Tables
////////////////////////////////////////////////////////////////////////

Function LoadExternalColorTables()
	// This will load text files (.lut/tsv/txt or .csv) from a folder
	// Automatic detection of 0-1, 0-255 and 0-65535 LUTs and conversion to 16-bit
	String expDiskFolderName
	String FileList, ThisFile, fileName, plotName
	Variable FileLoop, pgNum
	
	NewPath/O/Q/M="Please find disk folder" ExpDiskFolder
	if (V_flag!=0)
		DoAlert 0, "Disk folder error"
		return -1
	endif
	
	NewDataFolder/O root:Packages
	NewDataFolder/O root:Packages:ColorTables
	
	fileList = IndexedFile(expDiskFolder,-1,".csv")
	fileList += IndexedFile(expDiskFolder,-1,".lut")
	Variable nFiles = ItemsInList(FileList)
	if(nFiles == 0)
		DoAlert 0, "No files found"
		return -1
	endif
	
	NewDataFolder/O/S root:Packages:ColorTables:Imported
	
	for (FileLoop = 0; FileLoop < nFiles; FileLoop += 1)
		ThisFile = StringFromList(FileLoop, FileList)
		fileName = ParseFilePath(3, ThisFile, ":", 0, 0)
		fileName = CleanupName(fileName,0)
		if(exists(fileName) > 0)
			fileName += "_lut"
		endif
		if(StringMatch(ThisFile,"*.csv") == 1)
			LoadWave/Q/A=rgb/J/D/W/O/L={0,0,0,0,3}/P=expDiskFolder ThisFile
		else // assume .lut or .tsv or .txt
			LoadWave/Q/A=rgb/J/D/W/O/L={0,1,0,1,3}/P=expDiskFolder ThisFile
		endif
		Concatenate/O/KILL S_WaveNames, $fileName
		Wave w = $fileName
		// convert to 16-bit
		if(wavemax(w) <= 1)
			w *= 65535
		elseif(wavemax(w) <= 255)
			w *= 257
		elseif(wavemax(w) <= 65535)
			// do nothing
		else
			Print filename, "color scale not recognised"
		endif
	endfor
	
	SetDataFolder root:
End

Function SaveColorTableWaves()
	if(!DataFolderExists("root:Packages:ColorTables:Imported"))
		DoAlert 0, "No imported color tables found"
		return -1
	else
		SetDataFolder root:Packages:ColorTables:Imported:
	endif
	
	String wList = WaveList("*",";","")
	Variable nWaves = ItemsInList(wList)
	if(nWaves == 0)
		DoAlert 0, "No color table waves found"
		return -1
	endif
	String wName, fileName

	NewPath/O/Q/M="Save ibw file in..." SaveDiskFolder
	if (V_flag!=0)
		DoAlert 0, "Disk folder error"
		Return -1
	endif
	
	Variable i
	
	for(i = 0; i < nWaves; i += 1)
		wName = StringFromList(i, wList)
		Wave w0 = $wName
		fileName = wName + ".ibw"
		Save/C/O/P=SaveDiskFolder w0 as fileName
	endfor
	
	SetDataFolder root:
End

////////////////////////////////////////////////////////////////////////
// Visualizing Color Tables
////////////////////////////////////////////////////////////////////////

Function ShowAllColorTables()
	Make/O/N=(256,40) testimg=p

	SetDataFolder root:Packages:ColorTables:
	DFREF dfr = GetDataFolderDFR()
	Variable nFolders = CountObjectsDFR(dfr, 4)
	String folderName, wList, wName, plotName
	Variable nWaves, counter = 0
	
	Variable i,j
	
	for(i = 0; i < nFolders; i += 1)
		folderName = GetIndexedObjNameDFR(dfr, 4, i)
		SetDataFolder $("root:Packages:ColorTables:" + folderName)
		wList = WaveList("*",";","")
		nWaves = ItemsInList(wList)
		for(j = 0; j < nWaves; j += 1)
			wName = StringFromList(j, wList)
			Wave w = $wName
			plotName = "img" + num2str(counter)
			KillWindow/Z $plotName
			NewImage/K=0/HIDE=1/N=$plotName testimg
			ModifyImage/W=$plotName testimg ctab= {*,*,w,0}
			ModifyGraph/W=$plotName nticks(left)=0,noLabel(left)=2
			TextBox/C/N=text0/F=0/A=LB/X=5.00/Y=0.00/E folderName + "_" + wName
			counter += 1
		endfor
	endfor
	
	Variable TablesPerPage = 27, pgnum
	MakeSummaryLayout(counter,TablesPerPage)
	
	for (i = 0; i < counter; i += 1)
		plotName = "img" + num2str(counter - 1 - i)
		pgnum = 1 + floor(i / TablesPerPage)
		AppendLayoutObject/W=summaryLayout/PAGE=(pgnum) graph $plotName
	endfor
	TileLayout(counter,TablesPerPage)
	
	SetDataFolder root:
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
	SavePICT/PGR=(1,-1)/E=-2/W=(0,0,0,0) as "AllColourTables.pdf"
End


Function SimilarityWorkflow()
	ClusterLuts()
	FindIdentities()
	// possibly here we can delete duplicates
	// show hierarchical clustering of colorTables
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
		DoAlert 0, "To use this, you need a list of corrected wave names"
		return -1
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