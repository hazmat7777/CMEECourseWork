"""Defining and testing simple arithmetic functions."""

####################
def hello_1(x):
    """Returns 'hello' for every multiple of 3 below x."""
    for j in range(x):
        if j% 3 == 0:
            print('hello')
    print (' ')

hello_1(12)

#prints hello for every integer between 0-11 where the number is divisible by 3 with no remainder

########################
def hello_2(x):
    """Returns 'hello' for every integer below x which is:
        a) 3 above a multiple of 5
        b) 3 above a multiple of 4."""
    for j in range(x):
        if j % 5 == 3:
            print('hello')
        elif j % 4 == 3:
            print('hello')
    print(' ')

hello_2(12)

def hello_3(x, y):
    """Prints 'hello' for each integer from x to y (exclusive)."""
    for i in range(x, y):
        print('hello')
    print('')

hello_3(3, 17)

#############################

def hello_4(x):
    """Prints 'hello' repeatedly, increasing x by 3, until x equals 15."""
    while x != 15:
        print('hello')
        x = x + 3
    print('')  # Prints a blank line after the loop is completed

hello_4(0)

#############################

def hello_5(x):
    """Prints 'hello' or 'hello!' based on specific conditions until x reaches 100."""
    while x < 100:
        if x == 31:
            for k in range(7):
                print('hello')
        elif x == 18:
            print('hello!')
        x = x + 1
    print('')

hello_5(12)

############################

# WHILE loop with BREAK

def hello_6(x, y):
    """Prints 'hello!' followed by y, incrementing y until it reaches 6."""
    while x:  # While x is True
        print("hello! " + str(y))
        y += 1  # Increment y by 1
        if y == 6:
            break
    print('')

hello_6(True, 0)
