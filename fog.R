# Peng TIAN, 5354870, pt882
# luckytianpeng@hohtmail.com, pt882@uowmail.edu.au
#
# CSCI926 Software Testing and Analysis
# Group project - simulation testing tool for ADAS, automated, and autonomous driving systems

# Traffic Signs with different fog


setwd("~/GitHub/UOW-CSCI926-Autumn-2020")

# install.packages("plyr")
library(plyr)

source("utilities.R")


# density of fog
FOG_MIN <- 0.05
FOG_MAX <- 0.25
FOG_STEP <- 0.05

seq(FOG_MIN, FOG_MAX, FOG_STEP)

df_t <- read.csv("output_thresh.csv")
head(df_t)

df_t <- df_t[which(0.4 == df_t$thresh), ]
df_t$fog <- 0.0
head(df_t)

df_f <- read.csv("output_fog.csv")
head(df_f)

df <- rbind(df_t, df_f)
df$fog <- as.numeric(df$fog)

levels(as.factor(df$fog))

df.fog.freq <- count(df$fog)
df.fog.freq
plot(df.fog.freq, xlab="density of fog", ylab="number of signs")
lines(df.fog.freq)


# 1. space:

# overlap areas:

df[c("overlap")] <- FALSE
head(df)

for (r in 1:nrow(df)) {
  # sub datafram - same thresh, video, frame
  sub <- df[which(  (df$fog == df$fog[r])
                    & (df$video == df$video[r])
                    & (df$frame == df$frame[r])
                    & (! df$overlap[r])
                    & (  df$x != df$x[r]
                         | df$y != df$y[r]
                         | df$w != df$w[r]
                         | df$h != df$h[r])), ]
  
  # check every area
  if (1 <= nrow(sub)) {
    for (rr in 1:nrow(sub)) {
      if (is_overlapping(df$x[r], df$y[r], df$w[r], df$h[r],
                         sub$x[rr], sub$y[rr], sub$w[rr], sub$h[rr])) {
        df$overlap[r] = TRUE
      }
    }
  }
}

write.csv(df, "output_fog_overlap.csv")

df.overlap.freq <- count(df[df$overlap, ]$fog)
df.overlap.freq
plot(df.overlap.freq, xlab="density of fog", ylab="number of overlapping areas")
lines(df.overlap.freq)


# 2. time sequence:

sequence <- data.frame(matrix(ncol=6, nrow = 0))
colnames(sequence) <- c("fog", "video",
                          "first_frame", "last_frame",
                          "omission", "class_number")

WINDOW_LENGTH_MIN = 15
WINDOW_BREAK_LEGTH_MAX = 4  ## unit: frame
X_MOMENTUM_MAX = 20         ## unit: pixel
Y_MOMENTUM_MAX = 20         ## unit: pixel

row_no = nrow(df)

win_frame_h = 1  ## head
win_frame_t = 2  ## tail
while (win_frame_h <= row_no & win_frame_t <= row_no) {
  omission = 0  ## break point in sequence
  
  while (     (win_frame_t <= row_no)
            & (df$fog[win_frame_t] == df$fog[win_frame_h])
            & (df$video[win_frame_t] == df$video[win_frame_h])
            & (   WINDOW_BREAK_LEGTH_MAX
                  >= df$frame[win_frame_t] - df$frame[win_frame_t - 1] - 1)
            & (X_MOMENTUM_MAX >= df$x[win_frame_t] - df$x[win_frame_t - 1])
            & (Y_MOMENTUM_MAX >= df$y[win_frame_t] - df$y[win_frame_t - 1])) {
    
    # still in a sequence
    
    if (df$frame[win_frame_t] > df$frame[win_frame_t - 1] + 1) {
      # in a sequence, we assume it should be the same sign, but was not recognized
      omission = omission + (df$frame[win_frame_t] - df$frame[win_frame_t - 1] - 1)
    }  
    
    # expand the sequence
    win_frame_t = win_frame_t + 1
  }
  
  
  if (  (df[win_frame_t, ]$fog == df[win_frame_h, ]$fog)
        & (df[win_frame_t, ]$video == df[win_frame_h, ]$video)
        & (WINDOW_LENGTH_MIN <= win_frame_t - win_frame_h)) {
    
    # find a sequence
    
    sub <- (df[win_frame_h:(win_frame_t-1), ])
    
    sequence[nrow(sequence) + 1,] =
      c(df[win_frame_h, ]$fog,
        df[win_frame_h, ]$video,
        df[win_frame_h,]$frame,
        df[win_frame_t-1,]$frame,
        omission,
        length(levels(as.factor(sub$class))))
  }
  
  win_frame_h = win_frame_t
  win_frame_t = win_frame_t + 1
}

sequence$fog <- as.numeric(sequence$fog)
sequence$first_frame <- as.numeric(sequence$first_frame)
sequence$last_frame <- as.numeric(sequence$last_frame)
sequence$omission <- as.numeric(sequence$omission)

sequence

sequence.fog.freq <- count(sequence$fog)
sequence.fog.freq
plot(sequence.fog.freq, xlab="density of fog", ylab="number of sequences")
lines(sequence.fog.freq)
