
# Feedback on Project Structure, Workflow, and Code Structure

**Student:** Harry Trevelyan

---

## General Project Structure and Workflow

- **Directory Organization**: The project is well-structured, with weekly directories like `week1`, `week2`, and `week3`, alongside separate folders for code, data, and results. This setup is clear and allows for easy navigation through weekly tasks.
- **README Files**: There are informative README files in both the root and `week3` directories, outlining the languages used and dependencies required. The inclusion of usage examples for more complex scripts, such as `DataWrang.R`, `Girko.R`, and `align_seqs_fasta.py`, would enhance comprehension for users who are unfamiliar with these files.

### Suggested Improvements:
1. **Expand README Files**: Include examples of command-line usage and expected inputs/outputs for key scripts.
2. **Git Management**: With `sandbox` and `results` included in `.gitignore`, the project maintains efficiency by avoiding unnecessary file tracking.

## Code Structure and Syntax Feedback

### R Scripts in `week3/code`

1. **break.R**: Demonstrates effective use of loop controls. Adding inline comments for conditions like `i == 10` would improve clarity.
2. **sample.R**: This script efficiently contrasts different looping and vectorization methods. Include a comment explaining the performance implications of each approach.
3. **Vectorize1.R**: Uses loops and vectorized functions to sum matrix elements. Correcting minor spelling (e.g., "Dimentions" to "Dimensions") would enhance readability.
4. **R_conditionals.R**: Useful functions for determining number properties. Consider handling edge cases for `NA` inputs to enhance robustness.
5. **apply1.R**: Demonstrates `apply()` across matrix dimensions. Adding comments to explain row and column operations will improve comprehension.
6. **basic_io.R**: Manages data I/O effectively. Streamlining repetitive code could improve efficiency.
7. **boilerplate.R**: This template file is clear, with print statements indicating data types. Inline comments would help clarify each function’s purpose.
8. **apply2.R**: Applies conditional functions using `apply()`. Adding inline comments would clarify the effects of each operation.
9. **try.R**: Contains effective error handling, though using `tryCatch()` could provide more structured error responses.
10. **control_flow.R**: Demonstrates basic control flow structures. Adding a header block summarizing each structure would help users.
11. **TreeHeight.R**: The function is well-structured, with clear argument definitions. Adding an example calculation would help illustrate expected output.
12. **next.R**: Uses `next` to skip certain loop iterations. Add comments explaining this application for clarity.
13. **browse.R**: The use of `browser()` for debugging is effective but should be commented out or moved to a `sandbox` for production readiness.
14. **preallocate.R**: Effectively shows performance comparisons between preallocated and non-preallocated loops. Adding summary comments would clarify the time efficiency of each approach.

### Python Scripts

1. **align_seqs_fasta.py**: The script effectively aligns sequences from two files. Adding error handling for missing files, such as providing a user-friendly message or sample file, would improve user experience.
2. **oaks_debugme.py**: Uses docstrings well, and `is_an_oak()` is appropriately tested with `doctest`. Adding a test file with additional oak and non-oak species could strengthen debugging capabilities.

---
