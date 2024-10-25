"""List comprehensions and for loops to extract data from a tuple of tuples."""

birds = ( ('Passerculus sandwichensis','Savannah sparrow',18.7),
          ('Delichon urbica','House martin',19),
          ('Junco phaeonotus','Yellow-eyed junco',19.5),
          ('Junco hyemalis','Dark-eyed junco',19.6),
          ('Tachycineata bicolor','Tree swallow',20.2),
         )

#(1) Write three separate list comprehensions that create three different
# lists containing the latin names, common names and mean body masses for
# each species in birds, respectively. 
print("Using list comps: \n")

latin_names1 = [row[0] for row in birds]
print('Latin names: \n', latin_names1)

cmn_names1 = [row[1] for row in birds]
print('Common names: \n', cmn_names1)

bird_masses1 = [row[2] for row in birds]
print('Body masses: \n', bird_masses1)

# (2) Now do the same using conventional loops (you can choose to do this 
# before 1 !). 

print("\nUsing loops: \n")

latin_names2 = []
for row in birds:
    latin_names2.append(row[0])

print('Latin names: \n', latin_names2)

cmn_names2 = []
for row in birds:
    cmn_names2.append(row[1])

print('Common names: \n', cmn_names2)

bird_masses2 = []
for row in birds:
    bird_masses2.append(row[2])

print('Body masses: \n', bird_masses2)

# A nice example output is:
# Step #1:
# Latin names:
# ['Passerculus sandwichensis', 'Delichon urbica', 'Junco phaeonotus', 'Junco hyemalis', 'Tachycineata bicolor']
# ... etc.
 