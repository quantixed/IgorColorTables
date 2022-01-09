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
	Submenu "Display Color Tables"
		"Display Color Tables (Linear)", /Q, ShowAllColorTables(0)
		"Display Color Tables (Both)", /Q, ShowAllColorTables(1)
	End
	"List Identical Color Tables", SimilarityWorkflow()
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

Function ShowAllColorTables(optVar)
	Variable optVar
	SetDataFolder root:
	if(optVar == 1)
		LatinSquare(9)
		WAVE/Z lsMat
	endif
	Make/O/N=(256,40) testimg=p

	SetDataFolder root:Packages:ColorTables:
	DFREF dfr = GetDataFolderDFR()
	Variable nFolders = CountObjectsDFR(dfr, 4)
	String folderName, wList, wName, plotName0, plotName1
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
			plotName0 = "img" + num2str(counter)
			KillWindow/Z $plotName0
			NewImage/K=0/HIDE=1/N=$plotName0 testimg
			ModifyImage/W=$plotName0 testimg ctab= {*,*,w,0}
			ModifyGraph/W=$plotName0 nticks(left)=0,noLabel(left)=2
			TextBox/C/N=text0/F=0/A=LB/X=5.00/Y=0.00/E folderName + "_" + wName
			if(optVar == 1)
				plotName1 = "ls" + num2str(counter)
				KillWindow/Z $plotName1
				NewImage/K=0/HIDE=1/N=$plotName1 lsMat
				ModifyImage/W=$plotName1 lsMat ctab= {*,*,w,0}
				ModifyGraph/W=$plotName1 nticks=0,noLabel=2,width={Aspect,1}
				TextBox/C/N=text0/F=0/A=LB/X=5.00/Y=0.00/E folderName + "_" + wName
			endif
			counter += 1
		endfor
	endfor
	
	// also show built-in Igor Color Tables
	wList = CTabList()
	nWaves = ItemsInList(wList)
	for(i = 0; i < nWaves; i += 1)
		wName = StringFromList(i, wList) // not actually a wave
		plotName0 = "img" + num2str(counter)
		KillWindow/Z $plotName0
		NewImage/K=0/HIDE=1/N=$plotName0 testimg
		ModifyImage/W=$plotName0 testimg ctab= {*,*,$wName,0}
		ModifyGraph/W=$plotName0 nticks(left)=0,noLabel(left)=2
		TextBox/C/N=text0/F=0/A=LB/X=5.00/Y=0.00/E folderName + "_" + wName
		if(optVar == 1)
			plotName1 = "ls" + num2str(counter)
			KillWindow/Z $plotName1
			NewImage/K=0/HIDE=1/N=$plotName1 lsMat
			ModifyImage/W=$plotName1 lsMat ctab= {*,*,$wName,0}
			ModifyGraph/W=$plotName1 nticks=0,noLabel=2,width={Aspect,1}
			TextBox/C/N=text0/F=0/A=LB/X=5.00/Y=0.00/E folderName + "_" + wName
		endif
		counter += 1
	endfor
	
	Variable TablesPerPage = 27, pgnum
	MakeTheLayout(counter,TablesPerPage, "allLinearCTs")
	
	for (i = 0; i < counter; i += 1)
		plotName0 = "img" + num2str(counter - 1 - i)
		pgnum = 1 + floor(i / TablesPerPage)
		AppendLayoutObject/W=allLinearCTs/PAGE=(pgnum) graph $plotName0
	endfor
	TileLayout(counter,TablesPerPage, 3, "allLinearCTs")
	
	if(optVar == 1)
		TablesPerPage = 40
		MakeTheLayout(counter,TablesPerPage, "allLSCTs")
	
		for (i = 0; i < counter; i += 1)
			plotName1 = "ls" + num2str(counter - 1 - i)
			pgnum = 1 + floor(i / TablesPerPage)
			AppendLayoutObject/W=allLSCTs/PAGE=(pgnum) graph $plotName1
		endfor
		TileLayout(counter,TablesPerPage, 5, "allLSCTs")
	endif
	
	SetDataFolder root:
End

///	@param	nFiles	total number of TIFFs
///	@param	plotNum	number of plots per page
///	@param	layoutName	name of layout
Function MakeTheLayout(nFiles, plotNum, layoutName)
	Variable nFiles,plotNum
	String layoutName
	
	Variable pgMax = floor((nFiles -1) / plotNum) + 1
	
	Variable i
	
	DoWindow/K $layoutName
	NewLayout /N=$layoutName
	for(i = 1; i < pgMax; i += 1)
		LayoutPageAction/W=$layoutName appendPage
	endfor
	
	LayoutPageAction size(-1)=(595, 842), margins(-1)=(18, 18, 18, 18)
	ModifyLayout units=0
	ModifyLayout frame=0,trans=1
End

///	@param	nFiles	total number of graphs
///	@param	plotNum	number of plots per page
///	@param	nCol	number of columns on a page
///	@param	layoutName	name of layout
Function TileLayout(nFiles, plotNum, nCol, layoutName)
	Variable nFiles, plotNum, nCol
	String layoutName
	
	Variable pgMax = floor((nFiles -1) / plotNum) + 1
	Variable nRow = ceil(plotNum / nCol)
	
	Variable i
	
	DoWindow/F $layoutName
	for(i = 1; i < pgMax + 1; i += 1)
		LayoutPageAction/W=$layoutName page=(i)
		ModifyLayout/W=$layoutName frame=0,trans=1
		Execute/Q "Tile/A=("+num2str(nRow)+","+num2str(nCol)+")/O=1"
	endfor
	SavePICT/PGR=(1,-1)/E=-2/W=(0,0,0,0) as layoutname + ".pdf"
End

////////////////////////////////////////////////////////////////////////
// Latin Squares
////////////////////////////////////////////////////////////////////////

Function MakeLatinSquare(nn)
	Variable nn
	String plotName = "ls_0"
	if(LatinSquare(nn) == 1)
		WAVE/Z lsMat
		KillWindow/Z $plotName
		NewImage/S=0/N=$plotName lsMat
		ModifyImage/W=$plotname lsMat ctab= {*,*,ColdWarm,0}
	endif
End

Threadsafe Function LatinSquare(lsSize)
	Variable lsSize

	Make/O/N=(lsSize,lsSize) lsMat = 0
	Make/O/N=(lsSize)/FREE intW = p + 1, mixW
	Variable okVar
	
	Variable i
	
	// use shuffled sequence to fill all but last column
	for(i = 0; i < lsSize - 1; i += 1)
		okVar = 0
		do
			RandomiseWave(intW,mixW,lsSize)
			Duplicate/O/RMD=[][0,i]/FREE lsMat, lsTemp
			lsTemp[][i] = mixW[p]
			okVar = lsCheck(lsTemp,lsSize,i)
		while (okVar == 0)
		lsMat[][i] = mixW[p]
	endfor
	// quicker to fill last column by simply finding missing values
	FillLastColumn(lsMat,lsSize)
	
	return 1
End

Threadsafe Function RandomiseWave(w0,w1,np)
	Wave w0,w1
	Variable np
	// reset w1 as w0
	w1 = w0
	Make/O/N=(np)/FREE randW = enoise(1)
	Sort randW, w1
End

Threadsafe Function lsCheck(w,n,ii)
	Wave w
	int n,ii
	
	if(ii == 0)
		return 1 // we are at the first column, all OK
	endif
	
	Variable i
	
	for(i = 0; i < n; i += 1)
		MatrixOp/O/FREE rowW = row(w,i)^t // make a column of the ith row
		FindDuplicates/FREE/Z/RN=dupRemW rowW
		if(numpnts(dupRemW) < numpnts(rowW))
			return 0 // row has a duplicate so we need to try again
		endif
	endfor
	// if we get here all is good
	return 1
End

Threadsafe Function FillLastColumn(w,np)
	Wave w
	Int np
	Variable missingVal
	
	Variable i,j,k
	
	for(i = 0; i < np; i += 1)
		// check row
		MatrixOp/O/FREE thisRow = row(w,i)
		Redimension/N=(np-1) thisRow // row as 1D wave missing last point
		Sort thisRow, thisRow
		
		missingVal = 9
		for(j = 0; j < np - 1; j += 1)
			if(thisRow[j] != j + 1)
				missingVal = j + 1
				break
			endif
		endfor
		w[i][np-1] = missingVal
	endfor
End

////////////////////////////////////////////////////////////////////////
// Identical Color Table detection
////////////////////////////////////////////////////////////////////////

Function SimilarityWorkflow()
	ClusterLuts()
	// possibly here we can delete duplicates
	// show hierarchical clustering of colorTables
End

// finds average Euclidean distance between different LUTS in RGB space
Function ClusterLuts()
	// build a list of Color Tables
	SetDataFolder root:Packages:ColorTables:
	DFREF dfr = GetDataFolderDFR()
	Variable nFolders = CountObjectsDFR(dfr, 4)
	String folderName, thisList
	String wList = ""
	
	Variable i,j
	
	for(i = 0; i < nFolders; i += 1)
		folderName = GetIndexedObjNameDFR(dfr, 4, i)
		SetDataFolder $("root:Packages:ColorTables:" + folderName)
		thisList = WaveList("*",";","")
		for(j = 0; j < ItemsInList(thisList); j += 1)
			wList += "root:Packages:ColorTables:" + folderName + ":" + StringFromList(j,thisList) + ";"
		endfor
	endfor
	
	SetDataFolder root:
	Variable nWaves = ItemsInList(wList)
	Make/O/N=(nWaves,nWaves) distMat
	distMat[][] = GetDistance(StringFromList(p,wList),StringFromList(q,wList))
	
	// now flag the identical Color Tables, do not remove them
	Duplicate/O/FREE distMat, dMat, pMat, qMat
	pMat[][] = p
	qMat[][] = q
	
	Variable nRow = numpnts(distMat)
	Redimension/N=(nRow) dMat, pMat, qMat
	String  labelList = ReplaceString("root:Packages:ColorTables:",wList,"")
	
	for(i = 0; i < nRow; i += 1)
		if(dMat[i] == 0)
			if(pMat[i] != qMat[i] && pMat[i] < qMat[i])
				Print pMat[i], qMat[i], "--->",StringFromList(pMat[i],labelList),"matches",StringFromList(qMat[i],labelList)
			endif
		else
			continue
		endif
	endfor
End

STATIC Function GetDistance(pName,qName)
	String pName, qName
	Wave wp = $pName
	Wave wq = $qName
	
	// if the number of rows is unequal, return non-zero value
	if(DimSize(wp,0) != DimSize(wq,0))
		return 1
	endif
	
	MatrixOp/O/FREE sqDiffW = (wp - wq) * (wp - wq)
	MatrixOp/O/FREE distW = sqrt(sumcols(sqDiffW))
	
	return sum(distW) / 256
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

