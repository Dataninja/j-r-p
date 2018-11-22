import requests
from lxml import html
import pandas as pd
import matplotlib.pyplot as plt

url  = "https://it.wikipedia.org/wiki/Leone_d'oro_al_miglior_film"

#Parse html
response = requests.get(url)
root = html.fromstring(response.text) 
tree = root.getroottree() #salva root element

#Naviga root fino alle cell con solo i film, escludendo gli anni senza film. Tutti i film sono in italics, ergo:
films = root.xpath("//th[contains(., 'Anno')]/ancestor::table/tbody/tr/td/i[1]")

#inizia una empty list a cui si aggiungeranno i dictionary
data = []

for film in films:
    #store xpath specifica al film in questione, usala poi per spostarti di due colonne e prendere nazioni
    film_xpath = tree.getpath(film) 
    nazioni = [nazione.strip() for nazione in root.xpath(film_xpath+'/ancestor::td/following-sibling::td[2]')[0].text_content().split('/')]
    
    #crea dictionary per ogni nazione_singola-film-regista-anno
    for nazione in nazioni:
        row = {}
        row['nazione'] = nazione
        row['film'] = film.text_content().strip()
        
        #Sfrutta errore per sistemare casi in cui anno non è convertibile a int (nel caso in cui 2 film hanno vinto in un anno)
        try:
            row['anno'] = int(root.xpath(film_xpath+'/ancestor::tr/td')[0].text_content().strip())
        except ValueError:
            row['anno'] = data[-1]['anno']
        
        row['regista'] = root.xpath(film_xpath+'/ancestor::td/following-sibling::td')[0].text_content().strip()
       
        #optional: calcola prize shares (esempio: se 1 film ha 3 nazioni, allora il weight del premio della nazione è 0.33)
        totale_nazioni = len(nazioni)
        row['prize_share'] = round(1/len(nazioni),2)
        data.append(row)


#Crea dataframe da list of dict e salva
df = pd.DataFrame(data).sort_values(by = 'anno')
df.to_csv('vincitori.csv',  encoding='utf8', index = False)

#Crea pivot e salva csv
nazioni_count = df.pivot_table(index = 'nazione', aggfunc = {'nazione':'count', 'prize_share':'sum'}).sort_values(by= 'nazione', ascending=False)
nazioni_count.columns = ['leoni_absolute', 'leoni_prize_share'] 
nazioni_count.to_csv('leoni-nazioni.csv',  encoding='utf8')

# Crea bar e salva
nazioni_count.plot(kind='barh',figsize=(10,10), width=0.8, color=['#DF1B3B','#333333']).invert_yaxis()
plt.savefig('leoni-nazione.png')
