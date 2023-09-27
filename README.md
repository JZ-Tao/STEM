# A demo for STEM (Shearlet Transform based Entropy Matching)

### Pan-sharpening Framework Based on Multi-scale Entropy Level Matching and Its Application (TGRS, 2022).

### Code Usage Notes
1) This sample program contains three pan-sharpening methods STEM-MS, STEM-MA and ST-Naive.
2) Please add all the directories to the path of Matlab.
3) The main program is the "STEM_demo.m" file in the root directory.
4) This program is tested on Windows 10 and Matlab R2019b/R2021a.
5) The data and some third-party tools or functions contained in the code package should be copyrighted to the corresponding authors and organizations.
6) If you want to run the STEM code with other data, refer to the flow in the STEM_demo.m file and call the *generateDefaultSensorInf* function as needed.
7) If this code is helpful to your work, please cite our paper: https://doi.org/10.1109/TGRS.2022.3198097
8) For questions, please contact: blueuranus@qq.com.

### An additional toy experiment not mentioned in our paper
![](toy_experiment.png)
The first two of these images are the source images with different contents (letters) due to spectral differences. The other images are the results of processing by different sharpening methods. It can be seen that only STEM achieves the sharpening of the "X" without showing the extra "B". 
