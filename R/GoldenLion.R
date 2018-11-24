# Caricamento librerie ----------------------------------------------------

library(tidyverse)
library(rvest)

# Acquisizione dati da tabella html ---------------------------------------

table_df <- 'https://it.wikipedia.org/wiki/Leone_d%27oro_al_miglior_film' %>%
  read_html() %>% #parsing html
  html_node(".wikitable") %>% #selezione del nodo 'wikitable'
  html_table(fill=T) %>% #trasformazione in formato tabulare e gestione fill missing values
  filter(!str_detect(string = Film, pattern = 'non [venne||fu]')) %>% #filtro per escludere anni senza premiazioni
  rename(Paese=Nazione) #to fix in it.wikipedia too

#Scrivi CSV
write_csv(x = table_df, path = "R/Winners.csv") 


#Creazione pivot ----------------------------------------------------------------

pivot_df <-  table_df %>% 
             separate_rows(Paese, sep = "/\\s?") %>% #split righe con più paesi per "/" e spazio (con regex)
             count(Paese, sort = T) %>% #Conteggio e sort
             rename(Vincitori = n)
  
#Scrivi CSV
write_csv(x = pivot_df, path = "R/Countries.csv")

# Creazione grafico a barre -----------------------------------------------

chart <- ggplot(data = pivot_df,
            aes(x = reorder(Paese,Vincitori), y = Vincitori)) +
         geom_bar(stat='identity') +
            labs(x= "Paese vincitore",
                 y="Numero di vittorie",
                 title="Vincitori per paese d'origine",
                 caption= "Fonte: Wikipedia") + #da qui sono modifiche estetiche
         scale_y_continuous(breaks = pivot_df %$% Vincitori %>% unique) + #personalizzazione scala
         coord_flip() +
         theme_minimal() + #da qua personalizzazione elementi tema grafico
         theme(panel.grid.major.x = element_line(linetype = "dotted", colour = "darkgrey"),
           panel.grid.major.y = element_blank(),
           panel.grid.minor = element_blank())

# Salvataggio grafico in png ----------------------------------------------

ggsave(plot = chart, filename = "R/plot.png", device = "png")