# Check_chr_vs_plasmid
Checks if a gene of interest is on a chromosome or plasmid

How to get the code:
```
git clone https://github.com/abuultjens/Check_chr_vs_plasmid.git
```

Activate a conda env with snippy
```
conda activate [env_name]
```

How to run it:
```
sh Check_chr_vs_plasmid.sh [blast_report.csv] [outfile_name.csv]
```

Example:
```
sh Check_chr_vs_plasmid.sh ArdA_E.fm_Uniprot_Q3XYD3_report_ArdA_E.fm_Uniprot_Q3XYD3_ID-gtet-98_LEN-gtet-165.csv ArdA_E.fm_Uniprot_Q3XYD3_report_ArdA_E.fm_Uniprot_Q3XYD3_ID-gtet-98_LEN-gtet-165_CHR-PLAS.csv
```
