# Peng TIAN, 5354870, pt882
# luckytianpeng@hohtmail.com, pt882@uowmail.edu.au
#
# CSCI926 Software Testing and Analysis
# Group project - simulation testing tool for ADAS, automated, and autonomous driving systems

# Traffic Signs with new signs


setwd("~/GitHub/UOW-CSCI926-Autumn-2020")


df <- read.csv("output_new_signs.csv")

head(df)
summary(df)

df.oldclass.levels <- levels(as.factor(df$oldclass))
length(df.oldclass.levels)
df.oldclass.levels

df.signname.levels <- levels(as.factor(df$signname))
length(df.signname.levels)
df.signname.levels

df.newclass.levels <- levels(as.factor(df$newclass))
length(df.newclass.levels)
df.newclass.levels

df[df$signname == df$newclass]

df_sign_class <- data.frame(matrix(ncol=3, nrow = 0))
colnames(df_sign_class) <- c("sign", "class", "freq")

for (i in 1:length(df.signname.levels)) {
    sign <- df.signname.levels[i]
    
    sub <- df[df$signname == sign, ]
    
    classes <- as.data.frame(table(sub$newclass))
    classes$Var1 <- as.character(classes$Var1)

    for (r in 1:nrow(classes)) {
      df_sign_class[nrow(df_sign_class)+1, ] =
        c(sign, classes[r, ]$Var1, classes[r, ]$Freq)
    }
}

df_sign_class
