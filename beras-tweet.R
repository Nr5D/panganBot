library(rvest)
library(dplyr)

# URL from hargapangan.ID
# Pasar Tradisional (PT) : https://hargapangan.id/tabel-harga/pasar-tradisional/komoditas
# Pasar Modern (PM) : https://hargapangan.id/tabel-harga/pasar-modern/komoditas
# Pedagang Besar (PB) : https://hargapangan.id/tabel-harga/pedagang-besar/komoditas
# Produsen (PD) : https://hargapangan.id/tabel-harga/produsen/komoditas

# Latest Price Data from Traditional Market

urlPT <- "https://hargapangan.id/tabel-harga/pasar-tradisional/komoditas"
data <- urlPT %>% read_html() %>% html_table()
dataPT <- data[[1]]

# Data from Modern Market

urlPM <- "https://hargapangan.id/tabel-harga/pasar-modern/komoditas"
data <- urlPM %>% read_html() %>% html_table()
dataPM <- data[[1]]

# Data from Wholesaler

urlPB <- "https://hargapangan.id/tabel-harga/pedagang-besar/komoditas"
data <- urlPB %>% read_html() %>% html_table()
dataPB <- data[[1]]

# Data from Producer

urlPD <- "https://hargapangan.id/tabel-harga/produsen/komoditas"
data <- urlPD %>% read_html() %>% html_table()
dataPD <- data[[1]]

# Make it Tidy
library(tidyr)

# Traditional Market
rapiPT <- gather(dataPT, "date","price", -'Provinsi (Rp)', -'No.')
rapiPT$type <- rep("Pasar Tradisional", nrow(rapiPT))

# Modern Market
rapiPM <- gather(dataPM, "date","price", -'Provinsi (Rp)', -'No.')
rapiPM$type <- rep("Pasar Modern", nrow(rapiPM))

# Wholesaler
rapiPB <- gather(dataPB, "date","price", -'Provinsi (Rp)', -'No.')
rapiPB$type <- rep("Pedagang Besar", nrow(rapiPB))

# Producer
rapiPD <- gather(dataPD, "date","price", -'Provinsi (Rp)', -'No.')
rapiPD$type <- rep("Produsen", nrow(rapiPD))


# Bind Them All
rapi <-rbind(rapiPT, rapiPM, rapiPB, rapiPD)
colnames(rapi) <- c("no", "provinsi", "date", "price","type")
rapi$no <- (1:nrow(rapi))

# Status Message
## Looking for the Latest Data to Make Status Message

df <- rapi

data <- df %>% 
  filter(as.Date(date, "%d/%m/%Y") == max(as.Date(df$date, "%d/%m/%Y")))

baris <- c(1:nrow(data))
terpilih <- sample(baris, 1)

dataSiap <- data %>%
  filter(provinsi == data$provinsi[terpilih]) %>%
  mutate(price = formatC(as.numeric(price)*1000, format="d", big.mark=".", decimal.mark=","))

# Hashtag

## 1st Hashtag
hashtag <- c("pangan","hargaPangan","hargaPanganIndonesia","hargaHarian","pasarTradisional","pasarModern","pedagangBesar","produsen",
             "github","rvest","rtweet", "bot", "opensource", "ggplot2")

samp_word <- sample(hashtag, 1)

## 4th Hashtag
namaprov <- dataSiap$provinsi[1]

## Function for Capital Each Word

simpleCap <- function(x) {
  x <- tolower(x)
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
        sep="", collapse=" ")
}

# Build the status message (text and price)

status_details <- paste0(
  dataSiap$date[1],": Harga beras di Provinsi ", simpleCap(dataSiap$provinsi[1]),
  " di :", "\n","\n",
  if(!is.na(dataSiap$type[1])) {paste0("⛺ ",dataSiap$type[1], " : Rp",dataSiap$price[1],",-")},"\n",
  if(!is.na(dataSiap$type[2])) {paste0("🏪 ",dataSiap$type[2], " : Rp",dataSiap$price[2],",-")}, "\n",
  if(!is.na(dataSiap$type[3])) {paste0("🎪 ",dataSiap$type[3], " : Rp",dataSiap$price[3],",-")}, "\n",
  if(!is.na(dataSiap$type[4])) {paste0("👨🏻‍🌾 ", dataSiap$type[4], " : Rp",dataSiap$price[4],",-")}, "\n",
  "\n",
  "\n",
  "#",samp_word, " #beras #hargaberas #", paste(gsub(" ", "", simpleCap(namaprov), fixed = TRUE)))


# Create Time Series Plot
## Data Preparation
dataPlot <- df %>%
  group_by(date) %>%
  filter(provinsi == data$provinsi[terpilih]) %>%
  mutate(date = as.Date(date, "%d/%m/%Y")) %>%
  mutate(price = as.numeric(price)*1000) %>%
  na.omit()

## ggplot2
library(ggplot2)
theme_set(theme_light(base_size = 15))
p <- ggplot(dataPlot,aes(x=date,y=price,colour=type,group=type)) +
  geom_line(size = 1)+
  geom_point(size = 3)+
  xlab(simpleCap(dataPlot$provinsi[1]))+
  ylab("Harga")+
  scale_y_continuous(labels = function(x) paste0("Rp", x,",-" )) +
  theme(legend.title=element_blank(),
        legend.position="bottom",
        axis.title.x = element_text(color="forestgreen", vjust=-0.35),
        axis.title.y = element_text(color="forestgreen" , vjust=0.35),
        legend.key=element_rect(fill='turquoise1'),
        legend.background = element_rect(fill = 'turquoise1'),
        panel.background = element_rect(fill = 'grey95'),
        plot.background = element_rect(fill = 'turquoise1'),
        axis.text.x=element_text(angle=0, hjust=1))+
  labs(tag = paste0("@panganBot")) +
  theme(plot.tag.position = c(0.85, 0.015),
        plot.tag = element_text(color="forestgreen"),
        text=element_text(family="mono"))+
  scale_x_date(date_labels = "%d-%b")

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
