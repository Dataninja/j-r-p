
using HTTP, DataFrames, Gumbo, Cascadia, PyPlot

sorgente = HTTP.get("https://it.wikipedia.org/wiki/Leone_d%27oro_al_miglior_film");
println(sorgente.status)

data = parsehtml(String(sorgente.body))

# elimino a mano le righe degli anni in cui la mostra non è presente
#  questo passaggio dovrebbe essere fatto meglio, di fatto non è automatizzato
data[1:end .!= "<td colspan=\"3\">"]

function pulizia(a, b) for i in b a=pulizia(a, i) end; a end;
html_data = "Anno,Film,Regista,Nazione\n" *  # specifico l'intestazione
         pulizia(
            data[findfirst(r"<table class=\"wikitable sortable\">"s, data)],
            ["\t"=>"",
             "\r\n"=>"",  
             r"<tr.*?>"=>"",  
             "</tr>"=>"\n",   
             r"</td><td>"=>"\",\"",
             r"<[/]?td>"=>"\"",
             r"<[/]?tbody>"=>""]);

df = readtable(IOBuffer(html_data))

df = by(df, :Nazione, nrow)

showcols(df)

x = df.Nazione
y = df.x1

plot(y, x, color="red", linewidth=2.0, linestyle="-")

savefig("vincitori.png")
