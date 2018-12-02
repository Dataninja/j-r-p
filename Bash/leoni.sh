 #!/bin/bash

 ### requisiti ###
 # htmltable2flatgrid https://github.com/aborruso/htmltable2flatgrid/blob/master/htmltable2flatgrid.py
 # miller http://johnkerl.org/miller/doc/
 ### requisiti ###
 
 # estrai la terza tabella dalla pagina di wikipedia
htmltable2flatgrid.py "https://it.wikipedia.org/wiki/Leone_d%27oro_al_miglior_film" 2


# estrai soltanto gli anni con il premio assegnato
# rimuovi righe con anni zenza vincitori
# normalizza il separatore degli anni con più nazioni vincitrici

tail -n +2 ./table.csv | \
mlr --csv filter -S '$Regista =~ ".+"' \
then fill-down -f Anno \
then put '$Nazione=gsub($Nazione,"/ +","|")' >./leoni.csv

# cancella la cartella raw di download
rm ./table.csv

# estrai la colonna Nazione
# esplodi in verticale le celle, in presenza del separaratore | per gli anni con più nazioni premiate
# conteggia per valori distinti di Nazione
# ordina per Nazione
mlr --csv cut -o -f Nazione \
then nest --explode --values --across-records -f Nazione --nested-fs "|" \
then count-distinct -f Nazione -o Conteggio \
then sort -nr Conteggio leoni.csv >./leoniNazione.csv
