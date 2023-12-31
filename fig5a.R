## Combines count and Cnet data in one plot (day 14)
library("dplyr")
library(ggplot2)
library(scales)

# import data
count_bact <- read.csv("data/flow2_day14_bact.csv")
count_pt <- read.csv("data/flow2_day14_pt.csv")
cnet_stat <- read.csv("data/SIP_cnet_summary.csv")

# get statistics from count data
count_bact_stat <- count_bact %>%
  group_by(Treatment, Ring) %>%
  summarize(mean = mean(Abundance), 
            sd = sd(Abundance))

# merbe count and cnet in to df
count_bact_stat$Ring[count_bact_stat$Ring==1] <- 'inner'
count_bact_stat$Ring[count_bact_stat$Ring==2] <- 'outer'
df <- cnet_stat
colnames(df) <- c("treatment", "ring", "cnet_q25", "cnet_q50", "cnet_q75")
df$count_mean <- NA
df$count_sd <- NA

for (row in 1:nrow(df)){
  t <- df$treatment[row]
  r <- df$ring[row]
  df[row, 'count_mean'] <- count_bact_stat$mean[count_bact_stat$Treatment==t & count_bact_stat$Ring==r]
  df[row, 'count_sd'] <- count_bact_stat$sd[count_bact_stat$Treatment==t & count_bact_stat$Ring==r]
}


# plot
setEPS()
postscript("figures/fig5a.eps", width = 1.8, height = 1.3)

ggplot(df, aes(x=cnet_q50, y=count_mean, shape=ring, colour=treatment)) + 
  geom_point(size=1.7, stroke=0.3) + 
  geom_errorbar(aes(ymax = count_mean+count_sd, ymin = count_mean-count_sd), width=0.02, linewidth=0.2) + 
  geom_errorbarh(aes(xmax = cnet_q75, xmin = cnet_q25), height=0.02, linewidth=0.2) + 
  # scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
  #               labels = trans_format("log10", math_format(10^.x))) +
  scale_x_continuous(trans='log10', breaks=c(0.1)) +
  scale_y_continuous(trans='log10', breaks=c(10^6, 10^7)) +
  annotation_logticks(short = unit(0.1, "cm"),
                      mid = unit(0.1, "cm"),
                      long = unit(0.2, "cm"),
                      size = 0.1) +
  scale_color_manual(values=c("#C00000", "#0432FF", "#AB7942", "#000000")) +
  # scale_fill_manual(values=c("#FFDFE1", "#D2DCFB", "#F8DFC4", "#D1D3D4")) +
    # Alcani, Devosi, Marino, none
  scale_shape_manual(values = c(16,1)) +  # Inner, outer
  theme(strip.background = element_rect(fill=NA),
        panel.background = element_rect(fill = "transparent", color = NA),
        panel.grid.major = element_blank(),
        # panel.grid.minor = element_line(colour = "grey80", linewidth=0.2),
        plot.background = element_rect(fill = "transparent", color = NA),
        panel.border = element_blank(),
        legend.position = "None",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        axis.text.x = element_blank(),
        axis.text.y = element_blank(),
        axis.line = element_line(size = 0.15),
        axis.ticks = element_blank()
        )

dev.off()


# plot for each ring
df_sub <- df[df$ring=='outer',]

setEPS()
postscript("figures/fig5a_outer_inset.eps", width = 3.2, height = 1)

ggplot(df_sub, aes(x=cnet_q50, y=count_mean, shape=ring, colour=treatment)) + 
  geom_point(size=1.7, stroke=0.3) + 
  geom_errorbar(aes(ymax = count_mean+count_sd, ymin = count_mean-count_sd), width=0.001, linewidth=0.2) + 
  geom_errorbarh(aes(xmax = cnet_q75, xmin = cnet_q25), height=3e5, linewidth=0.2) + 
  # scale_x_log10(breaks = trans_breaks("log10", function(x) 10^x),
  #               labels = trans_format("log10", math_format(10^.x))) +
  # scale_x_continuous(
  #   limits = c(0.02, 0.04),
    # trans='log10',
    # breaks=seq(0.02, 0.04, 0.01)
  #   ) +
  # scale_y_continuous(limits = c(0, 12e6)
                     # trans='log10',
                     # breaks=c(10^6, 10^7)
                     # ) +
  # annotation_logticks(short = unit(0.1, "cm"),
  #                     mid = unit(0.1, "cm"),
  #                     long = unit(0.2, "cm"),
  #                     size = 0.3) +
  scale_color_manual(values=c("#C00000", "#0432FF", "#AB7942", "#000000")) +
  # scale_fill_manual(values=c("#FFDFE1", "#D2DCFB", "#F8DFC4", "#D1D3D4")) +
    # Alcani, Devosi, Marino, none
  scale_shape_manual(values = c(1)) +  # Inner (16), outer (1)
  theme(strip.background = element_rect(fill=NA),
        panel.background = element_rect(fill = "transparent", color = NA),
        panel.grid.major = element_blank(),
        # panel.grid.minor = element_line(colour = "grey80", linewidth=0.2),
        plot.background = element_rect(fill = "transparent", color = NA),
        panel.border = element_blank(),
        legend.position = "None",
        axis.title.x = element_blank(),
        axis.title.y = element_blank(),
        # axis.text.x = element_blank(),
        # axis.text.y = element_blank(),
        axis.line = element_line(size = 0.15)
        # axis.ticks = element_blank()
  )

dev.off()