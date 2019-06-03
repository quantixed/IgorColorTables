function lutValuesToTable(filePath) {
	getLut(reds, greens, blues);
	tableTitle = "lutValueTable";
	eightBit = 256;
	run("Table...", "name=["+tableTitle+"] width=600 height=250");
	print("["+tableTitle+"]", "\\Headings:Index\tRed\tGreen\tBlue");
	for (i = 0; i < eightBit; i ++) {
		rowString = d2s(i,0) + "\t" + reds[i] + "\t" + greens[i] + "\t" + blues[i];
		print("["+tableTitle+"]", rowString);
	}
	selectWindow(tableTitle);
	saveAs("results",filePath);
	close(tableTitle);
}

dirPath = getDirectory("Select a directory");
// Create the output folder
fileDirPath = dirPath + "LutTSVs" + File.separator;
File.makeDirectory(fileDirPath);
lutdirname = "luts";
lutdir = getDirectory("startup") + lutdirname + File.separator;
if (!File.exists(lutdir))
 exit("The 'luts' folder not found in the ImageJ folder");
list = getFileList(lutdir);
setBatchMode(true);
for (i=0; i<list.length; i++) {
	if (endsWith(list[i], ".lut")) {
		//selectWindow("ramp");
		open(lutdir+list[i]);
		filePath = fileDirPath + list[i];
		lutValuesToTable(filePath);
		}
	}
close();
setBatchMode(false);