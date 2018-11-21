
# importiamo i pacchetti necessari
import pandas as pd
import matplotlib.pyplot as plt

# l'indirizzo da cui vogliamo scaricare la tabella
pageURL  = 'https://it.wikipedia.org/wiki/Leone_d%27oro_al_miglior_film'

# facciamo scaricare la pagina direttamente a pandas, dando indizi su qual e' la tabella che ci interessa
# "match" : la tabella deve contenere la stringa "Anno"
# "header": la prima riga contiene i nomi delle colonne
tables = pd.read_html(pageURL, match='Anno', header=0)

# read_html restituisce una lista di tabelle, usiamo la prima
dataframe = tables[0]

# alcune righe non contengono l'anno (grazie Alessio!), che va preso dalla riga precedente
# dobbiamo inoltre cancellare le righe riguardanti gli anni in cui non sono stati assegnati premi
# 1 - convertiamo il dataframe in una lista di dizionari
records = dataframe.to_dict(orient='records')
# 2 - sistemiamo i record difettosi
corrected_records = []
current_year = None
for record in records:

    if ('mostra non fu' in record['Film']) or ('non venne assegnato') in record['Film']:
        continue

    if not record['Anno'].isdigit():
        corrected_record = {
            'Anno'    : current_year,
            'Film'    : record['Anno'],
            'Regista' : record['Film'],
            'Nazione' : record['Regista']
        }
        corrected_records.append(corrected_record)
    else:
        current_year = record['Anno']
        corrected_records.append(record)

# 3 - riconvertiamo i dizionari in dataframe
dataframe = pd.DataFrame(corrected_records)

# salviamo in CSV
dataframe.to_csv('leoni.csv', index=None, quoting=1, encoding='utf8')

# pivot per contare i vincitori di ogni nazione
pivot = dataframe.groupby('Nazione').size().reset_index(name='Vincitori')
pivot = pivot.sort_values(by='Vincitori', ascending=False)

# salva CSV
pivot.to_csv('paesi_vincitori.csv', index=None, encoding='utf8')

# grafico a barre
pivot_sorted = pivot.sort_values(by='Vincitori', ascending=True)
pivot_sorted.plot.barh(x='Nazione', y='Vincitori')
plt.savefig('bars.png')

# PYTHON RULEZ
