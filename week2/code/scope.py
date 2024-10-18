###scope- the visibility and lifetime of variables

i = 1
x = 0
for i in range(10): #loop iterates 10 times (from 0-9)
    x += 1           #increases x by 1 for each iter of loop
print(i)
print(x)

#why are i and x different? redoing step by step

i = 1
x = 0

i, x #or print (i, x)


for i in range(10):
    x += 1

i, x

#i is now 9 cos it ran from numbers 1-> 10 (excluding 10)
#x is 10 cos of the increment (added 1 to 0, 10 times)


i = 1
x = 0

def a_function(y):
    x = 0
    for i in range(y):
        x += 1
    return x

a_function(10)
    #returns the value of x, remember!
    

     #would expect it to change i and x -> 9,10 like above


i,x     #it didnt because the scope of the variables
        #in the function is limited to within that fn

#more explaining:
#repeat code
i = 1
x = 0
def a_function(y):
    x = 0
    for i in range(y):
        x += 1
    return x

whos    #can see x and also function

#to update x:

x = a_function(10)

x

## local vs global variables

_a_global = 10 # a global variable

if _a_global >= 5:
    _b_global = _a_global + 5 #also a global variable

print("Before calling a_function, outside the function, the value of _a_global is", _a_global)
print("Before calling a_function, outside the function, the value of _b_global is", _b_global)

def a_function():
    _a_global = 4 # a local variable
    
    if _a_global >= 4:
        _b_global = _a_global + 5 # also a local variable
        
    _a_local = 3
    
    print("Inside the function, the value of _a_global is", _a_global)
    print("Inside the function, the value of _b_global is", _b_global)
    print("Inside the function, the value of _a_local is", _a_local)

a_function()


print("After calling a_function, outside the function, the value of _a_global is (still)", _a_global)
print("After calling a_function, outside the function, the value of _b_global is (still)", _b_global)
print("After calling a_function, outside the function, the value of _a_local is ", _a_local)

#_a_local remained inside the function

#global variables are available within functions though ofc

_a_global = 10

def a_function():
    _a_local = 4
    
    print("Inside the fn _a_local is", _a_local)
    print("inside the fn _a_global is", _a_global)

a_function()

print("Outside the fn, _a_global is", _a_global)

## modifying global variables from inside a fn- use 'global' keyword

_a_global = 10

print("Before calling a_function, outside fn, value of _a_global is", _a_global)

def a_function():
    global _a_global
    _a_global = 5
    _a_local = 4

    print("Inside the fn, _a_global is", _a_global)
    print("Inside the fn, _a_local is", _a_local)
    
a_function()

print("after calling a_function, outside fn, _a_global is", _a_global)

#_a_global changed outside fn due to global keyword

##using global inside nested functions

def a_function():
    _a_global = 10

    def a_function2():
        global _a_global
        _a_global = 20
    
    print("Before calling a_function2, within a_function, _a_global is", _a_global)
    
    a_function2()

    print("After calling a_function2, within a_function, _a_global is", _a_global)
    
a_function()

print("a_global in main workspace / namespace now is", _a_global)

#swapping lines to define the global variable outside the a_function

_a_global = 10

def a_function():

    def a_function2():
        global _a_global
        _a_global = 20
    
    print("Before calling a_function2, within a_function, _a_global is", _a_global)
    
    a_function2()

    print("After calling a_function2, within a_function, _a_global is", _a_global)
    
a_function()

print("a_global in main workspace / namespace now is", _a_global)
