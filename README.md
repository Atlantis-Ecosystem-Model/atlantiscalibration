# General Overview

Package to calibrate the Atlantis ecosystem model using the **calibrar** R package.  
The example included here is applied to the **Southeast Tasmania Atlantis Model**.


![V3 Figure 1 papier calibration](https://github.com/user-attachments/assets/0f1aaa58-dfaf-4231-869b-87db8c276bf0)

# Recommendations for performing an Atlantis calibration with calibrar

To perform the Atlantis Calibration with calibrar, review our material in this order:

1. Read our preprint describing the calibration of Atlantis using **calibrar**:  
   https://papers.ssrn.com/sol3/papers.cfm?abstract_id=5888414

2. Go through the slides presenting the article:  
   https://docs.google.com/presentation/d/1LF5dIWs0NObyVicStsMRFs5jmnmBjcYI/edit

3. Watch the recording of the workshop describing the files and scripts:  
   https://drive.google.com/file/d/1QSdkpcLq7TR39WiESiUJAEdU-YdxBp5o/view  

   A transcript of the workshop is also available:  
   https://docs.google.com/document/d/1vbCfxM_akezcLdmvxRtgcGKmWH44Ju6m/edit

4. Pull and explore the code for the packages linking **Atlantis** and **calibrar**:  
   - https://github.com/alaiam/Atlantis_Calibration  
   - https://github.com/alaiam/atlantis2ls

5. Explore the **calibrar** package and associated publication:  
   https://besjournals.onlinelibrary.wiley.com/doi/full/10.1111/2041-210X.14452

## Development Setup

### Installation

To install the package for development or use:

```r
devtools::install()
```

**Important:** For parallel calibration to work, the package must be properly installed in the system library (not just loaded with `devtools::load_all()`). This is because parallel worker nodes need access to the installed package.

### Best Practices for Development

To avoid package build errors and database corruption issues:

1. **Always use a fresh R session before installing**
   - Close and restart R completely before running `devtools::install()`
   - This prevents conflicts between development-mode loading and installation

2. **Don't mix development modes in the same session**
   - During development: use `devtools::load_all()` to test changes
   - For testing/deployment: use `devtools::install()` in a **fresh R session**
   - Never call both approaches in the same R session

If you encounter a "lazy-load database is corrupt" error:

```r
# Clean up and reinstall
remove.packages('atlantiscalibration')
devtools::install()
```

   
