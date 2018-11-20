

# Caricamento librerie ----------------------------------------------------

library(tidyverse)
library(rvest)


# Acquisizione dati da tabella html ---------------------------------------

win_df <- 'https://it.wikipedia.org/wiki/Leone_d%27oro_al_miglior_film' %>%
  read_html() %>% #parsing html
  html_node(".wikitable") %>% 
  html_table(fill=T) %>% 
  filter(!str_detect(string = Film, pattern = 'non [venne||fu]')) %>% #filtro per escludere anni senza premiazioni
  rename(Paese=Nazione) 


# Scrittura csv -----------------------------------------------------------

write_csv(x = win_df, path = "R/Winners.csv")


# Creazione pivot ---------------------------------------------------------

pivot_df <- win_df %>% 
  separate_rows(Paese, sep = "/\\s?") %>% #split righe con più paesi per "/" e spazio
  count(Paese, sort = T) %>% #Conteggio e sort
  rename(Vincitori = n)  


# Scrittura csv -----------------------------------------------------------

write_csv(x = pivot_df, path = "R/Countries.csv")


# Creazione grafico a barre -----------------------------------------------

g <- ggplot(data = pivot_df,
            aes(x = reorder(Paese,Vincitori), y = Vincitori)) +
  geom_bar(stat='identity') +
  coord_flip()

#Salvataggio grafico in png
ggsave(filename = "R/plot.png", device = "png")
