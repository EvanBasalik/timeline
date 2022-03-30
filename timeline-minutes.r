##original code from https://benalexkeen.com/creating-a-timeline-graphic-using-r-and-ggplot2/

library(ggplot2)
library(scales)
library(lubridate)

#read the files
df <- read.csv('timeline-r-2.csv')
df

# create a new column with actual date
df$date <- with(df, ymd_hms(df$inputdate))
df <- df[with(df, order(date)), ]
head(df)

#apply colors to the status
#status_levels <- c("Complete", "On Target", "At Risk", "Critical")
#status_colors <- c("#0070C0", "#00B050", "#FFC000", "#C00000")
#df$status <- factor(df$status, levels=status_levels, ordered=TRUE)

#order the data so it plots in time order
positions <- c(0.5, -0.5, 1.0, -1.0, 1.5, -1.5)
directions <- c(1, -1)

line_pos <- data.frame(
  "date"=unique(df$date),
  "position"=rep(positions, length.out=length(unique(df$date))),
  "direction"=rep(directions, length.out=length(unique(df$date)))
)

df <- merge(x=df, y=line_pos, by="date", all = TRUE)
df <- df[with(df, order(date)), ]
head(df)

#start calculating plotted points
text_offset <- 0.05

df$month_count <- ave(df$date==df$date, df$date, FUN=cumsum)
df$text_position <- (df$month_count * text_offset * df$direction) + df$position
head(df)

#set up the x-axis
#first part is the months to show
month_buffer <- 2

month_date_range <- seq(min(df$date) - months(month_buffer), max(df$date) + months(month_buffer), by='month')
head(month_date_range)
month_format <- format(month_date_range, '%b')
month_df <- data.frame(month_date_range, month_format)
head(month_df)

#### PLOT ####

timeline_plot<-ggplot(df,aes(x=date,y=0, col= "black", label=milestone))
timeline_plot<-timeline_plot+labs(col="Milestones")
#timeline_plot<-timeline_plot+scale_color_manual(values=status_colors, labels=status_levels, drop = FALSE)
timeline_plot<-timeline_plot+theme_classic()
print(timeline_plot)

# Plot horizontal black line for timeline
timeline_plot<-timeline_plot+geom_hline(yintercept=0,color = "black", size=0.3)
print(timeline_plot)

# Plot vertical segment lines for milestones
timeline_plot<-timeline_plot+geom_segment(data=df[df$month_count == 1,], aes(y=position,yend=0,xend=date), color='black', size=0.2)
print(timeline_plot)

# Plot scatter points at zero and date
timeline_plot<-timeline_plot+geom_point(aes(y=0), size=3)
print(timeline_plot)

# Don't show axes, appropriately position legend
timeline_plot<-timeline_plot+theme(axis.line.y=element_blank(),
                                   axis.text.y=element_blank(),
                                   axis.title.x=element_blank(),
                                   axis.title.y=element_blank(),
                                   axis.ticks.y=element_blank(),
                                   axis.text.x =element_blank(),
                                   axis.ticks.x =element_blank(),
                                   axis.line.x =element_blank(),
                                   legend.position = "bottom"
)
print(timeline_plot)

# Show text for each month
timeline_plot<-timeline_plot+geom_text(data=month_df, aes(x=month_date_range,y=-0.1,label=month_format),size=2.5,vjust=0.5, color='black', angle=90)
print(timeline_plot)

# Show text for each milestone
timeline_plot<-timeline_plot+geom_text(aes(y=text_position,label=milestone),size=2.5)
print(timeline_plot)

