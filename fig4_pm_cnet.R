## An R-version to analyze incorporation of C and N
library("ggplot2")
library(ggforce)
library("dplyr")
# detach(package:plyr)
library("ggbreak")


get_cnet_df_stat <- function(fileloc='data/SIP_all.csv'){
  df <- read.csv(file='data/SIP_all.csv')
  df_stat <- df[df$isotope=='c',] %>%
    group_by(treatment, distance) %>%
    summarize(q25 = quantile(value, probs = 0.25), 
              q50 = quantile(value, probs = 0.5),
              q75 = quantile(value, probs = 0.75))
  
  return(df_stat)
}

df_stat <- get_cnet_df_stat()
write.csv(df_stat, 'data/SIP_cnet_summary.csv', row.names=FALSE)


# draw figures
df_vis <- df[(df$isotope=='c')&(df$distance=='outer'),]
df_vis_stat <- df_vis %>%
  group_by(treatment) %>%
  summarize(q25 = quantile(value, probs = 0.25), 
            q50 = quantile(value, probs = 0.5),
            q75 = quantile(value, probs = 0.75))

ggplot() +
  geom_sina(data = df_vis, 
            aes(x=treatment, y=value, color=treatment), 
            maxwidth = 0.5, 
            alpha=0.3, 
            size=1) +
  geom_errorbar(data=df_vis_stat, 
                aes(x=treatment, ymin=q25, ymax=q75),
                width = 0.15, color='black', size=0.4) + 
  geom_errorbar(data=df_vis_stat, 
                aes(x=treatment, ymin=q50, ymax=q50),
                width = 0.3, color='black', size=0.8) + 
  labs(x = "Isolate in inner", y = "Incorporation by net") +
  ylim(NA, 0.24) +
  scale_y_continuous(breaks = append(seq(0, 0.09, 0.03), seq(0.10, 0.25, 0.1))) +
  scale_y_break(c(0.09, 0.10), scales=0.2) +
  scale_color_manual(values=c("#E06666","#5E7BFB","#1a6b3b","#878787")) +  
    # Alcani, Devosi, Marino, none
  theme(strip.background = element_rect(fill=NA),
        panel.background = element_rect(fill = "transparent", color = NA),
        panel.grid.major = element_blank(),
        panel.grid.minor = element_blank(),
        plot.background = element_rect(fill = "transparent", color = NA),
        panel.border = element_rect(colour = "black", fill=NA, size=0.5),
        legend.position = "none",
        axis.text.y.right = element_blank(),
        axis.ticks.y.right = element_blank(),
        axis.line.y.right = element_blank()
        )

ggsave("figures/SIP_cnet_day14_outer_break.pdf", width = 3, height = 4)
ggsave("figures/SIP_cnet_day14_inner_break.pdf", width = 3, height = 4)


# statistical test
kruskal.test(value ~ treatment, data = df_vis)
pairwise.wilcox.test(df_vis$value, df_vis$treatment, p.adjust.method = "BH")

print(
  cat(
    'Alcanivorax:', (df_vis_stat$q50[1]-df_vis_stat$q50[4]) / df_vis_stat$q50[4], 
    '\n',
    'Devosia:', (df_vis_stat$q50[2]-df_vis_stat$q50[4]) / df_vis_stat$q50[4], 
    '\n',
    'Marinobacter:', (df_vis_stat$q50[3]-df_vis_stat$q50[4]) / df_vis_stat$q50[4],
    '\n'
    )
  )