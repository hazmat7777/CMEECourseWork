## simple linear functions

rm(list=ls())

# indexing practice
x<-seq(from = -5, to = 5, by = 1)

i <- 1
x[i]

i<- seq(0,10,1)
x[i[2]]

a<-2
b<-1
y<-a+b*x
plot(x,y)
segments(0,-10,0,10, lty=3) # add cartesian axes
segments(-10,0,10,0,lty=3) # lty = line type. 3 = dotted

abline(a = 2, b = 1) # add the lobf

points(4,0, col="red", pch=19)
points(-2,6, col="green", pch=9)
points(x,y, pch=c(1,2,3,4,5,6,7,8,9,10,11)) # point character- choose some randos

# quadratic function
dev.off()

x<-seq(from = -5, to = 5, by = 0.1)
a<- -2
y<-a+x^2
plot(x,y)
segments(0,-30,0,30, lty=3)
segments(-30,0,30,0,lty=3)

plot(x,y)
a <- -2
b <-3
y <-a+b*x^2
points(x,y, pch=19, col="red")
segments(0,-30,0,30, lty=3)
segments(-30,0,30,0,lty=3)

plot(x,y)
a<- -2
b1<- 10
b2<-3
y<-a+b1*x+b2*x^2 # moves the whole line
points(x,y, pch=19, col="green")
segments(0,-100,0,100, lty=3)
segments(-100,0,100,0,lty=3)


## Exercises
#1
    # 12kg

#2
    # 80

#3
x<-seq(from = 0, to = 20, by = 1)
y = -1+ 2*x-0.15*x^2 

dev.off()
plot(x,y)
    # differentiated this
    # turning point at x = 6.66, y = 5.66

max(y) #  bad method as depends on resolution of my x sequence

#4
dev.off()
y = -0.08*x^2 + 2*x -1
plot(x, y)





