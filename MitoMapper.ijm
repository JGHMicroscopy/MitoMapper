dir = getDirectory("Choose a Directory");
list = getFileList(dir);
ts= false //troubleshoot mode
for (c = 0; c < list.length; c++) {
	path = dir + list[c];
	   if (!File.isFile(path)) {
        continue; 
    }
    	if (File.isFile(path)) {
        open(path);
    }        
//setup and load all the images
	tit= getTitle();
	tif= indexOf(tit, ".tif");
	name=  substring(tit, 0, tif);
	getDimensions(W, H, channels, slices, frames);
	getPixelSize(unit, pixelWidth, pixelHeight);
	ASF= (pixelWidth*pixelHeight);
	PSF= floor(0.2/pixelWidth);
	setForegroundColor(255, 255, 255);
	setBackgroundColor(0, 0, 0);
	run("Set Measurements...", "area mean standard center shape redirect=None decimal=3");
	roiManager("reset");
	run("Clear Results");
	run("8-bit");
	open(dir+"/Cell_Masks/"+name+"_cell.tif");
	rename("Cell");
	setOption("BlackBackground", true);
	setThreshold(255, 255);
	run("Convert to Mask");
	open(dir+"/Mito_Masks/"+name+"_mito.tif");
	rename("Mito");
	setOption("BlackBackground", true);
	setThreshold(255, 255);
	run("Convert to Mask");
	open(dir+"/Myo_Masks/"+name+"_myo.tif");
	rename("Myo");
	setOption("BlackBackground", true);
	setThreshold(255, 255);
	run("Convert to Mask");
	open(dir+"/Nucleus_Masks/"+name+"_nucleus.tif");
	rename("Nucleus");
	setOption("BlackBackground", true);
	setThreshold(255, 255);
	run("Convert to Mask");
// start analysis nucleus
selectWindow("Nucleus");
run("Analyze Particles...", "display add");
n=roiManager("count");
if (n>1) {
run("Summarize");
Circ=getResult("Circ.", n);
AR=getResult("AR", n);
Round=getResult("Round", n);
Solidity=getResult("Solidity", n);
}
else {
Area=(getResult("Area", 0)*ASF);
Circ=getResult("Circ.", 0);
AR=getResult("AR", 0);
Round=getResult("Round", 0);
Solidity=getResult("Circ.", 0);
}
XM= newArray();
YM= newArray();
for (i = 0; i < n; i++) {
	XM[i]=(getResult("XM", i));
	YM[i]=(getResult("YM", i));
}
roiManager("reset");
WNT=0; //Nucleus Total Width 
LNT=0; //Nucleus Total Lenght
WI=newArray();
LI=newArray();
selectWindow("Nucleus");
for (z = 0; z < n; z++) {
	roiManager("reset");
	CP1 = XM[z];
	CP2 = YM[z];
		for (i = 0; i < 23; i++) {
		a=(tan(Math.toRadians(2*i))*CP2);
		makeLine(CP1, CP2, (CP1+a), 0);
		roiManager("Add");
	}
		for (i = 0; i < 23; i++) {
		a=(tan(Math.toRadians(2*(22-i)))*(W-CP1));
		makeLine(CP1, CP2, W, (CP2-a));
		roiManager("Add");
	}
		for (i = 1; i < 23; i++) {
		a=(tan(Math.toRadians(2*i))*(W-CP1));
		makeLine(CP1, CP2, W, (CP2+a));
		roiManager("Add");
	}
		for (i = 1; i < 23; i++) {
		a=(tan(Math.toRadians(2*(23-i)))*(H-CP2));
		makeLine(CP1, CP2, CP1+a, H);
		roiManager("Add");
	}
		for (i = 0; i < 23; i++) {
		a=(tan(Math.toRadians(2*i))*(H-CP2));
		makeLine(CP1, CP2, CP1-a, H);
		roiManager("Add");
	}
		for (i = 0; i < 23; i++) {
		a=(tan(Math.toRadians(2*(22-i)))*CP1);
		makeLine(CP1, CP2, 0, (CP2+a));
		roiManager("Add");
	}
		for (i = 1; i < 23; i++) {
		a=(tan(Math.toRadians(2*i))*CP1);
		makeLine(CP1, CP2, 0, (CP2-a));
		roiManager("Add");
	}
		for (i = 1; i < 23; i++) {
		a=(tan(Math.toRadians(2*(23-i)))*CP2);
		makeLine(CP1, CP2, (CP1-a), 0);
		roiManager("Add");
	}
NL= newArray();//Nuclear Length
for (x = 0; x < 180; x++) {
	roiManager("Select", x);
	wait(10);
	yc= getProfile();
	nc= yc.length;// in pixel
	vx= 0;
	V= newArray();
	for (i = 0; i< nc; i++) {
			if (yc[i] <= 125) {
			V[vx]=i;
			vx++;
			}
		}
	Array.getStatistics(V, Vmin, Vmax, Vmean, VstdDev);
	NL[x]= (Vmin);
}
LN= 0; //Lenght Nucleus
WN= (H*W); //Width Nucleus
for (i = 0; i < 90; i++) {
	Lia= (NL[i]+NL[i+90]);
	if (Lia > LN) {
	LN = Lia;
	LI[z]=i;//Length Index 
	}	
	if (Lia < WN) {
	WN = Lia;
	WI[z]=i;//Width Index 
	}
}
LNT=(LNT+LN);
WNT=(WNT+WN);
}
LNT= ((LNT/(n))*pixelWidth);
WNT= ((WNT/(n))*pixelWidth);
if (ts==true) {
print(LNT, WNT ,Area ,Circ ,AR ,Round ,Solidity);
}
// Nuclear positioning 
CW=newArray();
for (w = 0; w < n; w++) {
	roiManager("reset");
	selectWindow("Cell");
	imageCalculator("Subtract create", "Cell","Nucleus");
	selectImage("Result of Cell");
	CP1 = XM[w];
	CP2 = YM[w];
		for (i = 0; i < 23; i++) {
		a=(tan(Math.toRadians(2*i))*CP2);
		makeLine(CP1, CP2, (CP1+a), 0);
		roiManager("Add");
	}
		for (i = 0; i < 23; i++) {
		a=(tan(Math.toRadians(2*(22-i)))*(W-CP1));
		makeLine(CP1, CP2, W, (CP2-a));
		roiManager("Add");
	}
		for (i = 1; i < 23; i++) {
		a=(tan(Math.toRadians(2*i))*(W-CP1));
		makeLine(CP1, CP2, W, (CP2+a));
		roiManager("Add");
	}
		for (i = 1; i < 23; i++) {
		a=(tan(Math.toRadians(2*(23-i)))*(H-CP2));
		makeLine(CP1, CP2, CP1+a, H);
		roiManager("Add");
	}
		for (i = 0; i < 23; i++) {
		a=(tan(Math.toRadians(2*i))*(H-CP2));
		makeLine(CP1, CP2, CP1-a, H);
		roiManager("Add");
	}
		for (i = 0; i < 23; i++) {
		a=(tan(Math.toRadians(2*(22-i)))*CP1);
		makeLine(CP1, CP2, 0, (CP2+a));
		roiManager("Add");
	}
		for (i = 1; i < 23; i++) {
		a=(tan(Math.toRadians(2*i))*CP1);
		makeLine(CP1, CP2, 0, (CP2-a));
		roiManager("Add");
	}
		for (i = 1; i < 23; i++) {
		a=(tan(Math.toRadians(2*(23-i)))*CP2);
		makeLine(CP1, CP2, (CP1-a), 0);
		roiManager("Add");
	}
selectImage("Result of Cell");
wait(500);
//Wall Distance
WD= newArray();
for (x = 0; x < 180; x++) {
	roiManager("Select", x);
	wait(10);
	yc= getProfile();
	nc= yc.length;// in pixel
	vx= 0;
	V= newArray();
	for (i = 0; i< nc; i++) {
			if (yc[i] >= 125) {
			V[vx]=i;
			vx++;
			}
		}
	Array.getStatistics(V, Vmin, Vmax, Vmean, VstdDev);
	WD[x]= (Vmax-Vmin);
}
Array.getStatistics(WD, WDmin, WDmax, WDmean, WDstdDev);
CW[w]= (WDmin*pixelWidth);
wait(500);
}
Array.getStatistics(CW, CWmin, CWmax, CWmean, CWstdDev);
if (ts==true) {
print(CWmin);
}
//segmenting mitochondria and mitochondria analysis 
roiManager("reset");
run("Clear Results");
selectWindow("Mito");
run("Analyze Particles...", "display add");
m=roiManager("count");
XMm= newArray();
YMm= newArray();
mA= newArray();
mC= newArray();
mAR= newArray();
mRO= newArray();
mSO= newArray();
for (i = 0; i < m; i++) {
	XMm[i]=(getResult("XM", i));
	YMm[i]=(getResult("YM", i));
	mA[i]=((getResult("Area", i)*ASF));
	mC[i]=(getResult("Circ.", i));
	mAR[i]=(getResult("AR", i));
	mRO[i]=(getResult("Round", i));
	mSO[i]=(getResult("Solidity", i));
}
roiManager("reset");
selectWindow("Mito");
WMT=newArray();//Mitochondrial Total Width 
LMT=newArray(); //Mitochondrial Total Lenght
mWI=newArray();
mLI=newArray();
selectWindow("Mito");
for (z = 0; z < m; z++) {
	roiManager("reset");
	CP1 = XMm[z];
	CP2 = YMm[z];
		for (i = 0; i < 23; i++) {
		a=(tan(Math.toRadians(2*i))*CP2);
		makeLine(CP1, CP2, (CP1+a), 0);
		roiManager("Add");
	}
		for (i = 0; i < 23; i++) {
		a=(tan(Math.toRadians(2*(22-i)))*(W-CP1));
		makeLine(CP1, CP2, W, (CP2-a));
		roiManager("Add");
	}
		for (i = 1; i < 23; i++) {
		a=(tan(Math.toRadians(2*i))*(W-CP1));
		makeLine(CP1, CP2, W, (CP2+a));
		roiManager("Add");
	}
		for (i = 1; i < 23; i++) {
		a=(tan(Math.toRadians(2*(23-i)))*(H-CP2));
		makeLine(CP1, CP2, CP1+a, H);
		roiManager("Add");
	}
		for (i = 0; i < 23; i++) {
		a=(tan(Math.toRadians(2*i))*(H-CP2));
		makeLine(CP1, CP2, CP1-a, H);
		roiManager("Add");
	}
		for (i = 0; i < 23; i++) {
		a=(tan(Math.toRadians(2*(22-i)))*CP1);
		makeLine(CP1, CP2, 0, (CP2+a));
		roiManager("Add");
	}
		for (i = 1; i < 23; i++) {
		a=(tan(Math.toRadians(2*i))*CP1);
		makeLine(CP1, CP2, 0, (CP2-a));
		roiManager("Add");
	}
		for (i = 1; i < 23; i++) {
		a=(tan(Math.toRadians(2*(23-i)))*CP2);
		makeLine(CP1, CP2, (CP1-a), 0);
		roiManager("Add");
	}
ML= newArray();//Mitochondrial Length
for (x = 0; x < 180; x++) {
	roiManager("Select", x);
	wait(10);
	yc= getProfile();
	nc= yc.length;// in pixel
	vx= 0;
	V= newArray();
	for (i = 0; i< nc; i++) {
			if (yc[i] <= 125) {
			V[vx]=i;
			vx++;
			}
		}
	Array.getStatistics(V, Vmin, Vmax, Vmean, VstdDev);
	ML[x]= (Vmin);
}
LM= 0; //Lenght Mitochondria
WM= (H*W); //Width Mitochondria
for (i = 0; i < 90; i++) {
	Lia= (ML[i]+ML[i+90]);
	if (Lia > LM) {
	LM = Lia;
	mLI[z]=i;//Length Index 
	}	
	if (Lia < WM) {
	WM = Lia;
	mWI[z]=i;//Width Index 
	}
}
LMT[z]=(LM*pixelWidth);
WMT[z]=(WM*pixelWidth);
}
if (ts==true) {
Array.print(LMT);
Array.print(WMT);
Array.print(mA);
Array.print(mC);
Array.print(mAR);
Array.print(mRO);
Array.print(mSO);
}
// sort mito into categories
roiManager("reset");
C=newArray();
iC=0;
I=newArray();
iI=0;
F=newArray();
iF=0;
CI=newArray();
iCI=0;
II=newArray();
iII=0;
FI=newArray();
iFI=0;

selectWindow("Myo");

for (z = 0; z < n; z++) { 
	CPn1 = XM[z];
	CPn2 = YM[z];
	
	for (i = 0; i < m; i++) {
		CPm1 = XMm[i];
		CPm2 = YMm[i];
		makeLine(CPn1, CPn2, CPm1, CPm2);
		roiManager("Add");
	}
	
	for (x = 0; x < m; x++) {
		roiManager("Select", x);
		wait(10);
		yc = getProfile();
		nc = yc.length;
		
		intersection = false;
		for (b = 0; b < nc; b++) {
			if (yc[b] >= 125) {
				intersection = true;
				break;
			}
		}
		
		if (nc <= LN) {
			if (!intersection) {
				C[iC] = x;
				iC++;
			} else {
				CI[iCI] = x;
				iCI++;
			}
		} else if (nc > LN && nc < 2.5 * LN) {
			if (!intersection) {
				I[iI] = x;
				iI++;
			} else {
				II[iII] = x;
				iII++;
			}
		} else { 
			if (!intersection) {
				F[iF] = x;
				iF++;
			} else {
				FI[iFI] = x;
				iFI++;
			}
		}
	}
}
if (ts==true) {
Array.print(C);
Array.print(I);
Array.print(F);
Array.print(CI);
Array.print(II);
Array.print(FI);
}
//sort mito output
function extractValues(srcArray, idxArray) {
    result = newArray(idxArray.length);
    for (i = 0; i < idxArray.length; i++) {
        result[i+1] = srcArray[idxArray[i]];
    }
    return result;
}
CLMT = extractValues(LMT, C);
CLMT[0]= "Length";
CWMT = extractValues(WMT, C);
CWMT[0] = "Width";
CmA  = extractValues(mA,  C);
CmA[0] = "Area";
CmC  = extractValues(mC,  C);
CmC[0] = "circularity";
CmAR = extractValues(mAR, C);
CmAR[0] = "Aspect Ratio";
CmRO = extractValues(mRO, C);
CmRO[0] = "Roundness";
CmSO = extractValues(mSO, C);
CmSO[0]= "Solidity";

CILMT = extractValues(LMT, CI);
CILMT[0]= "Length";
CIWMT = extractValues(WMT, CI);
CIWMT[0]= "Width";
CImA  = extractValues(mA,  CI);
CImA[0]= "Area";
CImC  = extractValues(mC,  CI);
CImC[0]= "circularity";
CImAR = extractValues(mAR, CI);
CImAR[0]= "Aspect Ratio";
CImRO = extractValues(mRO, CI);
CImRO[0]= "Roundness";
CImSO = extractValues(mSO, CI);
CImSO[0]= "Solidity";

ILMT = extractValues(LMT, I);
ILMT[0]="Length";
IWMT = extractValues(WMT, I);
IWMT[0]= "Width";
ImA  = extractValues(mA,  I);
ImA[0]= "Area";
ImC  = extractValues(mC,  I);
ImC[0]= "circularity";
ImAR = extractValues(mAR, I);
ImAR[0]= "Aspect Ratio";
ImRO = extractValues(mRO, I);
ImRO[0]= "Roundness";
ImSO = extractValues(mSO, I);
ImSO[0]= "Solidity";

IILMT = extractValues(LMT, II);
IILMT[0]="Length";
IIWMT = extractValues(WMT, II);
IIWMT[0]= "Width";
IImA  = extractValues(mA,  II);
IImA[0]= "Area";
IImC  = extractValues(mC,  II);
IImC[0]= "circularity";
IImAR = extractValues(mAR, II);
IImAR[0]= "Aspect Ratio";
IImRO = extractValues(mRO, II);
IImRO[0]= "Roundness";
IImSO = extractValues(mSO, II);
IImSO[0]= "Solidity";

FLMT = extractValues(LMT, F);
FLMT[0]="Length";
FWMT = extractValues(WMT, F);
FWMT[0]= "Width";
FmA  = extractValues(mA,  F);
FmA[0]= "Area";
FmC  = extractValues(mC,  F);
FmC[0]= "circularity";
FmAR = extractValues(mAR, F);
FmAR[0]= "Aspect Ratio";
FmRO = extractValues(mRO, F);
FmRO[0]= "Roundness";
FmSO = extractValues(mSO, F);
FmSO[0]= "Solidity";

FILMT = extractValues(LMT, FI);
FILMT[0]="Length";
FIWMT = extractValues(WMT, FI);
FIWMT[0]= "Width";
FImA  = extractValues(mA,  FI);
FImA[0]= "Area";
FImC  = extractValues(mC,  FI);
FImC[0]= "circularity";
FImAR = extractValues(mAR, FI);
FImAR[0]= "Aspect Ratio";
FImRO = extractValues(mRO, FI);
FImRO[0]= "Roundness";
FImSO = extractValues(mSO, FI);
FImSO[0]= "Solidity";

//grab last overfiew infos
run("Clear Results");
roiManager("reset");
selectImage("Mito");
run("Analyze Particles...", "summarize");
selectImage("Cell");
run("Convert to Mask");
run("Invert");
run("Analyze Particles...", "summarize");
selectImage("Myo");
run("Analyze Particles...", "summarize");
selectWindow("Summary"); 
lines = split(getInfo(), "\n"); 
tMiA = split(lines[1], "\t"); 
tCA = split(lines[2], "\t"); 
tMyA = split(lines[3], "\t"); 
if (ts==true) {
print(tMiA[2],tCA[2],tMyA[2]);
}
selectWindow("Summary"); 
run("Close");
// calculate mitochondrial nuclear contact coverage
selectImage("Nucleus");
run("Duplicate...", " ");
run("Erode");
imageCalculator("Subtract create", "Nucleus","Nucleus-1");
selectImage("Result of Nucleus");
run("Analyze Particles...", "summarize");
selectImage("Mito");
run("Duplicate...", " ");
selectImage("Mito-1");
for (i = 0; i < PSF; i++) {
	run("Dilate");
}
imageCalculator("Subtract", "Result of Nucleus","Mito-1");
run("Analyze Particles...", "summarize");
selectWindow("Summary"); 
lines = split(getInfo(), "\n"); 
tNO = split(lines[1], "\t"); 
pNO = split(lines[2], "\t"); 
selectWindow("Summary"); 
run("Close");
//generate output
print(tit);
print("Nucleus Length",",", "Width" ,",", "Area" ,",", "Circ" ,",", "AR" ,",", "Roundness" ,",", "Solidity",",", "Minimum Wall Distance",",", "Number of mitos",",","Nuclear Mito contact ratio");
print(LNT,",", WNT ,",", Area ,",", Circ ,",", AR ,",", Round ,",", Solidity,",", CWmin,",", m,",",(1-(pNO[2])/(tNO[2])));
print("Nuclear Area",",", "Mitochondrial Area" ,",", "Myofibril Area" ,",", "Cell Area",",","Unit");
print(Area,",", ((tMiA[2])*ASF) ,",", ((tMyA[2])*ASF),",", ((tCA[2])*ASF), ",",unit );
print("Close mitos");
Array.print(CLMT);
Array.print(CWMT);
Array.print(CmA);
Array.print(CmC);
Array.print(CmAR);
Array.print(CmRO);
Array.print(CmSO);
print("Close intersected mitos");
Array.print(CILMT);
Array.print(CIWMT);
Array.print(CImA);
Array.print(CImC);
Array.print(CImAR);
Array.print(CImRO);
Array.print(CImSO);
print("Intermediate mitos");
Array.print(ILMT);
Array.print(IWMT);
Array.print(ImA);
Array.print(ImC);
Array.print(ImAR);
Array.print(ImRO);
Array.print(ImSO);
print("Intermediate intersected mitos");
Array.print(IILMT);
Array.print(IIWMT);
Array.print(IImA);
Array.print(IImC);
Array.print(IImAR);
Array.print(IImRO);
Array.print(IImSO);
print("Far mitos");
Array.print(FLMT);
Array.print(FWMT);
Array.print(FmA);
Array.print(FmC);
Array.print(FmAR);
Array.print(FmRO);
Array.print(FmSO);
print("Far intersected mitos");
Array.print(FILMT);
Array.print(FIWMT);
Array.print(FImA);
Array.print(FImC);
Array.print(FImAR);
Array.print(FImRO);
Array.print(FImSO);
//gererating Colored Output 
selectImage("Mito");
run("Analyze Particles...", "add");
selectImage(tit);
roiManager("Set Line Width", 10);
function colorROIs(indices, color) {
    for (i = 0; i < indices.length; i++) {
        roiManager("select", indices[i]);
        Roi.setStrokeColor(color);
    }
}
colorROIs(C, "#0000FF");
colorROIs(CI, "#FF00FF");
colorROIs(I, "#FF0000");
colorROIs(II, "#FFA500");
colorROIs(F, "#FFFF00");
colorROIs(FI, "#FFFFFF");
run("Flatten");
roiManager("reset");
selectImage("Nucleus");
run("Analyze Particles...", "add");
selectImage(name+"-1.tif");
roiManager("Show None");
roiManager("Show All")
roiManager("Set Color", "cyan");
roiManager("Set Line Width", 10);
roiManager("show all");
roiManager("show all");
run("Flatten");
roiManager("reset");
selectImage("Myo");
run("Analyze Particles...", "add");
selectImage(name+"-2.tif");
roiManager("Show None");
roiManager("Show All")
roiManager("Set Color", "green");
roiManager("Set Line Width", 10);
roiManager("show all");
run("Flatten");
selectImage(name+"-3.tif");
saveAs("Tiff", dir+"/Results/Result_of_"+tit);
// cleanup
selectImage("Mito");
close;
selectImage("Mito-1");
close;
selectImage("Cell");
close;
selectImage("Myo");
close;
selectImage("Result of Cell");
close;
selectImage("Nucleus");
close;
selectImage("Nucleus-1");
close;
selectImage("Result of Nucleus");
close;
selectImage(tit);
close;
selectImage(name+"-1.tif");
close;
selectImage(name+"-2.tif");
close;
selectImage("Result_of_"+tit);
close;
}
selectWindow("Log");
saveAs("Text", dir+"/Results/Result.txt");
run("Close", "Log");
