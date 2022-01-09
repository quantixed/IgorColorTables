# IgorColorTables

Expanding the use of color tables in IGOR Pro.

Igor ships with:

- a series of 61 in-built Color Tables: a list can be generated using `CTabList()`
- a further 243 additional Color Tables in `Igor Pro 9 Folder/Color Tables/`: full details are in `Color Table Waves.ihf`

In this repo, there is an Igor port of the ImageJ Update Site [NeuroCyto-LUTs](https://sites.imagej.net/NeuroCyto-LUTs/) created and maintained by [Christophe Leterrier](https://github.com/cleterrier) which makes a further **~400 Color Tables available**.

An abbreviated list of color tables:

	- EPFL - ametrine, isolum and morgenstemning
	- LANL - from Data Science at Scale
	- MatplotLib - approximations from scipy
	- Moreland - Moreland's maps including *smoothcoolwarm256*
	- SciColMaps - Crameri's maps including *batlow*
	- NeuroCyto-LUTs - useful for images but also includes Kovesi color maps

## Installation

Copy the `NeuroCytoLUTs` folder in `ibwfiles` to your `Igor Pro 9 User Files/User Color Tables` directory.
Create the `User Color Tables` if it does not exist.

Copy the `ColorTableProcs.ipf` to `Igor Pro 9 User Files/User Procedures` and run, or load into an existing experiment.

## Using ColorTableProcs

Additional color tables can be made available in your experiment using *Colors > More Color Tables*

Color Tables are loaded into `root:Packages:ColorTables:subfolder` where the subfolder is the family of color tables.

To display the Color Tables that have been loaded, chose *Colors > Display Color Tables*

## Examples

One page of examples of the additional Igor Color Tables as linear color scales

![img](img/allLinearCTs1.png?raw=true "image")

One page of examples of the NeuroCyto-LUTs Color Tables as linear color scales

![img](img/allLinearCTs2.png?raw=true "image")

One page of examples of the additional Igor Color Tables as 9 x 9 latin squares

![img](img/allLSCTs1.png?raw=true "image")

One page of examples of the NeuroCyto-LUTs Color Tables as 9 x 9 latin squares

![img](img/allLSCTs2.png?raw=true "image")

## Notes

To load even more LUTs as `.lut` `.csv` `.txt` or `.tsv` use *Colors > Load Color Tables*

A menu command allows easy save of these files following conversion, as `.ibw` files.

To generate readable files from ImageJ/Fiji, a script `lut2tsv.ijm` will export all luts from your ImageJ/Fiji installation as tab-separated values.

<details>
	<summary>After loading these additional LUTs and enabling the additional Igor Color Tables, there are some duplications</summary>

```
NeuroCytoLUTs:CET_C5  matches  NeuroCytoLUTs:C3_cyclic_grey_15_85_c0_n256
  NeuroCytoLUTs:CET_C5s  matches  NeuroCytoLUTs:C3_cyclic_grey_15_85_c0_n256_s25
  NeuroCytoLUTs:CET_C2  matches  NeuroCytoLUTs:C3_cyclic_mygbm_30_95_c78_n256
  NeuroCytoLUTs:CET_C2s  matches  NeuroCytoLUTs:C3_cyclic_mygbm_30_95_c78_n256_s25
  NeuroCytoLUTs:CET_CBTC2  matches  NeuroCytoLUTs:C3_cyclic_tritanopic_wrwc_70_100_c20_n256
  NeuroCytoLUTs:CET_D6  matches  NeuroCytoLUTs:C3_diverging_bky_60_10_c30_n256
  NeuroCytoLUTs:CET_D13  matches  NeuroCytoLUTs:C3_diverging_bwg_20_95_c41_n256
  NeuroCytoLUTs:CET_D1A  matches  NeuroCytoLUTs:C3_diverging_bwr_20_95_c54_n256
  NeuroCytoLUTs:CET_D1  matches  NeuroCytoLUTs:C3_diverging_bwr_40_95_c42_n256
  NeuroCytoLUTs:CET_D9  matches  NeuroCytoLUTs:C3_diverging_bwr_55_98_c37_n256
  NeuroCytoLUTs:CET_D10  matches  NeuroCytoLUTs:C3_diverging_cwm_80_100_c22_n256
  NeuroCytoLUTs:CET_D3  matches  NeuroCytoLUTs:C3_diverging_gwr_55_95_c38_n256
  NeuroCytoLUTs:CET_D12  matches  NeuroCytoLUTs:C3_diverging_isoluminant_cjm_75_c23_n256
  NeuroCytoLUTs:CET_D11  matches  NeuroCytoLUTs:C3_diverging_isoluminant_cjo_70_c25_n256
  NeuroCytoLUTs:CET_D7  matches  NeuroCytoLUTs:C3_diverging_linear_bjy_30_90_c45_n256
  NeuroCytoLUTs:CET_CBTD1  matches  NeuroCytoLUTs:C3_diverging_tritanopic_cwr_75_98_c20_n256
  NeuroCytoLUTs:CET_I1  matches  NeuroCytoLUTs:C3_isoluminant_cgo_70_c39_n256
  NeuroCytoLUTs:CET_I2  matches  NeuroCytoLUTs:C3_isoluminant_cgo_80_c38_n256
  NeuroCytoLUTs:CET_I3  matches  NeuroCytoLUTs:C3_isoluminant_cm_70_c39_n256
  NeuroCytoLUTs:CET_L9  matches  NeuroCytoLUTs:C3_linear_bgyw_20_98_c66_n256
  NeuroCytoLUTs:CET_L12  matches  NeuroCytoLUTs:C3_linear_blue_95_50_c20_n256
  NeuroCytoLUTs:CET_L7  matches  NeuroCytoLUTs:C3_linear_bmw_5_95_c86_n256
  NeuroCytoLUTs:CET_L8  matches  NeuroCytoLUTs:C3_linear_bmy_10_95_c71_n256
  NeuroCytoLUTs:CET_L11  matches  NeuroCytoLUTs:C3_linear_gow_65_90_c35_n256
  NeuroCytoLUTs:CET_L1  matches  NeuroCytoLUTs:C3_linear_grey_0_100_c0_n256
  NeuroCytoLUTs:CET_L16  matches  NeuroCytoLUTs:C3_linear_kbgyw_5_98_c62_n256
  NeuroCytoLUTs:CET_L5  matches  NeuroCytoLUTs:C3_linear_kgy_5_95_c69_n256
  NeuroCytoLUTs:CET_L4  matches  NeuroCytoLUTs:C3_linear_kry_0_97_c73_n256
  NeuroCytoLUTs:CET_CBL1  matches  NeuroCytoLUTs:C3_linear_protanopic_deuteranopic_kbjyw_5_95_c25_n256
  NeuroCytoLUTs:CET_CBL2  matches  NeuroCytoLUTs:C3_linear_protanopic_deuteranopic_kbw_5_98_c40_n256
  NeuroCytoLUTs:CET_L15  matches  NeuroCytoLUTs:C3_linear_ternary_blue_0_44_c57_n256
  NeuroCytoLUTs:CET_L14  matches  NeuroCytoLUTs:C3_linear_ternary_green_0_46_c42_n256
  NeuroCytoLUTs:CET_L13  matches  NeuroCytoLUTs:C3_linear_ternary_red_0_50_c52_n256
  NeuroCytoLUTs:CET_CBTL2  matches  NeuroCytoLUTs:C3_linear_tritanopic_krjcw_5_95_c24_n256
  NeuroCytoLUTs:CET_L19  matches  NeuroCytoLUTs:C3_linear_wcmr_100_45_c42_n256
  NeuroCytoLUTs:CET_L18  matches  NeuroCytoLUTs:C3_linear_wyor_100_45_c55_n256
  NeuroCytoLUTs:CET_R1  matches  NeuroCytoLUTs:C3_rainbow_bgyrm_35_85_c69_n256
  NeuroCytoLUTs:CET_R2  matches  NeuroCytoLUTs:C3_rainbow_bgyr_35_85_c72_n256

```
</details>