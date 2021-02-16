install.packages("utf8")
install.packages("wbstats")

help("plot")
  ?na.omit()
#cosas por hacer
x <- na.omit(Gasto_educ_2000$SE.XPD.TOTL.GD.ZS)
y <- na.omit(Desigualdad$SI.POV.GINI)
cor(x, y)