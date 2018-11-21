# Caricamento librerie ----------------------------------------------------

library(tidyverse)
library(magrittr)
library(rvest)


# Acquisizione dati da tabella html ---------------------------------------

pivot_df <- 'https://it.wikipedia.org/wiki/Leone_d%27oro_al_miglior_film' %>%
  read_html() %>% #parsing html
  html_node(".wikitable") %>% 
  html_table(fill=T) %>% 
  filter(!str_detect(string = Film, pattern = 'non [venne||fu]')) %>% #filtro per escludere anni senza premiazioni
  rename(Paese=Nazione) %T>% # Scrivi CSV e continua oltre
  write_csv(path = "R/Winners.csv") %>%
  separate_rows(Paese, sep = "/\\s?") %>% #split righe con più paesi per "/" e spazio
  count(Paese, sort = T) %>% #Conteggio e sort
  rename(Vincitori = n) %T>%
  write_csv(path = "R/Countries.csv")

# Creazione grafico a barre -----------------------------------------------

g <- ggplot(data = pivot_df,
            aes(x = reorder(Paese,Vincitori), y = Vincitori)) +
  geom_bar(stat='identity') +
  labs(x= "Paese vincitore",
       y="Numero di vittorie",
       title="Vincitori per paese d'origine",
       caption= "Fonte: Wikipedia") +
  scale_y_continuous(breaks = pivot_df %$% Vincitori %>% unique) +
  coord_flip() +
  theme_minimal() +
  theme(panel.grid.major.x = element_line(linetype = "dotted", colour = "darkgrey"),
        panel.grid.major.y = element_blank(),
        panel.grid.minor = element_blank())

# Salvataggio grafico in png ----------------------------------------------

ggsave(plot = g, filename = "R/plot.png", device = "png")