library(rvest)

# URL from hargapangan.id
# Pasar Tradisional (PT) : https://hargapangan.id/tabel-harga/pasar-tradisional/daerah
# Pasar Modern (PM) : https://hargapangan.id/tabel-harga/pasar-modern/daerah
# Pedagang Besar (PB) : https://hargapangan.id/tabel-harga/pedagang-besar/daerah
# Produsen (PD) : https://hargapangan.id/tabel-harga/produsen/daerah


# Data from Traditional Market
urlPT <- "https://hargapangan.id/tabel-harga/pasar-tradisional/daerah"
tabelPT <- read_html(urlPT)
dataPT <- html_table(tabelPT)
dataPT <- dataPT[[1]]

# Data from Modern Market
urlPM <- "https://hargapangan.id/tabel-harga/pasar-modern/daerah"
tabelPM <- read_html(urlPM)
dataPM <- html_table(tabelPM)
dataPM <- dataPM[[1]]

# Data from Wholesaler
urlPB <- "https://hargapangan.id/tabel-harga/pedagang-besar/daerah"
tabelPB <- read_html(urlPB)
dataPB <- html_table(tabelPB)
dataPB <- dataPB[[1]]

# Data from Producer
urlPD <- "https://hargapangan.id/tabel-harga/produsen/daerah"
tabelPD <- read_html(urlPD)
dataPD <- html_table(tabelPD)
dataPD <- dataPD[[1]]

# Make it Tidy
# Traditional Market
rapiPT <- gather(dataPT, "date","price", -'Komoditas (Rp)', -'No.')
rapiPT$type <- rep("Pasar Tradisional", nrow(rapiPT))

# Modern Market
rapiPM <- gather(dataPM, "date","price", -'Komoditas (Rp)', -'No.')
rapiPM$type <- rep("Pasar Modern", nrow(rapiPM))

# Wholesaler
rapiPB <- gather(dataPB, "date","price", -'Komoditas (Rp)', -'No.')
rapiPB$type <- rep("Pedagang Besar", nrow(rapiPB))

# Producer
rapiPD <- gather(dataPD, "date","price", -'Komoditas (Rp)', -'No.')
rapiPD$type <- rep("Produsen", nrow(rapiPD))


# Bind Them All
rapi <-rbind(rapiPT, rapiPM, rapiPB, rapiPD)
colnames(rapi) <- c("no", "commodity", "date", "price","type")
rapi$no <- 1:nrow(rapi)

# Upload to ElephantSQL

library(RPostgreSQL)

query <- '
CREATE TABLE IF NOT EXISTS pangan (
  no integer,
  commodity character,
  date date,
  price decimal,
  type character,
  PRIMARY KEY (no)
)
'

drv <- dbDriver("PostgreSQL")

con <- dbConnect(drv,
                 dbname = Sys.getenv("ELEPHANT_SQL_DBNAME"), 
                 host = Sys.getenv("ELEPHANT_SQL_HOST"),
                 port = 5432,
                 user = Sys.getenv("ELEPHANT_SQL_USER"),
                 password = Sys.getenv("ELEPHANT_SQL_PASSWORD")
                 )

data = rapi

#Upload data
dbWriteTable(conn = con, name = "pangan", value = data, append = T, row.names = F)

# Disconnect from DB
on.exit(dbDisconnect(con))  
