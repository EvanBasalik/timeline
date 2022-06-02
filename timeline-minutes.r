##original code from https://benalexkeen.com/creating-a-timeline-graphic-using-r-and-ggplot2/

library(ggplot2)
library(scales)
library(lubridate)
library(stringr)
library(readxl) 
library(M3)

#read the files
#df <- read.csv('timeline-r-2.csv')
df <- read_excel('inputxls.xlsx')
df

#df$date <- with(df, ymd_hms(df$Date))
df <- df[with(df, order(Date)), ]
df$date <- df$Date
head(df)

#order the data so it plots in time order
positions <- c(0.5, -0.5, 1.0, -1.0, 1.5, -1.5)
directions <- c(1, -1)

#wrap any events that are long
#also, rename EventData -> event to be as consistent as possible with old CSV approach
df$event<-str_wrap(df$EventData, width = 20, indent = 0, exdent = 0)
head(df)

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

#adjust the vertical height to account for wraps
df$wrap_count <- str_count(df$event, "\n")
for(i in 1:length(df$wrap_count)) {       
  if(df$wrap_count[i] > 0 && df$direction >0) {
    df$wrap_count[i] <- df$wrap_count[i]+2
  }
}
head(df)

df$minute_count <-ave(floor_date(df$date, unit = "minutes")==floor_date(df$date, unit = "minutes"), floor_date(df$date, unit = "minutes"), FUN=cumsum)
df$text_position <- (df$minute_count * text_offset * df$direction) + df$position + (df$wrap_count*text_offset*df$direction)
head(df)

#### PLOT ####
ggplot(df,aes(x=ymd_hms(date),y=0, col= "black", label=event)) +
  labs(col="Events")+theme_classic()+scale_x_datetime(expand = expansion(mult = 0.2), labels = date_format("%m-%d %H:%M"), breaks = c(df$date)) +
  scale_y_continuous(breaks = NULL) + #remove y-axis gridlines
  geom_hline(yintercept=0,color = "black", size=0.1) +
  geom_segment(data=df[df$minute_count == 1,], aes(y=position,yend=0,xend=date), color='black', size=1) +
  theme(  
    #axis.line.y=element_blank(),
    axis.text.y=element_blank(),
    axis.title.x=element_blank(),
    axis.title.y=element_blank(),
    axis.ticks.y=element_blank(),
    axis.text.x=element_text(angle = 45, vjust = 0.5, hjust=.5, size = 10),
    axis.ticks.length = unit(.25, "cm"),
    #axis.ticks.x =element_blank(),
    #axis.line.x =element_blank(),
    legend.position = "none"
  ) +
  geom_label(aes(y=text_position,label=event),size=5, colour="black")

#### PLOT DEBUGGING ####

# #### PLOT ####
# timeline_plot<-ggplot(df,aes(x=date,y=0, col= "black", label=event))
# timeline_plot<-timeline_plot+labs(col="Events") 
# timeline_plot<-timeline_plot+theme_classic() + scale_x_datetime(expand = expansion(mult = 0.2), labels = date_format("%Y-%m-%d %H:%M"), breaks = c(df$date))
# timeline_plot<-timeline_plot + scale_y_continuous(breaks = NULL) #remove y-axis gridlines
# print(timeline_plot)
# 
# # Plot horizontal black line for timeline
# timeline_plot<-timeline_plot+geom_hline(yintercept=0,color = "black", size=0.1)
# print(timeline_plot)
# 
# # Plot vertical segment lines for events
# timeline_plot<-timeline_plot+geom_segment(data=df[df$minute_count == 1,], aes(y=position,yend=0,xend=date), color='black', size=1)
# print(timeline_plot)
# 
# # Don't show axes, appropriately position legend
# timeline_plot<-timeline_plot+theme(
#   #axis.line.y=element_blank(),
#   axis.text.y=element_blank(),
#   axis.title.x=element_blank(),
#   axis.title.y=element_blank(),
#   axis.ticks.y=element_blank(),
#   axis.text.x=element_text(angle = 45, vjust = 0.5, hjust=.5),
#   axis.ticks.length = unit(.25, "cm"),
#   #axis.ticks.x =element_blank(),
#   #axis.line.x =element_blank(),
#   legend.position = "none"
# )
# print(timeline_plot)
# 
# # Show text for each event
# timeline_plot<-timeline_plot+geom_label(aes(y=text_position,label=event),size=5, colour="black")
# print(timeline_plot)

