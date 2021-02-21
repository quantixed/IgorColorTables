# IgorColorTables
Port to Igor of look-up tables (LUTs) from NeuroCyto LUTs ImageJ Update Site

In this repo there are a bunch of look-up tables represented as 16-bit ibw files for use in IgorPro.

The ImageJ Update Site [NeuroCyto-LUTs](https://sites.imagej.net/NeuroCyto-LUTs/) created by [Christophe Leterrier](https://github.com/cleterrier) makes available a huge number of look-up tables to Fiji users (repo [here](https://github.com/cleterrier/ChrisLUTs)). These `*.lut` files are in one of three formats:

- 3 column text files with red, green, blue values
- 4 column text files with integer, red, green, blue values
- binary file

In order to get 4 column text versions of all LUTs available in your installation of Fiji/ImageJ, run `lut2tsv.ijm`.

To bring all of these into Igor, use `LoadColorTableCSVs.ipf` and point Igor at the directory containing the LUTs (there is an option to load CSV format LUTs from other sources). Then ibw versions can be saved. Alternatively, use the loadColorTable

Below are the LUTs available in Fiji with the Update Site enabled. See `summary.pdf` for the Igor version.

![img](img/montage.png?raw=true "image")