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

#### PLOT ####
ggplot(df,aes(x=ymd_hms(date),y=0, col= "black", label=event)) +
  labs(col="Events")+theme_classic()+scale_x_datetime(expand = expansion(mult = 0.2)) +
  geom_hline(yintercept=0,color = "black", size=0.3) +
  geom_segment(data=df[df$month_count == 1,], aes(y=position,yend=0,xend=date), color='black', size=0.2) +
  theme(#axis.line.y=element_blank(),
    axis.text.y=element_blank(),
    axis.title.x=element_blank(),
    axis.title.y=element_blank(),
    axis.ticks.y=element_blank(),
    #axis.text.x =element_blank(),
    #axis.ticks.x =element_blank(),
    #axis.line.x =element_blank(),
    legend.position = "none"
  ) +
  geom_text(aes(y=text_position,label=event),size=5)

#### PLOT DEBUGGING ####

#### PLOT ####
timeline_plot<-ggplot(df,aes(x=ymd_hms(date),y=0, col= "black", label=event))
timeline_plot<-timeline_plot+labs(col="Events") 
timeline_plot<-timeline_plot+theme_classic() + scale_x_datetime(expand = expansion(mult = 0.2), labels = date_format("%Y-%m-%d %H:%M:%S"))
print(timeline_plot)

# Plot horizontal black line for timeline
timeline_plot<-timeline_plot+geom_hline(yintercept=0,color = "black", size=0.3)
print(timeline_plot)

# Plot vertical segment lines for events
timeline_plot<-timeline_plot+geom_segment(data=df[df$month_count == 1,], aes(y=position,yend=0,xend=date), color='black', size=0.2)
print(timeline_plot)

# Don't show axes, appropriately position legend
timeline_plot<-timeline_plot+theme(#axis.line.y=element_blank(),
  axis.text.y=element_blank(),
  axis.title.x=element_blank(),
  axis.title.y=element_blank(),
  axis.ticks.y=element_blank(),
  axis.text.x=element_text(angle = 45, vjust = 0.5, hjust=1),
  #axis.ticks.x =element_blank(),
  #axis.line.x =element_blank(),
  legend.position = "none"
)
print(timeline_plot)

# Show text for each event
timeline_plot<-timeline_plot+geom_text(aes(y=text_position,label=event),size=5)
print(timeline_plot)

