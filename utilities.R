# Peng TIAN, 5354870, pt882
# luckytianpeng@hohtmail.com, pt882@uowmail.edu.au
#
# CSCI926 Software Testing and Analysis
# Group project - simulation testing tool for ADAS, automated, and autonomous driving systems

# utilities


# Are tow rectangles overlapping?
#
#               w
# (x,y) --> +--------+
#           |        | h
#           |        |
#           +--------+
#
is_overlapping <- function(x1, y1, w1, h1, x2, y2, w2, h2) {
  if ((x1 < x2 & x1 + w1 < x2) | (y1 < y2 & y1 + h1 < y2)) {
    return (FALSE)
  } else {
    return (TRUE)
  }
}
