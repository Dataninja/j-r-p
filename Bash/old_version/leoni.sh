 #!/bin/bash
 
 # accedi alla pagina
curl "https://it.wikipedia.org/wiki/Leone_d%27oro_al_miglior_film" |
	# filtra soltantto i record della tabella con i leoni e estraila in JSON
	pup --charset utf-8 -p 'div.mw-parser-output > table.wikitable > tbody > tr:not(:first-child) json{}' >./raw.json
# estrai anni
jq <./raw.json '[.[].children | select(.|length > 2)] | {anno:.[][0].children[0].text}' |
	mlr --j2c cat >./anni.csv
# estrai titoli per anni con un solo vincitore
jq <./raw.json '[.[].children | select(.|length > 2)] | {titoloUno:.[][1].children[0].children[0].text}' |
	mlr --j2c cat >./titolo1.csv
# estrai titoli per anni con più di un vincitore
jq <./raw.json '[.[].children | select(.|length > 2)] | {titoloDue:.[][0].children[0].children[0].text}' |
	mlr --j2c cat >./titolo2.csv
# estrai regista per anni con un solo vincitore
jq <./raw.json '[.[].children | select(.|length > 2)] | {registaUno:.[][2].children[0].text}' |
	mlr --j2c cat >./regista1.csv
# estrai regista per anni con più di un vincitore
jq <./raw.json '[.[].children | select(.|length > 2)] | {registaDue:.[][1].children[0].text}' |
	mlr --j2c cat >./regista2.csv
# fai il merge dei dati estratti
paste -d "," ./anni.csv ./titolo1.csv ./titolo2.csv ./regista1.csv ./regista2.csv >./anniTitoloRegista.csv
# normalizza i dati
mlr --csv fill-down -f anno then put 'if ($titoloDue != "") {$titoloUno = $titoloDue}' \
	then put 'if ($registaDue != "") {$registaUno = $registaDue}' then cut -f anno,titoloUno,registaUno \
	then rename titoloUno,titolo,registaUno,regista ./anniTitoloRegista.csv >./leoni_tmp.csv
# estrai i dati sulle nazioni vincitrici
jq <./raw.json '[.[].children | select(.|length > 2)] | .[] | if (.|length) > 3 then 
([{nazione:.[3].children[].text }] | map(select(.nazione!= null).nazione) | . | 
{nazione:join(":")}) else  ([{nazione:.[2].children[].text }] | 
map(select(.nazione!= null).nazione) | . | {nazione:join(":")})  end' | mlr --j2c cat >./nazioni.csv
# aggiungi i dati sulle nazioni ai dati già estratti
paste -d "," ./leoni_tmp.csv ./nazioni.csv >./leoni.csv
# fai il conteggio per nazione
mlr --csv cut -o -f nazione then nest --explode --values --across-records -f nazione --nested-fs : \
	then count-distinct -f nazione -o conteggio then sort -nr conteggio ./leoni.csv >./leoniNazione.csv
