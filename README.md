# IgorColorTables

Port to Igor of look-up tables (LUTs) from NeuroCyto LUTs ImageJ Update Site and others.

In this repo there are a bunch of look-up tables represented as 16-bit ibw files for use in IgorPro.

The ImageJ Update Site [NeuroCyto-LUTs](https://sites.imagej.net/NeuroCyto-LUTs/) created by [Christophe Leterrier](https://github.com/cleterrier) makes available a huge number of look-up tables to Fiji users (repo [here](https://github.com/cleterrier/ChrisLUTs)).
These `*.lut` files are in one of three formats:

- 3 column text files with red, green, blue values
- 4 column text files with integer, red, green, blue values
- binary file

In order to get 4 column text versions of all LUTs available in your installation of Fiji/ImageJ, run `lut2tsv.ijm`.

To bring all of these into Igor, use `LoadColorTableCSVs.ipf` and point Igor at the directory containing the LUTs (there is an option to load CSV format LUTs from other sources).

From here, `*.ibw` versions can be saved.

Below are the LUTs available in Fiji with the Update Site enabled.
See `NeuroCytoLUTs.pdf` for the Igor version.

As a bonus, [Peter Kovesi's colour maps](http://peterkovesi.com/projects/colourmaps/) are included (see this [paper](https://arxiv.org/abs/1509.03700)).
See `kovesi.pdf` for details.

![img](img/montage.png?raw=true "image")

The huge number of LUTs can be a little overwhelming.
Similarity of LUTs is shown here:

![img](img/lutTree.png?raw=true "image")

<details>
	<summary>Note there are currently a number of duplicated LUTs</summary>

```
CET-L4	C3_linear_kry_0-97_c73_n256
CET-CBL1	C3_linear-protanopic-deuteranopic_kbjyw_5-95_c25_n256
CET-CBTC2	C3_cyclic-tritanopic_wrwc_70-100_c20_n256
CET-L1	C3_linear_grey_0-100_c0_n256
CET-R1	C3_rainbow_bgyrm_35-85_c69_n256
CET-CBL2	C3_linear-protanopic-deuteranopic_kbw_5-98_c40_n256
CET-C2s	C3_cyclic_mygbm_30-95_c78_n256_s25
CET-CBTD1	C3_diverging-tritanopic_cwr_75-98_c20_n256
CET-D3	C3_diverging_gwr_55-95_c38_n256
CET-L5	C3_linear_kgy_5-95_c69_n256
CET-I2	C3_isoluminant_cgo_80_c38_n256
CET-L13	C3_linear_ternary-red_0-50_c52_n256
CET-D1	C3_diverging_bwr_40-95_c42_n256
CET-D7	C3_diverging-linear_bjy_30-90_c45_n256
CET-L14	C3_linear_ternary-green_0-46_c42_n256
CET-L12	C3_linear_blue_95-50_c20_n256
CET-I1	C3_isoluminant_cgo_70_c39_n256
CET-D6	C3_diverging_bky_60-10_c30_n256
CET-R2	C3_rainbow_bgyr_35-85_c72_n256
CET-C5	C3_cyclic_grey_15-85_c0_n256
CET-D1A	C3_diverging_bwr_20-95_c54_n256
CET-D9	C3_diverging_bwr_55-98_c37_n256
CET-L15	C3_linear_ternary-blue_0-44_c57_n256
CET-I3	C3_isoluminant_cm_70_c39_n256
CET-L9	C3_linear_bgyw_20-98_c66_n256
CET-L8	C3_linear_bmy_10-95_c71_n256
CET-C5s	C3_cyclic_grey_15-85_c0_n256_s25
CET-L18	C3_linear_wyor_100-45_c55_n256
CET-D11	C3_diverging-isoluminant_cjo_70_c25_n256
CET-D10	C3_diverging_cwm_80-100_c22_n256
CET-L11	C3_linear_gow_65-90_c35_n256
CET-C2	C3_cyclic_mygbm_30-95_c78_n256
CET-CBTL2	C3_linear-tritanopic_krjcw_5-95_c24_n256
CET-L19	C3_linear_wcmr_100-45_c42_n256
CET-D12	C3_diverging-isoluminant_cjm_75_c23_n256
CET-D13	C3_diverging_bwg_20-95_c41_n256
CET-L7	C3_linear_bmw_5-95_c86_n256
CET-L16	C3_linear_kbgyw_5-98_c62_n256
```
</details>