"""
Demonstrates the concept of variable scope in Python,
including local and global variables, and how their visibility and 
lifetime can affect program behavior.
"""

i = 1
x = 0
for i in range(10):  # Loop iterates 10 times (from 0-9)
    x += 1           # Increases x by 1 for each iteration of the loop
print(i)  # Prints the final value of i
print(x)  # Prints the final value of x

# Explanation of variable differences
i = 1
x = 0

print(i, x)  # Display initial values of i and x

for i in range(10):
    x += 1

print(i, x)  # Final values after the loop

# i is now 9 because it ran from numbers 1 to 10 (excluding 10)
# x is 10 because it was incremented 10 times

i = 1
x = 0

def a_function(y):
    """Increments a local variable x from 0 to y and returns its value."""
    x = 0
    for i in range(y):
        x += 1
    return x

result = a_function(10)  # Calls the function with 10

# Variables i and x outside the function remain unchanged
print(i, x)  # Shows that they are unaffected

# More explanation
i = 1
x = 0

def a_function(y):
    """Increments x from 0 to y and returns its value."""
    x = 0
    for i in range(y):
        x += 1
    return x

# Display current variable states
print(globals())  # Can see global variables and functions

# To update x:
x = a_function(10)  # Assigns the result of the function to x
print(x)

# Local vs global variables
_a_global = 10  # A global variable

if _a_global >= 5:
    _b_global = _a_global + 5  # Also a global variable

print("Before calling a_function, outside the function, the value of _a_global is", _a_global)
print("Before calling a_function, outside the function, the value of _b_global is", _b_global)

def a_function():
    """Demonstrates local variable behavior within a function."""
    _a_global = 4  # A local variable

    if _a_global >= 4:
        _b_global = _a_global + 5  # Also a local variable

    _a_local = 3  # Local variable

    print("Inside the function, the value of _a_global is", _a_global)
    print("Inside the function, the value of _b_global is", _b_global)
    print("Inside the function, the value of _a_local is", _a_local)

a_function()

print("After calling a_function, outside the function, the value of _a_global is (still)", _a_global)
# _a_local remains inside the function

# Global variables are available within functions
_a_global = 10

def a_function():
    """Demonstrates accessing a global variable from within a function."""
    _a_local = 4
    
    print("Inside the function, _a_local is", _a_local)
    print("Inside the function, _a_global is", _a_global)

a_function()
print("Outside the function, _a_global is", _a_global)

# Modifying global variables from inside a function using 'global' keyword
_a_global = 10

print("Before calling a_function, outside function, value of _a_global is", _a_global)

def a_function():
    """Modifies the global variable _a_global and creates a local variable."""
    global _a_global  # Declare _a_global as global
    _a_global = 5
    _a_local = 4

    print("Inside the function, _a_global is", _a_global)
    print("Inside the function, _a_local is", _a_local)

a_function()
print("After calling a_function, outside function, _a_global is", _a_global)

# Using global inside nested functions
def a_function():
    """Demonstrates global variable access within nested functions."""
    _a_global = 10

    def a_function2():
        global _a_global  # Access the global _a_global
        _a_global = 20

    print("Before calling a_function2, within a_function, _a_global is", _a_global)
    
    a_function2()

    print("After calling a_function2, within a_function, _a_global is", _a_global)

a_function()
print("a_global in main workspace / namespace now is", _a_global)

# Swapping lines to define the global variable outside the a_function
_a_global = 10

def a_function():
    """Demonstrates global variable access within nested functions."""
    def a_function2():
        global _a_global
        _a_global = 20

    print("Before calling a_function2, within a_function, _a_global is", _a_global)
    
    a_function2()

    print("After calling a_function2, within a_function, _a_global is", _a_global)

a_function()
print("a_global in main workspace / namespace now is", _a_global)