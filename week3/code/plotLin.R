### Mathematical display
x <- seq(0, 100, by = 0.1)
y <- -4. + 0.25 * x +
    rnorm(length(x), mean = 0., sd = 2.5) # randos



# put them in a df
my_data <- data.frame(x = x, y = y)

head(my_data)

# perform a linear regression
my_lm <- summary(lm(y ~ x, data = my_data))

my_lm # understanding this summary is key to understanding the rest of the code

# plot the data
p <- ggplot(my_data, aes(x = x, y = y,
                        colour = abs(my_lm$residual))
                ) +
        geom_point() +
        scale_colour_gradient(low = "black", high = "red") +
        theme(legend.position = "none") +
        scale_x_continuous(
            expression(alpha^2 * pi / beta * sqrt(Theta)))

# add the regression line
p <- p + geom_abline(
    intercept = my_lm$coefficients[1][1],
    slope = my_lm$coefficients[2][1],
    colour = "red")

# throw some math on the plot
p <- p + geom_text(aes(x = 60, y = 0,
                       label = "sqrt(alpha) * 2* pi"), 
                       parse = TRUE, size = 6, 
                       colour = "blue")

pdf("../results/MyLinReg.pdf")
print(p)
dev.off()