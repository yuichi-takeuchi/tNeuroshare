# tNeuroshare
Igor Pro GUI for importing any neurophysiology data in neuroshare format.

## Getting Started

### Prerequisites
* Igor Pro 6 (https://www.wavemetrics.com/)
* Neuroshare.XOP (http://www.nips.ac.jp/huinfo/documents/neuroshare/index.html)
* Neuroshare-compliant DLL (http://neuroshare.sourceforge.net/DLLLinks.shtml)
* tUtility (https://github.com/yuichi-takeuchi/tUtility)
* SetWindowExt.XOP (https://github.com/yuichi-takeuchi/SetWindowExt)

This code has been tested in Igor Pro version 6.3.7.2. for Windows and supposed to work in Igor Pro 6.1 or later.

### Installing
1. Install Igor Pro 6.1 or later.
2. Put Neuroshare.ipf and GlobalProcedure.ipf of tUtility or their shortcuts into the Igor Procedures folder, which is normally located at My Documents\WaveMetrics\Igor Pro 6 User Files\Igor Procedures.
3. Put Neuroshare.XOP and SetWindowExt.XOP or their shortcuts into the Igor Extensions folder, which is normally located at My Documents\WaveMetrics\Igor Pro 6 User Files\Igor Extensions.
4. Optional: SetWindowExt Help.ipf or its shortcut into the Igor Help Files folder, which is normally located at My Documents\WaveMetrics\Igor Pro 6 User Files\Igor Help Files.
5. Change the name of the DLL to 'Neuroshare.dll', and move it to 'C:\Windows' folder
6. Restart Igor Pro and "tNeuroshare" will appear in the menu.

### How to initialize the tNeuroshare GUI
* Click "tNeuroshare Initialize" in Initialize submenu of the tNeuroshare menu.
* Neuroshare control panel (nsControlPanel) will appear.

### How to use
1. Get full path to your source file (eg. xxx.smr for CED Spike2 data file) by clicking "GetPath" button on the control panel.
2. Specify the number of EntityID by "Entity" setvar control on the control panel.
3. Get file information by clicking "FileInfo" button on File tab of the control panel.
4. Get entity info by clicking "EventInfo", "AnaInfo", "SegInfo", or "NeuralInfo" buttons on Event, Analogue, Segment, or NeuralData tabs, respectively, depending on types of the source entity ID.
5. Load data from the specified entity by clicking "EventData", "AnaDataFull", "AnaDataFALL", "AnaDataR", "AnaDataRALL", "SegData", or "NeuralData" buttons, depending on types of the source entity ID.

#### Loading analog data
* AnaDataFull: Loading full range of the specified analog data entity.
* AnaDataFALL: Loading full range of the all analog data entities.
* AnaDataR: Loading a time window defined on Analogue tab of the specified analog data entity.
* AnaDataRALL: Loading a time window defined on Analogue tab of the all analog data entities.

### Help
* Click "Help" in the tNeuroshare menu.
* Neuroshare.XOP User Manual (http://www.nips.ac.jp/huinfo/documents/neuroshare/OperationUsageOfNeuroShareXOP.pdf)
* neuroshare.org (http://neuroshare.sourceforge.net/index.shtml)

## DOI
[![DOI](https://zenodo.org/badge/93948996.svg)](https://zenodo.org/badge/latestdoi/93948996)

## Versioning
We use [SemVer](http://semver.org/) for versioning.

## Releases
* Version 1.0.0, 2017/06/10

## Authors
* **Yuichi Takeuchi PhD** - *Initial work* - [GitHub](https://github.com/yuichi-takeuchi)

## License
This project is licensed under the MIT License.

## Acknowledgments
* Dr. Takashi Kodama, Johns Hopkins University for Neuroshare.XOP
* Department of Information Physiology, National Institute for Physiological Sciences, Okazaki, Japan
* Department of Physiology, Tokyo Women's Medical University, Tokyo, Japan

## References
tNeuroshare has been used for the following works:
- Takeuchi Y, Osaki H, Yagasaki Y, Katayama Y, Miyata M (2017) Afferent Fiber Remodeling in the Somatosensory Thalamus of Mice as a Neural Basis of Somatotopic Reorganization in the Brain and Ectopic Mechanical Hypersensitivity after Peripheral Sensory Nerve Injury. eNeuro 4: e0345-0316.
- Nagumo Y, Ueta Y, Nakayama H, Osaki H, Takeuchi Y, Uesaka N, Kano M, Miyata M (2020) Tonic GABAergic inhibition is essential for nerve injury-induced afferent remodeling in the somatosensory thalamus and associated ectopic sensations. Cell Rep 31: 107797.
