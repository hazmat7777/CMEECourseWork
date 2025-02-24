"""For loop and list comprehension to populate a dictionary from a list of tuples."""

taxa = [ ('Myotis lucifugus','Chiroptera'),
         ('Gerbillus henleyi','Rodentia',),
         ('Peromyscus crinitus', 'Rodentia'),
         ('Mus domesticus', 'Rodentia'),
         ('Cleithrionomys rutilus', 'Rodentia'),
         ('Microgale dobsoni', 'Afrosoricida'),
         ('Microgale talazaci', 'Afrosoricida'),
         ('Lyacon pictus', 'Carnivora'),
         ('Arctocephalus gazella', 'Carnivora'),
         ('Canis lupus', 'Carnivora'),
        ]

# Write a python script to populate a dictionary called taxa_dic derived from
# taxa so that it maps order names to sets of taxa and prints it to screen.
# 
# An example output is:
#  
# 'Chiroptera' : set(['Myotis lucifugus']) ... etc. 
# OR, 
# 'Chiroptera': {'Myotis  lucifugus'} ... etc

#### Your solution here #### 

#taxa_dic =  {}

#for i in taxa:
#    if i[1] not in taxa_dic:            #only add a new key if it's not already there
#        #taxa_dic[key] = value        #this is how you add a new key-value pair 
#        taxa_dic[i[1]] = set()          # species names are sets
#        taxa_dic[i[1]].add(i[0])        # adding spp name to the newly created key      # add to a set, append to a list
#    else:
#        taxa_dic[i[1]].add(i[0])

#print(taxa_dic)

## trying again to make it more readable. See also above

taxa_dic =  {}

for species, order in taxa:     #can write anything for row, column
    if order not in taxa_dic:            
        #taxa_dic[key] = value        
        taxa_dic[order] = set()          
        taxa_dic[order].add(species)        
    else:
        taxa_dic[order].add(species)

print(taxa_dic)

# Now write a list comprehension that does the same (including the printing after the dictionary has been created)  
 
#### Your solution here #### 

taxa_dic_lc = {order: set() for species, order in taxa} 

taxa_dic_lc #above made an empty dictionary with the orders from taxa as the keys

for species, order in taxa:
    taxa_dic_lc[order].add(species)  # Populate sets

taxa_dic_lc