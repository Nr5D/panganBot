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

library(tidyr)

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

df <- rapi

# Status Message
## Looking for the Latest Data to Make Status Message

library(dplyr)
data <- df %>% 
  filter(as.Date(date, "%d/%m/%Y") == max(as.Date(df$date, "%d/%m/%Y")))

baris <- c(1:nrow(data))
terpilih <- sample(baris, 1)

dataSiap <- data %>%
  filter(commodity == data$commodity[terpilih]) %>%
  mutate(price = formatC(as.numeric(price)*1000, format="d", big.mark=".", decimal.mark=","))

# Hashtag
hashtag <- c("pangan","hargaPangan","hargaPanganIndonesia","hargaHarian","pasarTradisional","pasarModern","pedagangBesar","produsen",
             "github","rvest","rtweet", "ElephantSQL", "SQL", "bot", "opensource", "ggplot2","PostgreSQL","RPostgreSQL")

samp_word <- sample(hashtag, 1)

paste0("#",samp_word)

# Build the status message (text and price)
status_details <- paste0(
  dataSiap$date[1],": Harga ", dataSiap$commodity[1],
  " di :", "\n","\n",
  "⛺ ",dataSiap$type[1], " : Rp",dataSiap$price[1],",-", "\n",
  "🏪 ",dataSiap$type[2], " : Rp",dataSiap$price[2],",-", "\n",
  "🎪 ",dataSiap$type[3], " : Rp",dataSiap$price[3],",-", "\n",
  "👨🏻‍🌾 ",dataSiap$type[4], " : Rp",dataSiap$price[4],",-", "\n",
  "\n",
  "\n",
  "#",samp_word)


# Create Time Series Plot
## Data Preparation
dataPlot <- df %>%
  group_by(date) %>%
  filter(commodity == data$commodity[terpilih]) %>%
  mutate(date = as.Date(date, "%d/%m/%Y")) %>%
  mutate(price = as.numeric(price)*1000) %>%
  na.omit()

## ggplot2
library(ggplot2)
p <- ggplot(dataPlot,aes(x=date,y=price,colour=type,group=type)) +
  geom_line(size = 3)+
  geom_point(size = 6)+
  xlab(dataPlot$commodity[1])+
  ylab("Harga")+
  scale_y_continuous(labels = function(x) paste0("Rp", x,",-" )) +
  theme_light()

# Download the image to a temporary location
# save to a temp file
file <- tempfile( fileext = ".png")
ggsave(file, plot = p, device = "png", dpi = 144, width = 8, height = 8, units = "in" )


# Publish to Twitter
library(rtweet)

## Create Twitter token
pangan_token <- rtweet::create_token(
  app = "PanganBOT",
  consumer_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

## Post the image to Twitter
rtweet::post_tweet(
  status = status_details,
  media = file,
  token = pangan_token
)