# Miniproject Feedback

## Report

**"Guidelines" below refers to the MQB report [MQB Miniproject report guidelines](https://mulquabio.github.io/MQB/notebooks/Appendix-MiniProj.html#the-report) [here](https://mulquabio.github.io/MQB/notebooks/Appendix-MiniProj.html) (which were provided to the students in advance).**

**Title:** “Biphasic Logistic Models Outperform Simpler Ones in Describing Bacterial Growth Curves”

- **Introduction (15%)**  
  - **Score:** 13/15  
  - Thorough references to modeling trade-offs (realism vs. parsimony), plus biphasic logistic context. Could expand on the specific parameterization of biphasic logistic for novices.

- **Methods (15%)**  
  - **Score:** 13/15  
  - Repeated fits and random starts are clearly stated. A bit more detail on biphasic logistic parameter definitions would further strengthen reproducibility.

- **Results (20%)**  
  - **Score:** 16/20  
  - Biphasic logistic captures death-phase data well. More numeric breakdown of each subset's performance could be included (e.g., total “wins”).

- **Tables/Figures (10%)**  
  - **Score:** 8/10  
  - Conceptual figures for logistic vs. Gompertz vs. biphasic are well structured. 

- **Discussion (20%)**  
  - **Score:** 16/20  
  - Connects findings back to broader questions of parsimony vs. realism. A bit more reflection on parameter-sensitivity or overfitting might help.

- **Style/Structure (20%)**  
  - **Score:** 15/20  
  - Well organized, with clear referencing. Slightly more cross-linking between results and discussion could enhance flow.

**Summary:** Strong overall, with clear methods, good data-fitting logic, and well-supported conclusions on biphasic logistic. Inclusion of a summary table for each subset would be a helpful addition.

**Report Score:** 81  

---

## Computing

### Project Structure & Workflow

**Strengths**

* Modularity: data wrangling, model fitting, visualization, and figure assembly are in separate scripts.
* Top‑level `run_scripts.sh` orchestrates execution, providing a simple UX for reproducing the analysis.
* Results and data directories are organized (e.g. `data/`, `results/`).

**Suggestions**

1. Lock package versions using **renv** or a DESCRIPTION file. That makes installation more robust than a list of `install.packages()` calls.
2. For more complex pipelines, consider **Makefile**, **drake**, or **targets** to manage dependencies and avoid rerunning unchanged steps.
3. Add `set -euo pipefail` at the top of `run_scripts.sh` to catch errors early and stop on failure:

   ```bash
   #!/usr/bin/env bash
   set -euo pipefail
   ```

---

### README File

**Strengths**

* Description of the project goal.
* Lists dependencies and usage instructions.

**Suggestions**

1. Add copy‑pasta commands illustrating a full run, e.g.:

   ```bash
   git clone ...
   cd Miniproject
   renv::restore()
   bash run_scripts.sh
   ```
2. Instead of listing `install.packages()`, reference a lockfile or script:

   ```r
   renv::init()
   renv::snapshot()
   ```
3. Explain relative paths (e.g. why scripts use `../data/`).
4. The `AICc_allmodels.csv` entry appears twice in “Results.” Remove duplicates.
5. Add a LICENSE file and specify data provenance / citation for the bacterial growth datasets.

---

### Code Structure & Syntax

####  DataWrang.R

* **Avoid `rm(list = ls())`**: Instead, run scripts in a clean R session.
* Use `here::here()` or `fs::path()` to build paths portably.
* Wrap cleaning steps into functions (e.g. `clean_data <- function(df) { ... }`), improving testability.
* Prefer `library(readr)` over `read.csv()`, and load only needed `dplyr`, `ggplot2`, etc.
* Move exploratory `print()`/`head()` out of production script; use interactive notebooks or tests instead.

### model\_fitting.R

* Linear, quadratic, and cubic fit functions share nearly identical structure. Abstract a generic wrapper:

  ```r
  fit_poly <- function(i, data, degree) { ... }
  ```
* In `fit_with_sampling`, the variable `trial` in `aicc_values[trial] <<- ...` is undefined in that scope. Consider using a `for(trial in seq_len(n_trials))` inside the sampling function or pass `trial` into it.
* Set `set.seed()` before sampling starting values to enable reproducible fits.
* Use `lower=`/`upper=` in `nlsLM()` to prevent unrealistic parameter values drifting far from data support.
* You parallelize across IDs but not within heavy NLLS loops. Consider **furrr** or parallel map for consistency.
* Summarize failed fits (e.g. log warnings) rather than silently discarding them.

####  Figure\_2.R & visualisation.R

* *DRY Principle*: The six panel plots differ only by ID and annotation text. Create a helper function:

  ```r
  make_panel <- function(id, label, annotate_params) { ... }
  panels <- map(panel_specs, ~ make_panel(...))
  ```
* If layout permits, use `facet_wrap(~ model)` to reduce boilerplate.
* Good approach! Just ensure `fitted_df` is loaded only once.
* *Bug in visualisation.R*: It references `data` and `fitted_points_df` but only reads `fitted_df`; you need to read `cleaned_data_final.csv` and align variable names.

#### run\_scripts.sh

* **Error Checking**: Use `set -e`.
* **Shebang**: Use `#!/usr/bin/env bash` for portability.
* **Logging**: Print timestamps or redirect logs to a file for auditing.

---

### NLLS Fitting Approach

**Strengths**

* Comparison of six candidate models (linear → biphasic logistic) via AICc.
* Sensitivity analysis via multiple starting‑value trials.

**Suggestions**

1. Current SD multipliers (×2 or ×5) can yield extreme starting values. Define distributions grounded in domain knowledge (e.g. plausible `r_max` range).
2. Instead of naive normal sampling **nls.multstart::nls\_multstart()** would cover parameter space more uniformly.
3. Leverage `nlsLM()`’s `lower`/`upper` arguments to bound parameters (e.g. `N_0 > 0`, `K > N_0`).
4. Record convergence flags and residual standard error; inspect patterns in failed fits.
5. Reporting ΔAICc thresholds is good; consider also evidence ratios or Akaike weights for more nuanced model selection.
6. For time‑series, consider leave‑timepoint‑out cross‑validation to assess predictive performance beyond in‑sample AICc.

---

### Summary

Good pipeline! Needed more modularization and reproducibility enhancements, and minor bug fixes in the NLLS loops and visualization scripts to scale up analysis more robustly and transparently.

### **Score: 70**

---

## Overall Score: (81 + 70)/2 = 75.5