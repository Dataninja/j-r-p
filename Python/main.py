
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
# 2 - sistemiamo i record difettosi con una tanto incomprensibile quanto affascinante combinazione di list comprehension e dictionary unpacking
records = [item for sublist in [
    [
        {
            **record,
            'Anno'    : record['Anno'] if record['Anno'].isdigit() else records[index-1]['Anno'],
            'Film'    : record['Film'] if record['Anno'].isdigit() else record['Anno'],
            'Regista' : record['Regista'] if record['Anno'].isdigit() else record['Film'],
            'Nazione' : country
        }
        for country in [
            c.strip()
            for c in (record['Nazione'] if record['Anno'].isdigit() else record['Regista']).split('/')
        ]
    ]
    for index, record in enumerate(records)
    if ('mostra non fu' not in record['Film']) and ('non venne assegnato' not in record['Film'])
] for item in sublist]

# 3 - riconvertiamo i dizionari in dataframe
dataframe = pd.DataFrame(records)

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
