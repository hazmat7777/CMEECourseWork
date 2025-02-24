rm(list = ls())

# create 3 datasets with different variances- 1, 10, 100
y1<-rnorm(10, mean = 0, sd = sqrt(1))
var(y1)
y2 <- rnorm(10, mean = 0, sd = sqrt(10))
var(y2)
y3<-rnorm(10, mean = 0, sd = sqrt(100))
var(y3)

# create x variable for plotting
x <- rep(0,10)

# plot
par(mfrow = c(1,3))
plot(x, y1, xlim=c(-0.1,0.1), ylim=c(-12,12), pch=19, cex=0.8, col = "red")
abline(v=0)
abline(h=0)
plot(x, y2, xlim=c(-0.1,0.1), ylim=c(-12,12), pch=19, cex=0.8, col="blue")
abline(v=0)
abline(h=0)
plot(x, y3, xlim=c(-0.1,0.1), ylim=c(-12,12), pch=19, cex=0.8,, col= 2)
abline(v=0)
abline(h=0)

# now draw the squares of differences to illustrate
#?polygon()
par(mfrow = c(1,3))
plot(x, y1, xlim=c(-12,12), ylim=c(-12,12) ,pch=19, cex=0.8, col="red")
abline(v=0)
abline(h=0)
for (i in 1: length(y1)) {
    polygon(x=c(0,0,y1[i],y1[i]),y=c(0,y1[i],y1[i],0), col=rgb(1, 0, 0, 0.2))
}

plot(x, y2, xlim=c(-12,12), ylim=c(-12,12), pch=19, cex=0.8, col="blue")
abline(v=0)
abline(h=0)
for (i in 1:length(y2)) {
polygon(x=c(0,0,y2[i],y2[i]),y=c(0,y2[i],y2[i],0), col=rgb(0, 0, 1,0.2))
}
plot(x, y3, xlim=c(-12,12), ylim=c(-12,12), pch=19, cex=0.8,, col="darkgreen"
)
abline(v=0)
abline(h=0)
for (i in 1:length(y3)) {
polygon(x=c(0,0,y3[i],y3[i]),y=c(0,y3[i],y3[i],0), col=rgb(0, 1, 0,0.2))
}


## covariance
dev.off()

rm(list = ls())
par(mfrow = c(1, 3))
x<-c(-10:10)
var(x) ## [1] 38.5

y1<-x*1 + rnorm(21, mean=0, sd=sqrt(1)) # y = mx + b + noise

cov(x, y1) ## [1] 39.42318

plot(x, y1, xlim=c(-10,10), ylim=c(-20, 20), col="red", pch=19, cex=0.8, main
=paste("Cov=",round(cov(x,y1),digits=2)))

y2<-rnorm(21, mean=0, sd=sqrt(1)) # Here, there is no association

cov(x, y2) ## [1] 1.572258

plot(x, y2, xlim=c(-10,10), ylim=c(-20, 20), col="blue", pch=19, cex=0.8,
main=paste("Cov=",round(cov(x,y2),digits=2)))

y3 <- x* (-1) +rnorm(21, mean=0, sd=sqrt(1)) # Here, the association is negative

cov(x, y3) ## [1] -34.6899

plot(x, y3, xlim=c(-10,10), ylim=c(-20, 20), col="darkgreen", pch=19, cex=0.8,
main=paste("Cov=",round(cov(x,y3),digits=2)))

# introducing less variation
rm(list = ls())

par(mfrow = c(1, 3))
x<-c(-10:10)
var(x) ## [1] 38.5

y1<-x*0.1 + rnorm(21, mean=0, sd=sqrt(1)) # here the association is weak but not 0:
cov(x, y1) ## [1] 1.221025
plot(x, y1, xlim=c(-10,10), ylim=c(-20, 20), col="red", pch=19, cex=0.8, 
main=paste("Cov=",round(cov(x,y1),digits=2)))

y2<-x*0.5+ rnorm(21, mean=0, sd=sqrt(1))
cov(x, y2) ## [1] 20.53452
plot(x, y2, xlim=c(-10,10), ylim=c(-20, 20), col="blue", pch=19, cex=0.8,
main=paste("Cov=",round(cov(x,y2),digits=2)))

y3<- x*2 +rnorm(21, mean=0, sd=sqrt(1)) 
cov(x, y3) ## [1] 77.61198
plot(x, y3, xlim=c(-10,10), ylim=c(-20, 20), col="darkgreen", pch=19, cex=0.8,
main=paste("Cov=",round(cov(x,y3),digits=2)))
