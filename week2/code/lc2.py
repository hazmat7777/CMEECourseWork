"""Using for loops and list comprehensions to extract data from a tuple of tuples."""
# Average UK Rainfall (mm) for 1910 by month
# http://www.metoffice.gov.uk/climate/uk/datasets
rainfall = (('JAN',111.4),
            ('FEB',126.1),
            ('MAR', 49.9),
            ('APR', 95.3),
            ('MAY', 71.8),
            ('JUN', 70.2),
            ('JUL', 97.1),
            ('AUG',140.2),
            ('SEP', 27.0),
            ('OCT', 89.4),
            ('NOV',128.4),
            ('DEC',142.2),
           )

# (1) Use a list comprehension to create a list of month,rainfall tuples where
# the amount of rain was greater than 100 mm.

print("Using list comprehensions: \n")

rainy_months =[row for row in rainfall if row[1] > 100]

print("Rainy months and their rainfalls:", rainy_months)
 
# (2) Use a list comprehension to create a list of just month names where the
# amount of rain was less than 50 mm. 

dry_months = [row[0] for row in rainfall if row[1] < 50]

print("Dry months: ", dry_months)

# (3) Now do (1) and (2) using conventional loops (you can choose to do 
# this before 1 and 2 !). 

print("\nUsing loops: \n")

rainy_months2 = []
for row in rainfall:
    if row[1] > 100:
        rainy_months2.append(row)

print("Rainy months and their rainfalls:", rainy_months2)


dry_months2 = []
for row in rainfall:
    if row[1] < 50:
        dry_months2.append(row[0])

print("Dry months: ", dry_months2)

# A good example output is:
#
# Step #1:
# Months and rainfall values when the amount of rain was greater than 100mm:
# [('JAN', 111.4), ('FEB', 126.1), ('AUG', 140.2), ('NOV', 128.4), ('DEC', 142.2)]
# ... etc.

