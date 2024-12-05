#!/usr/bin/env python3

"""Aligns two sequences read from a csv file."""

## imports
import csv
import os

## functions
def read_sequences(input_path):
    """Reads sequences from a CSV file."""
    
    if not input_path.endswith('.csv'):
        raise ValueError("The input file must be a CSV file.")
    
    # Check if the file exists before trying to open it
    if not os.path.isfile(input_path):
        raise FileNotFoundError(f"Error: The file {input_path} was not found.")
    
    try:
        with open(input_path, 'r') as file:
            reader = csv.reader(file)
            seqs = [item for row in reader for item in row]  # Flattening the sequence list

            # Debugging print statement to confirm sequences are read
            print(f"Sequences read: {seqs}")
            
            # Check if at least two sequences are read
            if len(seqs) < 2:
                raise ValueError("The input CSV must contain at least two sequences.")
            
            return seqs
            
    except Exception as e:
        print(f"Error reading the file: {e}")
        exit(1)  # Exit in case of any other error

def make_s1_longest(seq1, seq2):
    """Assigns the longer sequence s1, and the shorter to s2"""
    l1 = len(seq1)
    l2 = len(seq2)
    if l1 >= l2:
        s1 = seq1
        s2 = seq2
    else:
        s1 = seq2
        s2 = seq1
        l1, l2 = l2, l1 # swap the two lengths
    return s1, s2

def calculate_score(s1, s2, l1, l2, startpoint):
    """Calculates the number of shared bases between two sequences."""
    matched = "" # to hold string displaying alignements
    score = 0
    for i in range(l2):
        if (i + startpoint) < l1:
            if s1[i + startpoint] == s2[i]: # if the bases match
                matched = matched + "*"
                score = score + 1
            else:
                matched = matched + "-"
    return matched, score

def find_best_alignment(s1, s2, l1, l2):
    """Finds the best alignment and score between two sequences."""
    my_best_align = None
    my_best_score = -1
    my_best_matched = ""
    for i in range(l1):  # Trying all startpoints
        matched, score = calculate_score(s1, s2, l1, l2, i)  # Call your modified calculate_score
        if score > my_best_score:
            my_best_matched = "." * i + matched  # Store the matched string
            my_best_align = "." * i + s2  # Adding 'i' many dots to align the sequences
            my_best_score = score
    return my_best_align, my_best_score, my_best_matched

def main(input_path="../data/fasta/seqs_to_align.csv", output_file="../results/best_alignment.txt"):
    """Reads sequences from a csv, finds the best alignment, and writes the result to a text file."""
    print(f"Starting alignment with input file: {input_path}")
    seqs = read_sequences(input_path)
    seq1 = seqs[0]
    seq2 = seqs[1]
    print(f"Sequences to align: {seq1}, {seq2}")  # Debug print
    s1, s2 = make_s1_longest(seq1, seq2)
    l1 = len(s1)
    l2 = len(s2)
    my_best_align, my_best_score, my_best_matched = find_best_alignment(s1, s2, l1, l2)
    
    print(f"Best score: {my_best_score}")  # Debug print
    
    with open(output_file, 'w') as f:
        f.write(my_best_align + '\n')  # Note that you just take the last alignment with the highest score
        f.write(my_best_matched + '\n')
        f.write(s1 + '\n')
        f.write(f"Best score: {my_best_score}\n")
    print(f"Alignment results saved to: {output_file}")  # Debug print
    
if __name__ == "__main__":
    main()
