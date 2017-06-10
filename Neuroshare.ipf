#pragma rtGlobals=1		// Use modern global access method.
#pragma version = 1.0.0	
#pragma IgorVersion = 6.1	//Igor Pro 6.1 or later

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// This procedure (tNeuroshare) offers a GUI for importing any data in neuroshare format.
// Latest version is available at Github (https://github.com/yuichi-takeuchi/tNeuroshare).
//
// More information on neuroshare: neuroshare.org (http://neuroshare.sourceforge.net/index.shtml)
//
// Prerequisites:
//* Igor Pro 6.1 or later
//* Neuroshare.XOP (http://www.nips.ac.jp/huinfo/documents/neuroshare/index.html)
//* Neuroshare-compliant DLL (http://neuroshare.sourceforge.net/DLLLinks.shtml)
//* tUtility (https://github.com/yuichi-takeuchi/tUtility)
//* SetWindowExt.XOP (http://fermi.uchicago.edu/freeware/LoomisWood/SetWindowExt.shtml)
//
// Author:
// Yuichi Takeuchi PhD
// Department of Physiology, University of Szeged, Hungary
// Email: yuichi-takeuchi@umin.net
// 
// Lisence:
// MIT License
//
// Acknowledgments
// Dr. Takashi Kodama, Johns Hopkins University
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

Menu "tNeuroshare"
"-"
	SubMenu "Initialize"
		"tNeuroshare Initialize", nst_Main()
	End

	SubMenu "Main Control"
		"Display Main Control", nst_DisplayMainControl()
		".ipf",  DisplayProcedure/W= 'Neuroshare.ipf' "nst_MainControlPanel"
	End

	SubMenu "Neuroshare.ipf"
		"Display Procedure", DisplayProcedure/W= 'Neuroshare.ipf'
	End
	
"-"
	"Help", nst_HelpNote()
End

///////////////////////////////////////////////////////////////////
//Menu

Function nst_FolderCheck()
	If(DataFolderExists("root:Packages:Neuroshare"))
		else
			If(DataFolderExists("root:Packages"))
					NewDataFolder root:Packages:Neuroshare
				else
					NewDataFolder root:Packages
					NewDataFolder root:Packages:Neuroshare
			endif
	endif
End

Function nst_Main()
	nst_FolderCheck()
	nst_PrepWaves()
	nst_PrepGVs()	
	nst_MainControlPanel()
end

Function nst_PrepWaves()
	nst_FolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Neuroshare:
	SetDataFolder fldrSav0
end

Function nst_PrepGVs()
	nst_FolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Neuroshare:
		String/G NS_filepath_DisplayName
		
		Variable/G EntityID = 0, Index = 0, SourceID = 0
		Variable/G start_time = 0, time_length = 0, start_index, index_count
		Variable/G TimeForIndex = 0, IndexForTime = 0, FlagForGetIndexByTime = 0
		Variable/G SubIndex = 0
	SetDataFolder fldrSav0
end

Function nst_DisplayMainControl()
	If(WinType("tSortMainControlPanel") == 7)
		DoWindow/HIDE = ? $("nsControlPanel")
		If(V_flag == 1)
			DoWindow/HIDE = 1 $("nsControlPanel")
		else
			DoWindow/HIDE = 0/F $("nsControlPanel")
		endif
	else	
		nst_MainControlPanel()
	endif
End

Function  nst_HelpNote()
	
	NewNotebook/F=0
	String strhelp =""
	strhelp += "0. Initialize						(Menu -> Neuroshare -> Initialize -> NeuroshareInitialize)"+"\r"
	strhelp += "1. Get Fullpath of source file (eg. xxx.smr)"+"\r"
	strhelp += "2. Specify EntityID"+"\r"
	strhelp += "3. Get File Info					 	(File tab -> FileInfo button)"+"\r"
	strhelp += "4. Get Entity Info (eg. Analogue)		(Analogue tab -> AnaInfo button)"+"\r"
	strhelp += "5. Acquire Data	 (Full range)			(Analogue tab -> AnaDataFull)"+"\r"
	strhelp += "   Acquire Data (Specified Range)		(Specify Start time and Time length, then AnaDataR)"+"\r"
	strhelp += ""+"\r"
	Notebook $WinName(0, 16) selection={endOfFile, endOfFile}
	Notebook $WinName(0, 16) text = strhelp + "\r"
end

///////////////////////////////////////////////////////////////////
// Main Control Panel

Function nst_MainControlPanel()
	NewPanel /N=nsControlPanel/W=(600,5,1000,655)
	TabControl TabnsMain,pos={5,150},size={390,495},proc=nst_MainTabProc
	TabControl TabnsMain,tabLabel(0)="File",tabLabel(1)="Event"
	TabControl TabnsMain,tabLabel(2)="Analogue",tabLabel(3)="Segment"
	TabControl TabnsMain,tabLabel(4)="NeuralData", tabLabel(5)="Library"
	TabControl TabnsMain,value= 0

	Button Bt_ns_GetFilePath,pos={10,5},size={50,20},proc=nst_GetFilePath,title="GetPath"

	nst_FilePathTitleBox()
	SetVariable Setvar_ns_GetEntityInfo,pos={10,30},size={90,16},limits={0,inf,1},proc=nst_GetEntityInfo,title="EntityID",value= root:Packages:Neuroshare:EntityID
	SetVariable Setvar_Index,pos={10,50},size={90,16},limits={0,inf,1},title="Index",value= root:Packages:Neuroshare:Index
	ValDisplay Valdisp_NS_dwEntityType,pos={106,31},size={50,13},title="Type",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwEntityType"
	ValDisplay Valdisp_NS_dwItemCount,pos={160,31},size={125,13},title="Count",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwItemCount"
	nst_EntityIDTitleBox()
	
	SetVariable Setvar_IndexByTime,pos={10,70},size={100,16},proc=nst_GetIndexByTime,title="Time (s)",limits={0,inf,1},value= root:Packages:Neuroshare:TimeForIndex
	SetVariable Setvar_FlagForGetIndexByTime,pos={120,70},size={60,16},proc=nst_GetIndexByTime,title="Flag",limits={-1,1,1},value= root:Packages:Neuroshare:FlagForGetIndexByTime
	ValDisplay Valdisp_IndexByTime,pos={190,71},size={150,13},title="IndexByTime",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_IndexByTime"

	SetVariable Setvar_TimeByIndex,pos={10,90},size={100,16},title="IndexFT",limits={0,inf,1},value= root:Packages:Neuroshare:IndexForTime
	ValDisplay Valdisp_TimeByIndex,pos={190,91},size={150,13},proc=nst_GetTimeByIndex,title="TimeByIndex (s)",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_TimeByIndex"

//File (tab0)
	Button Bt_ns_GetFileInfo_tab0,pos={10,175},size={50,20},proc=nst_GetFileInfo,title="FileInfo"
	ValDisplay Valdisp_NS_dwEntityCount_tab0,pos={10,200},size={200,13},title="EntityCount",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwEntityCount"
	ValDisplay Valdisp_NS_dTimeStampRes_tab0,pos={10,215},size={200,13},title="TimeStampRes",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dTimeStampResolution"
	ValDisplay Valdisp_NS_dTimeSpan_tab0,pos={10,230},size={200,13},title="TimeSpan",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dTimeSpan"
	ValDisplay Valdisp_NS_dwTime_Year_tab0,pos={10,245},size={200,13},title="Year",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwTime_Year"
	ValDisplay Valdisp_NS_dwTime_Month_tab0,pos={10,260},size={200,13},title="Month",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwTime_Month"
	ValDisplay Valdisp_NS_dwReserved_tab0,pos={10,275},size={200,13},title="Reserved",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwReserved"
	ValDisplay Valdisp_NS_dwTime_Day_tab0,pos={10,290},size={200,13},title="Day",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwTime_Day"
	ValDisplay Valdisp_NS_dwTime_Hour_tab0,pos={10,305},size={200,13},title="Hour",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwTime_Hour"
	ValDisplay Valdisp_NS_dwTime_Min_tab0,pos={10,320},size={200,13},title="Min",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwTime_Min"
	ValDisplay Valdisp_NS_dwTime_Sec_tab0,pos={10,335},size={200,13},title="Sec",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwTime_Sec"	
	ValDisplay Valdisp_NS_dwTime_mSec_tab0,pos={10,350},size={200,13},title="mSec",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwTime_MilliSec"
	nst_FileInfoTitleBox()

//Event (tab1)
	Button Bt_ns_GetEventInfo_tab1,pos={10,175},size={60,20},proc=nst_GetEventInfo,title="EventInfo"
	Button Bt_ns_GetEventData_tab1,pos={70,175},size={60,20},proc=nst_GetEventData,title="EventData"
	ValDisplay Valdisp_NS_dwEventType_tab1,pos={10,200},size={200,13},title="EventType",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwEventType"
	ValDisplay Valdisp_NS_dwMinDataLength_tab1,pos={10,215},size={200,13},title="MinDataLength",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwMinDataLength"
	ValDisplay Valdisp_NS_dwMaxDataLength_tab1,pos={10,230},size={200,13},title="MaxDataLength",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwMaxDataLength"
	nst_EventInfoTitleBox()
	
//Analogue (tab2)
	Button Bt_ns_GetAnInfo_tab2,pos={10,175},size={50,20},proc=nst_GetAnalogueInfo,title="AnaInfo"
	Button Bt_ns_GetAnDataFull_tab2,pos={60,175},size={80,20},proc=nst_GetAnalogueData,title="AnaDataFull"
	Button Bt_ns_GetAnDataFullA_tab2,pos={140,175},size={90,20},proc=nst_GetAnalogueDataFAll,title="AnaDataFALL"
	Button Bt_ns_GetAnDataRange_tab2,pos={230,175},size={70,20},proc=nst_GetAnalogueData,title="AnaDataR"
	Button Bt_ns_GetAnDataRangeA_tab2,pos={300,175},size={90,20},proc=nst_GetAnalogueDataRALL,title="AnaDataRALL"
	ValDisplay Valdisp_NS_dSampleRate_tab2,pos={10,200},size={200,13},title="Sample Hz",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dSampleRate"
	ValDisplay Valdisp_NS_dMinVal_tab2,pos={10,215},size={200,13},title="MinVal",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dMinVal"
	ValDisplay Valdisp_NS_dMaxVal_tab2,pos={10,230},size={200,13},title="MaxVal",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dMaxVal"
	ValDisplay Valdisp_NS_dResolution_tab2,pos={10,245},size={200,13},title="Resolution",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dResolution"
	ValDisplay Valdisp_NS_dLocationX_tab2,pos={10,260},size={200,13},title="LocationX",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dLocationX"
	ValDisplay Valdisp_NS_dLocationY_tab2,pos={10,275},size={200,13},title="LocationY",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dLocationY"
	ValDisplay Valdisp_NS_dLocationZ_tab2,pos={10,290},size={200,13},title="LocationZ",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dLocationZ"
	ValDisplay Valdisp_NS_dLocationUser_tab2,pos={10,305},size={200,13},title="LocationUser",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dLocationUser"
	ValDisplay Valdisp_NS_dHighFreqCorner_tab2,pos={10,320},size={200,13},title="HighFreqCor",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dHighFreqCorner"
	ValDisplay Valdisp_NS_dwHighFreqOrder_tab2,pos={10,335},size={200,13},title="HighFreqOrder",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwHighFreqOrder"	
	ValDisplay Valdisp_NS_dLowFreqCorner_tab2,pos={10,350},size={200,13},title="LowFreqCorner",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dLowFreqCorner"
	ValDisplay Valdisp_NS_dwLowFreqOrder_tab2,pos={10,365},size={200,13},title="LowFreqOrder",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwLowFreqOrder"
	nst_AnalogueInfoTitleBox()
	
	SetVariable Setvar_start_time_tab2,pos={225,200},size={150,16},title="Start_time (s)",value= root:Packages:Neuroshare:start_time
	SetVariable Setvar_time_length_tab2,pos={225,220},size={150,16},title="Time_length (s)",value= root:Packages:Neuroshare:time_length
	SetVariable Setvar_subindex_tab2,pos={225,240},size={150,16},title="SubIndex",limits={0,inf,1},value= root:Packages:Neuroshare:SubIndex
	ValDisplay Valdisp_NS_dwContCount_tab2,pos={225,260},size={150,13},title="ContCount",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwContCount"

//Segment (tab3)
	Button Bt_ns_GetSegInfo_tab3,pos={10,175},size={70,20},proc=nst_GetSegmentInfo,title="SegInfo"
	ValDisplay Valdisp_NS_dwSourceCnt_tab3,pos={10,200},size={200,13},title="SourceCount",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwSourceCount"
	ValDisplay Valdisp_NS_dwMinSampleCnt_tab3,pos={10,215},size={200,13},title="MinSampleCount",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwMinSampleCount"
	ValDisplay Valdisp_NS_dwMaxSampleCnt_tab3,pos={10,230},size={200,13},title="MaxSmapleCount",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwMaxSampleCount"
	ValDisplay Valdisp_NS_dSampleRate_tab3,pos={10,245},size={200,13},title="SampleRate",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dSampleRate"
	nst_SegmentInfoTitleBox()
	
	Button Bt_ns_GetSegSourceInfo_tab3,pos={80,175},size={90,20},proc=nst_GetSegSourceInfo,title="SegSrcInfo"
	ValDisplay Valdisp_NS_dSubSampleShift_tab3,pos={10,285},size={200,13},title="SubSampleShift",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dSubSampleShift"
	ValDisplay Valdisp_NS_dMinVal_tab3,pos={10,300},size={200,13},title="MinVal",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dMinVal"
	ValDisplay Valdisp_NS_dMaxVal_tab3,pos={10,315},size={200,13},title="MaxVal",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dMaxVal"
	ValDisplay Valdisp_NS_dResolution_tab3,pos={10,330},size={200,13},title="Resolution",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dResolution"
	ValDisplay Valdisp_NS_dLocationX_tab3,pos={10,345},size={200,13},title="LocationX",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dLocationX"
	ValDisplay Valdisp_NS_dLocationY_tab3,pos={10,360},size={200,13},title="LocationY",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dLocationY"
	ValDisplay Valdisp_NS_dLocationZ_tab3,pos={10,375},size={200,13},title="LocationZ",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dLocationZ"
	ValDisplay Valdisp_NS_dLocationUser_tab3,pos={10,390},size={200,13},title="LocationUser",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dLocationUser"
	ValDisplay Valdisp_NS_dHighFreqCorner_tab3,pos={10,405},size={200,13},title="HighFreqCor",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dHighFreqCorner"
	ValDisplay Valdisp_NS_dwHighFreqOrder_tab3,pos={10,420},size={200,13},title="HighFreqOrder",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwHighFreqOrder"	
	ValDisplay Valdisp_NS_dLowFreqCorner_tab3,pos={10,435},size={200,13},title="LowFreqCorner",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dLowFreqCorner"
	ValDisplay Valdisp_NS_dwLowFreqOrder_tab3,pos={10,450},size={200,13},title="LowFreqOrder",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwLowFreqOrder"
	nst_SegSourceInfoTitleBox()

	Button Bt_ns_GetSegData_tab3,pos={170,175},size={90,20},proc=nst_GetSegmentData,title="SegData"
	ValDisplay Valdisp_NS_UnitID_tab3,pos={225,200},size={150,13},title="UnitID",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_UnitID"
	ValDisplay Valdisp_NS_SegSampleCount_tab3,pos={225,220},size={150,13},title="SegSampleCount",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_SegSampleCount"

//NeuralInfo (tab4)
	Button Bt_ns_GetNeuralInfo_tab4,pos={10,175},size={70,20},proc=nst_GetNeuralInfo,title="NeuralInfo"
	Button Bt_ns_GetNeuralData_tab4,pos={80,175},size={90,20},proc=nst_GetNeuralData,title="NeuralData"
	ValDisplay Valdisp_NS_dwSrcEntityID_tab4,pos={10,200},size={200,13},title="SrcEntityID",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwSourceEntityID"
	ValDisplay Valdisp_NS_dwSrcUnitID_tab4,pos={10,215},size={200,13},title="SrcUnitID",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwSourceUnitID"
	nst_NeuralInfoTitleBox()

	SetVariable Setvar_start_index_tab4,pos={225,200},size={150,16},title="Start_index",value= root:Packages:Neuroshare:start_index
	SetVariable Setvar_index_count_tab4,pos={225,220},size={150,16},title="Index_count",value= root:Packages:Neuroshare:index_count
//Library (tab5)
	Button Bt_ns_GetLibraryInfo_tab5,pos={10,175},size={50,20},proc=nst_GetLibraryInfo,title="LibInfo"
	ValDisplay Valdisp_NS_dwLibVersionMaj_tab5,pos={10,200},size={100,13},title="LibVerMaj",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwLibVersionMaj"
	ValDisplay Valdisp_NS_dwLibVersionMin_tab5,pos={10,215},size={100,13},title="LibVerMin",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwLibVersionMin"
	ValDisplay Valdisp_NS_dwAPIVersionMaj_tab5,pos={10,230},size={100,13},title="APIVerMaj",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwAPIVersionMaj"
	ValDisplay Valdisp_NS_dwAPIVersionMin_tab5,pos={10,245},size={100,13},title="APIVerMin",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwAPIVersionMin"
	ValDisplay Valdisp_NS_dwTime_Year_tab5,pos={10,260},size={100,13},title="Year",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwTime_Year"
	ValDisplay Valdisp_NS_dwTime_Month_tab5,pos={10,275},size={100,13},title="Month",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwTime_Month"
	ValDisplay Valdisp_NS_dwTime_Day_tab5,pos={10,290},size={100,13},title="Day",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwTime_Day"
	ValDisplay Valdisp_NS_dwFlags_tab5,pos={10,305},size={100,13},title="Flags",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwFlags"
	ValDisplay Valdisp_NS_dwMaxFiles_tab5,pos={10,320},size={100,13},title="MaxFiles",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwMaxFiles"
	ValDisplay Valdisp_NS_dwFileDescCount_tab5,pos={10,345},size={100,13},title="FileDescCount",limits={0,0,0},barmisc={0,1000},value= #"root:Packages:Neuroshare:NS_dwFileDescCount"
	nst_LibraryTitleBox()
	
//

	String controlsInATab= ControlNameList("nsControlPanel",";","*_tab*")
	String curTabMatch="*_tab0"
	String controlsInCurTab= ListMatch(controlsInATab, curTabMatch)
	String controlsInOtherTab= ListMatch(controlsInATab, "!"+curTabMatch)
	ModifyControlList controlsInCurTab disable = 0 //show
	ModifyControlList controlsInOtherTab disable = 1 //hide
end

Function nst_FilePathTitleBox()
	TitleBox Title_NS_filepath,pos={65,6},variable= root:Packages:Neuroshare:NS_filepath_DisplayName
End

Function nst_EntityIDTitleBox()
	TitleBox Title_NS_szEntityLabel,pos={293,28},variable= root:Packages:Neuroshare:NS_szEntityLabel
end

Function nst_FileInfoTitleBox()
	TitleBox Title_NS_szFileType_tab0,pos={10,365},variable= root:Packages:Neuroshare:NS_szFileType
	TitleBox Title_NS_szAppName_tab0,pos={10,385},variable= root:Packages:Neuroshare:NS_szAppName
	TitleBox Title_NS_szFileCom_tab0,pos={10,405},variable= root:Packages:Neuroshare:NS_szFileComment
end

Function nst_EventInfoTitleBox()
	TitleBox Title_NS_szCSVDesc_tab1,pos={10,245},variable= root:Packages:Neuroshare:NS_szCSVDesc
end

Function nst_AnalogueInfoTitleBox()
	TitleBox Title_NS_szUnits_tab2,pos={10,390},variable= root:Packages:Neuroshare:NS_szUnits
	TitleBox Title_NS_szHighFilterType_tab2,pos={10,410},variable= root:Packages:Neuroshare:NS_szHighFilterType
	TitleBox Title_NS_szLowFilterType_tab2,pos={10,430},variable= root:Packages:Neuroshare:NS_szLOwFilterType
	TitleBox Title_NS_szProbeInfo_tab2,pos={10,450},variable= root:Packages:Neuroshare:NS_szProbeInfo
End

Function nst_SegmentInfoTitleBox()
	TitleBox Title_NS_szUnits_tab3,pos={10,265},variable= root:Packages:Neuroshare:NS_szUnits
end

Function nst_SegSourceInfoTitleBox()
	TitleBox Title_NS_szHighFilterType_tab3,pos={10,465},variable= root:Packages:Neuroshare:NS_szHighFilterType
	TitleBox Title_NS_szLowFilterType_tab3,pos={10,485},variable= root:Packages:Neuroshare:NS_szLOwFilterType
	TitleBox Title_NS_szProbeInfo_tab3,pos={10,505},variable= root:Packages:Neuroshare:NS_szProbeInfo
End

Function nst_NeuralInfoTitleBox()
	TitleBox Title_NS_szProbeInfo_tab4,pos={10,235},variable= root:Packages:Neuroshare:NS_szProbeInfo
End

Function nst_LibraryTitleBox()
	TitleBox Title_NS_szDescription_tab5,pos={10,365},variable= root:Packages:Neuroshare:NS_szDescription
	TitleBox Title_NS_szCreator_tab5,pos={10,385},variable= root:Packages:Neuroshare:NS_szCreator
	TitleBox Title_NS_FileDesc_szDesc_tab5,pos={10,405},variable= root:Packages:Neuroshare:NS_FileDesc_szDescription
	TitleBox Title_NS_FileDesc_szExt_tab5,pos={10,425},variable= root:Packages:Neuroshare:NS_FileDesc_szExtension
	TitleBox Title_NS_FileDesc_szMac_tab5,pos={10,445},variable= root:Packages:Neuroshare:NS_FileDesc_szMacCodes
	TitleBox Title_NS_FileDesc_szMagic_tab5,pos={10,465},variable= root:Packages:Neuroshare:NS_FileDesc_szMagicCodes
end

Function nst_MainTabProc(ctrlName,tabNum) : TabControl
	String ctrlName
	Variable tabNum
	String controlsInATab= ControlNameList("nsControlPanel",";","*_tab*")
	String curTabMatch="*_tab*"+Num2str(tabNum)
	String controlsInCurTab= ListMatch(controlsInATab, curTabMatch)
	String controlsInOtherTab= ListMatch(controlsInATab, "!"+curTabMatch)
	ModifyControlList controlsInCurTab disable = 0 //show
	ModifyControlList controlsInOtherTab disable = 1 //hide
	return 0
End

Function nst_GetFilePath(ctrlName) : ButtonControl
	String ctrlName
	
	nst_FolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Neuroshare:
	
	ns_GetFilePath
	nst_NS_filepath_displayname()
	nst_FilePathTitleBox()
	
	SetDataFolder fldrSav0
End

Function nst_NS_filepath_displayname()
	SVAR NS_filepath = root:Packages:Neuroshare:NS_filepath
	String strsrc
	strsrc = NS_filepath
	strsrc = ReplaceString("\\", strsrc, "\\\\")
	
	nst_FolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Neuroshare:
		String/G NS_filepath_DisplayName
		NS_filepath_DisplayName = strsrc
	SetDataFolder fldrSav0
end

Function nst_GetEntityInfo(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName
	
	nst_FolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Neuroshare:
	
	SVAR NS_filepath = root:Packages:Neuroshare:NS_filepath
	ns_GetEntityInfo/E=(varNum) NS_filepath
	
	nst_EntityIDTitleBox()
	SetDataFolder fldrSav0
	
End

Function nst_GetIndexByTime(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	SVAR Filepath = root:Packages:Neuroshare:NS_filepath
	NVAR EntityID = root:Packages:Neuroshare:EntityID
	NVAR Flag = root:Packages:Neuroshare:FlagForGetIndexByTime
	NVAR TimeForIndex = root:Packages:Neuroshare:TimeForIndex

	nst_FolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Neuroshare:

	ns_GetIndexByTime/E = (EntityID)/F = (Flag)/T = (TimeForIndex) Filepath
	
	SetDataFolder fldrSav0
End

Function nst_GetTimeByIndex(ctrlName,varNum,varStr,varName) : SetVariableControl
	String ctrlName
	Variable varNum
	String varStr
	String varName

	SVAR Filepath = root:Packages:Neuroshare:NS_filepath
	NVAR EntityID = root:Packages:Neuroshare:EntityID

	nst_FolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Neuroshare:
	
	ns_GetTimeByIndex/E = (EntityID)/I = (varNum)/Q Filepath
	
	SetDataFolder fldrSav0
End

//////////////////////////////////////////////////////
//File (tab0)

Function nst_GetFileInfo(ctrlName) : ButtonControl
	String ctrlName
	
	nst_FolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Neuroshare:
	
	SVAR NS_filepath = root:Packages:Neuroshare:NS_filepath
	ns_GetFileInfo NS_filepath
	
	nst_FileInfoTitleBox()
	
	SetDataFolder fldrSav0
End

//////////////////////////////////////////////////////
//Event (tab1)

Function nst_GetEventInfo(ctrlName) : ButtonControl
	String ctrlName
	
	nst_FolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Neuroshare:
	
	SVAR NS_filepath = root:Packages:Neuroshare:NS_filepath
	NVAR EntityID = root:Packages:Neuroshare:EntityID
	
	ns_GetEventInfo/E=(EntityID) NS_filepath
	nst_EventInfoTitleBox()
	
	SetDataFolder fldrSav0
End

Function nst_GetEventData(ctrlName) : ButtonControl
	String ctrlName

	nst_FolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Neuroshare:

	SVAR NS_filepath = root:Packages:Neuroshare:NS_filepath
	NVAR EntityID = root:Packages:Neuroshare:EntityID
	
	ns_GetEventData/E=(EntityID) NS_filepath
	nst_WaveSave(1, 0)

	SetDataFolder fldrSav0
End

//////////////////////////////////////////////////////
//Analogue (tab2)

Function nst_GetAnalogueInfo(ctrlName) : ButtonControl
	String ctrlName
	
	nst_FolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Neuroshare:
	
	SVAR NS_filepath = root:Packages:Neuroshare:NS_filepath
	NVAR EntityID = root:Packages:Neuroshare:EntityID
	
	ns_GetAnalogInfo/E=(EntityID) NS_filepath
	nst_AnalogueInfoTitleBox()
	
	SetDataFolder fldrSav0
End

Function nst_GetAnalogueData(ctrlName) : ButtonControl
	String ctrlName
	
	nst_FolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Neuroshare:
	
	SVAR NS_filepath = root:Packages:Neuroshare:NS_filepath
	NVAR EntityID = root:Packages:Neuroshare:EntityID
	
	StrSwitch(ctrlName)
		case "Bt_ns_GetAnDataFull_tab2":
			ns_GetAnalogData/E=(EntityID) NS_filepath
			If(WaveExists(NS_AnalogData))
				nst_WaveSave(2, 0)
			endif
			break
		case "Bt_ns_GetAnDataRange_tab2":
			NVAR start_time = root:Packages:Neuroshare:start_time
			NVAR time_length = root:Packages:Neuroshare:time_length
			ns_GetAnalogData/E=(EntityID)/R={start_time, time_length} NS_filepath
			If(WaveExists(NS_AnalogData))
				nst_WaveSave(2, 1)
			endif
			break
		default:
			break
	endSwitch	
		
	SetDataFolder fldrSav0
End

Function nst_GetAnalogueDataFAll(ctrlName) : ButtonControl
	String ctrlName

	NVAR EntityID = root:Packages:Neuroshare:EntityID

	Variable i = 0
	
	for(i = 0; i < 5; i += 1)	// Initialize variables;continue test
		EntityID = i
		nst_GetEntityInfo("",i,"","")
		nst_GetAnalogueData("Bt_ns_GetAnDataFull_tab2")
	endfor
	nst_GetEntityInfo("",0,"","")
End

Function nst_GetAnalogueDataRALL(ctrlName) : ButtonControl
	String ctrlName

	NVAR EntityID = root:Packages:Neuroshare:EntityID

	Variable i = 0
	
	for(i = 0; i < 5; i += 1)	// Initialize variables;continue test
		EntityID = i
		nst_GetEntityInfo("",i,"","")
		nst_GetAnalogueData("Bt_ns_GetAnDataRange_tab2")
	endfor
	nst_GetEntityInfo("",0,"","")
End

//////////////////////////////////////////////////////
//Segment (tab3)

Function nst_GetSegmentInfo(ctrlName) : ButtonControl
	String ctrlName
	
	nst_FolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Neuroshare:
	
	SVAR NS_filepath = root:Packages:Neuroshare:NS_filepath
	NVAR EntityID = root:Packages:Neuroshare:EntityID
	
	ns_GetSegmentInfo/E=(EntityID) NS_filepath
	nst_SegmentInfoTitleBox()
	
	SetDataFolder fldrSav0
End

Function nst_GetSegSourceInfo(ctrlName) : ButtonControl
	String ctrlName
	
	nst_FolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Neuroshare:
	
	SVAR NS_filepath = root:Packages:Neuroshare:NS_filepath
	NVAR EntityID = root:Packages:Neuroshare:EntityID
	NVAR SourceID = root:Packages:Neuroshare:SourceID
	
	ns_GetSegmentSourceInfo/E=(EntityID)/S=(SourceID) NS_filepath
	nst_SegSourceInfoTitleBox()
	
	SetDataFolder fldrSav0
End

Function nst_GetSegmentData(ctrlName) : ButtonControl
	String ctrlName
	
	nst_FolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Neuroshare:
	
	SVAR NS_filepath = root:Packages:Neuroshare:NS_filepath
	NVAR EntityID = root:Packages:Neuroshare:EntityID
	NVAR Index = root:Packages:Neuroshare:Index
	
	ns_GetSegmentData/E=(EntityID)/I=(Index) NS_filepath
	nst_WaveSave(3, 0)
	
	SetDataFolder fldrSav0
End

//////////////////////////////////////////////////////
//Neural Data (tab4)

Function nst_GetNeuralInfo(ctrlName) : ButtonControl
	String ctrlName
	
	nst_FolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Neuroshare:
	
	SVAR NS_filepath = root:Packages:Neuroshare:NS_filepath
	NVAR EntityID = root:Packages:Neuroshare:EntityID
	
	ns_GetNeuralInfo/E=(EntityID) NS_filepath
	nst_NeuralInfoTitleBox()
	
	SetDataFolder fldrSav0
End

Function nst_GetNeuralData(ctrlName) : ButtonControl
	String ctrlName

	nst_FolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Neuroshare:

	SVAR NS_filepath = root:Packages:Neuroshare:NS_filepath
	NVAR EntityID = root:Packages:Neuroshare:EntityID
	NVAR start_index = root:Packages:Neuroshare:start_index
	NVAR index_count = root:Packages:Neuroshare:index_count
	
	ns_GetNeuralData/E=(EntityID)/R={start_index, index_count} NS_filepath
	nst_WaveSave(4, 0)
	
	SetDataFolder fldrSav0
End

/////////////////////////////////////////////////////////////////
//Library (tab5)

Function nst_GetLibraryInfo(ctrlName) : ButtonControl
	String ctrlName
	
	nst_FolderCheck()
	String fldrSav0= GetDataFolder(1)
	SetDataFolder root:Packages:Neuroshare:
	
	ns_GetLibraryInfo
	
	nst_LibraryTitleBox()

	SetDataFolder fldrSav0
End

///////////////////////////////////////////////////////////////////////////////////////////////////////////

Function nst_WaveSave(EntityType, VarSubIndex)
	Variable EntityType, VarSubIndex
	
	NVAR EntityID = root:Packages:Neuroshare:EntityID
	NVAR Index = root:Packages:Neuroshare:Index
	
	Switch(EntityType)
		case 0:
			break
		case 1:
			Wave NS_EventTime, NS_EventData
			Duplicate/O NS_EventTime, $("root:w_" + Num2str(EntityType) + "_" + Num2str(EntityID) + "_0")
			Duplicate/O NS_EventData, $("root:w_" + Num2str(EntityType) + "_" + Num2str(EntityID) + "_1")
			break
		case 2:
			Wave NS_AnalogData
			Duplicate/O NS_AnalogData, $("root:" +  nst_AnalogueDataName(VarSubIndex))
//			Duplicate/O NS_AnalogData, $("root:w_" + Num2str(EntityType) + "_" + Num2str(EntityID) + "_" + Num2str(Index))
			break
		case 3:
			Wave NS_SegmentData
			Duplicate/O NS_SegmentData, $("root:w_" + Num2str(EntityType) + "_" + Num2str(EntityID) + "_" + Num2str(Index))
			break
		case 4:
			Wave NS_NeuralData
			Duplicate/O NS_NeuralData, $("root:w_" + Num2str(EntityType) + "_" + Num2str(EntityID) + "_" + Num2str(Index))
			break
		default:
			break
	endSwitch
End

Function/S nst_AnalogueDataName(VarSubIndex)
	Variable VarSubIndex
	
	SVAR NS_filepath = root:Packages:Neuroshare:NS_filepath
	SVAR NS_szEntityLabel = root:Packages:Neuroshare:NS_szEntityLabel
	
	String strsrc, strdest
	strsrc = NS_filepath
	strsrc = ReplaceString("\\", strsrc, " ")
	strdest =  strsrc[strsearch(strsrc, " ", Inf, 1) + 1, strlen(strsrc) - 5]
	If(VarSubIndex == 0)
		strdest = "w_" + strdest +"_"+ NS_szEntityLabel
	else
		NVAR SubIndex = root:Packages:Neuroshare:SubIndex
		strdest = "w_" + strdest + "_"+ Num2str(SubIndex) +"_"+ NS_szEntityLabel 
	endIf
	
	return strdest
end