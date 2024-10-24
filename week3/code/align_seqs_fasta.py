#!/usr/bin/env python3

"""
Use functions to find the longest matching sequence in two files of DNA sequences and save the result as a text file
"""
__author__ = 'Dashing_Dingos(4)'
__version__ = '0.2.2'

import sys
import os


def read_file(file_name):
    """Reads a fasta file and returns the sequence and the sequence name"""
    try:
        with open(file_name) as f:
            seq_name = f.readline().strip()  # Get the sequence name
            sequence = f.read().strip().replace("\n", "")  # Get the sequence data
    except FileNotFoundError: # Checking the file exists
        print(f"Error: The file {file_name} does not exist.")
        sys.exit(1) # Terminate the program if there is no

    return seq_name, sequence


def calculate_score_and_alignment(s1, s2, l1, l2, startpoint):
    """Calculate the alignment score and returns the alignment details"""
    matched = ""  # To hold string displaying matches (*) and mismatches (-)
    alignment_s1 = "." * startpoint + s2  # Align s2 starting at the given point
    score = 0
    for i in range(l2):
        if (i + startpoint) < l1:
            if s1[i + startpoint] == s2[i]:  # If the bases match
                matched += "*"
                score += 1
            else:
                matched += "-"
    matched = "." * startpoint + matched # line up matched with the best alignment
    return score, alignment_s1, matched


def compare_seq_score(s1, s2, l1, l2):
    """Find the best alignment and return its score and the alignment"""
    best_align = None # Holds string for best alignment 
    best_score = -1 # Store highest score so far (-1 to be lower than any possible score)
    best_match = None # Holds string for best base matches
    for i in range(l1):  # Iterate over all possible starting points
        # Calculate score/alignment for each possible starting position (i)  for s2 within s1
        current_score, alignment_s1, matched = calculate_score_and_alignment(s1, s2, l1, l2, i)
        # Update the best alignment and store values 
        if current_score > best_score: 
            best_align = alignment_s1
            best_score = current_score
            best_match = matched
    return best_score, best_align, best_match


def format_alignment(s1, s2, match_line, line_length=80):
    """Format the alignment output for better readability"""
    output = ""    # Initialize an empty string to store the formatted output.
    
    # Iterate through the sequences, breaking them into chunks of 'line_length' characters.
    for i in range(0, len(s1), line_length):
        output += s1[i:i+line_length] + "\n"   # Add a substring of the first sequence, up to 'line_length' characters per line.
        output += match_line[i:i+line_length] + "\n"   # Add the corresponding substring of the match line (alignment indicators).
        output += s2[i:i+line_length] + "\n\n"   # Add the corresponding substring of the second sequence, up to 'line_length' characters per line.
    return output   # Return the formatted alignment string.


def save_results(seq_name1, seq_name2, best_score, best_align, match_line, original_s1, line_length=80):
    """Save the best alignment and score as a text file"""
    output_dir = "../results"               # Directory to save the output text file.
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    # Format the result for text output
    formatted_alignment = format_alignment(original_s1, best_align, match_line, line_length)
    
    # Define the file path for saving the alignment resul
    output_file_txt = os.path.join(output_dir, "align_seqs_fasta.txt")
    
    # Open the file in write mode and save the alignment details.
    with open(output_file_txt, "w") as f:   
        f.write(f"Alignment between {seq_name1} and {seq_name2}\n\n")   # Write sequence names. 
        f.write(f"Best alignment score: {best_score}\n\n")  # Write the best alignment score. 
        f.write(formatted_alignment)    # Write the formatted alignment
    print(f"Text file saved to {output_file_txt}")   # Print a message to indicate the file was saved successfully.


def main(file1, file2):
    """
    Main function to read two fasta files, compute the best alignment between their sequences, 
    and save the alignment result to a file.

    Args:
    file1 (str): Path to the first fasta file.
    file2 (str): Path to the second fasta file.
    """
    # Read the first sequence file
    seq_name1, seq1 = read_file(file1)

    # Read the second sequence file
    seq_name2, seq2 = read_file(file2)

    # Get the lengths of the two sequences
    l1, l2 = len(seq1), len(seq2)

    # Ensure s1 is the longer sequence
    if l2 > l1:
        seq1, seq2 = seq2, seq1
        l1, l2 = l2, l1
        seq_name1, seq_name2 = seq_name2, seq_name1
    # Compute the best alignment, score, and match line between the two sequences
    best_score, best_align, match_line = compare_seq_score(seq1, seq2, l1, l2)

    # Save the alignment results to an output file
    save_results(seq_name1, seq_name2, best_score, best_align, match_line, seq1)


if __name__ == "__main__":
    # Check if exactly 2 arguments are provided
    if len(sys.argv) == 3:
        main(sys.argv[1], sys.argv[2])
    
    # If only 1 argument is provided, use a default second file
    elif len(sys.argv) == 2:
        print("Warning: Only one input file provided, using default second file.")
        main(sys.argv[1], "../data/fasta/407228326.fasta")
        
    # If no arguments are provided, use two default files
    elif len(sys.argv) == 1:
        print("No input provided, using default files.")
        main("../data/fasta/407228412.fasta", "../data/fasta/407228326.fasta")
    # Handle incorrect input (more than 2 arguments)
    else:
        print("Error: Incorrect input format. Provide 0, 1, or 2 fasta files.")
        sys.exit(1)