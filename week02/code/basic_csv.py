"""Script demonstrating the use of the csv module to read and write csv files."""
import csv
#read a file containing:
# 'Species', 'Infraorder', 'Family', 'Distribution', 'Body mass male (Kg)'
with open('../data/testcsv.csv', 'r') as f:

    csvread = csv.reader(f)
    temp = []
    for row in csvread:
        temp.append(tuple(row))
        print(row)
        print("The species is", row[0])

# write a file comntaining only species name and body mass
with open('../data/testcsv.csv', 'r') as f:
    with open('../data/bodymass.csv', 'w') as g:
        
        csvread = csv.reader(f)        #converts csv to a list of rows 
        csvwrite = csv.writer(g)       #does the opposite
        for row in csvread:
            print(row)                  #shows that something is happening
            csvwrite.writerow([row[0], row[4]]) #writes rows 0 and 4 into g