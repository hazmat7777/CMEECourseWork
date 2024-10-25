"""Iterating through lists using for loops and list comprehensions."""

taxa = ['Quercus robur',
        'Fraximus excelsior',
        'Pinus sylvestris' ,
        'Quercus cerris' ,
        'Quercus petraea' 
        ]

def is_an_oak(name):
    """Identifies oaks"""
    return name.lower().startswith('quercus ')



##Using for loops

oaks_loops = set()

for species in taxa:

    if is_an_oak(species):
        
        oaks_loops.add(species)
        
print(oaks_loops)

##using list comprehensions
oaks_lc = set([species 
                for species in taxa             
                if is_an_oak(species)])
print(oaks_lc)

##get names in upper case using for loops

oaks_loops = set()


for species in taxa:
    if is_an_oak(species):
        oaks_loops.add(species.upper())
    print(oaks_loops)   #this is wrong, see output, because of indentation
    
oaks_loops = set()
for species in taxa:
    if is_an_oak(species):
        oaks_loops.add(species.upper())
print(oaks_loops)       #corrected version

##get names in UPPERCASE using list comprehensions

oaks_lc = set([species.upper() for species in taxa if is_an_oak(species)])

print(oaks_lc)

#unsure why we need sqr brackets
