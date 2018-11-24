# Estrarre i Leoni d'oro da Wikipedia a riga di comando

## requisiti

- il gigante [curl](https://curl.haxx.se/);
- il comodo [pup](https://github.com/ericchiang/pup);
- il magico [jq](https://stedolan.github.io/jq/);
- l'incredibile [miller](https://github.com/johnkerl/miller).


```bash
# accedi alla pagina
curl "https://it.wikipedia.org/wiki/Leone_d%27oro_al_miglior_film" | \
# filtra soltantto i record della tabella con i leoni e estraila in JSON
pup 'div.mw-parser-output > table.wikitable > tbody > tr:not(:first-child) json{}' | tee ./raw.json | \
# estrai i record con 4 colonne, ovvero quelli con premi assegnati
jq '[[.[].children | select(.|length > 3)] | .[] | {anno:.[0].children[0].text,titolo:.[1].children[0].children[0].text,regista:.[2].children[0].text}]' >./data.json
# estrai dai i record con 4 colonne, ovvero quelli con premi assegnati, i dati sulle nazioni vincenti
<raw.json jq '[.[].children | select(.|length > 3)] | .[] | [{nazione:.[3].children[].text }] | map(select(.nazione!= null).nazione) | . | {nazione:join(":")}' | mlr --j2c cat >./nazioni.csv
# converti in CSV i dati
mlr --j2c cat ./data.json >./leoni_tmp.csv
# aggiungi la colonna con le nazioni
paste  -d "," ./leoni_tmp.csv ./nazioni.csv > ./leoni.csv
# rimuovi file inutili
rm ./leoni_tmp.csv
# crea file con conteggio per nazioni
mlr --csv cut -o -f nazione then nest --explode --values --across-records -f nazione --nested-fs : then count-distinct -f nazione -o conteggio then sort -nr conteggio ./leoni.csv > leoniNazione.csv
```

## output

| nazione | conteggio |
| --- | --- |
| Francia | 10 |
| Italia | 10 |
| Stati Uniti | 8 |
| Regno Unito | 4 |
| Cina | 4 |
| Giappone | 3 |
| Germania Ovest | 3 |
| Taiwan | 3 |
| India | 2 |
| Russia | 2 |
| Cecoslovacchia | 1 |
| Danimarca | 1 |
| Algeria | 1 |
| Polonia | 1 |
| URSS | 1 |
| Vietnam | 1 |
| Iran | 1 |
| Irlanda | 1 |
| Israele | 1 |
| Corea del Sud | 1 |
| Svezia | 1 |
| Venezuela | 1 |
| Filippine | 1 |
| Messico | 1 |
