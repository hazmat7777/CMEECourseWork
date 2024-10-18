def buggyfunc(x):
    y = x
    for i in range(x):
        try:           #if an error happens, transfer control to the except block
            y = y-1
            z = x/y
        except ZeroDivisionError: #catches a specific type of error
            print(f"The result of dividing a number by zero is undefined")
        except:
            print(f"This didn't work; {x= }; {y = }") #indicates state of variables during an error
        else:
            print(f"OK; {x = }; {y = }, {z = };")
        finally:
            print("This section will always run")
    return z

buggyfunc(20)