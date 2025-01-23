
# Final CMEE Bootcamp Assessment: Harry Trevelyan

- You maintained a consistent and well-organized directory structure throughout the weeks - good!
- README files showed steady improvement, evolving to include detailed instructions, dependencies, and script descriptions.

## Week  1

- README outlined basic structure and author details.
- Results folder was correctly left empty.
   - `.gitignore` was basic and could have excluded more unnecessary files.
- README lacked usage examples or script explanations.
- Shell scripts demonstrated foundational skills in automation and file manipulation.
- `CompileLaTeX.sh` failed due to improper handling of missing input arguments.
- `tiff2png.sh` lacked validation for the presence of `.tif` files in the directory.

## Week  2
  - `.gitignore` improved, excluding more temporary and unnecessary files.
- README could include troubleshooting tips for scripts.
- Python scripts displayed a good understanding of file handling, control flow, and basic data manipulation.
   - Scripts like `cfexercises1.py` included docstrings, improving clarity.
- `align_seqs.py` required better error handling for malformed input files.

## Week  3

- README provided clear descriptions of R scripts, dependencies, and data sources.
- Dependencies for R were explicitly listed with installation instructions.
- README lacked detailed usage examples for complex scripts.
- Inline comments explaining the logic behind complex steps could improve readability.

## Week  4

- README was more comprehensive, detailing the Florida autocorrelation practical and other key scripts.
- The integration of LaTeX workflows was well-documented.
- `Florida.R` implemented a robust permutation test to estimate the p-value for the correlation between temperature and year.
- The use of comments explaining the limitations of traditional methods (e.g., `cor.test()`) was a good idea.
- Add inline comments explaining each step of the permutation test.
- The LaTeX report was concise, with clear explanations and professional-quality plots.
- Could have expanded the discussion to address the broader implications of the warming trend in Florida.

---

## Git Practices

- Commit frequency and message quality improved significantly across the weeks.
- `.gitignore` was consistently updated to exclude unnecessary files and directories.
- Some early commits were vague (e.g., "update script"). Use descriptive messages like "Refactor Florida.R to include parameterized permutation tests.- Introducing feature branches for major changes could enhance collaboration and workflow management.

---

## Overall Assessment

You did an excellent job overall! 

I was impressed by your efforts to understand as many details of the programming languages and coding as possible. You demonstrated substantial progress in programming skills, workflow organization, and documentation throughout the bootcamp. 

Commenting could be improved -- you are currently erring on the side of overly verbose comments at times (including in your readmes), which is nonetheless better than not commenting at all, or too little! This will improve with experience, as you will begin to get a feel of what is ``common-knowledge'' among programmers, and what stylistic idioms are your own and require explanation. In general though, comments should be written to help explain a coding or syntactical decision to a user (or to your future self re-reading the code!) rather than to describe the meaning of a symbol, argument or function (that should be in the function docstring in Python for example).

It was a tough set of weeks, but I hope they have given you a good start towards further training, a quantitative masters dissertation, and ultimately a career in quantitative biology!

### (Provisional) Mark

*77*