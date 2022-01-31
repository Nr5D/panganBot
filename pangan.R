library(rvest)

url <- "https://hargapangan.id/tabel-harga/pasar-tradisional/daerah"
# getting the html codes
pangan <- read_html(url)

data <- html_table(pangan)
data <- data[[1]]

data_semula <- read.csv('data/pangan.csv', check.names = FALSE)
data_sedot <- data # From rvest

d1 <- strptime(colnames(data_sedot)[ncol(data_sedot)], "%d/%m/%Y")
d2 <- strptime(colnames(data_semula)[ncol(data_semula)], "%d/%m/%Y")

if (!dir.exists('data')) {dir.create('data')}

if (! d1==d2) { #bikin double if di sini, jika tanggal beda dan jika datanya beda
  data_akhir <- cbind.data.frame(data_semula, data_sedot[,length(data_sedot)])
  write.csv( data_akhir, file.path("data/pangan.csv"), row.names = FALSE )
}


library('rtweet')
library('ggplot2')

# Create Twitter token
pangan_token <- rtweet::create_token(
  app = "PanganBOT",
  consumer_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

# Read Data from previously harvested data
data <- read.csv('data/pangan.csv', check.names = FALSE)
baris <- c(1:nrow(data))
terpilih <- sample(baris, 1)

# Food

# Format Pakai Angka
price <- data[,ncol(data)][terpilih]
price <- formatC(price*1000, format="d", big.mark=".", decimal.mark=",")
price_before <- data[,ncol(data)-1][terpilih]
price_before <- formatC(price_before*1000, format="d", big.mark=".", decimal.mark=",")

# Format Pakai Emoji
#price <- data[,length(data)][terpilih]*1000
#harga <- as.numeric(strsplit(as.character(price),"")[[1]])
#dice <- 1:length(harga)
#tes <- for (x in dice) {paste(keycap(harga[x]))}

name <- data[terpilih,2]

# Build the status message (text and URL)
status_details <- paste0(
  colnames(data)[ncol(data)],": Harga ", name,
  " di Pasar Tradisional adalah Rp",price,
  ",- dengan harga sebelumnya adalah Rp", price_before,",-"
)

# Image sample
value = data[terpilih,3:ncol(data)]

data_plot <- data.frame(
  day = strptime(colnames(value), "%d/%m/%Y"),
  value = t(value)*1000
)

colnames(data_plot)[2] <- data[terpilih,2]

# Most basic Line and Point Plot
p <- ggplot(data_plot, aes(x =day,  y=data_plot[,2])) +
  geom_line()+
  geom_point()+
  xlab(colnames(data_plot)[2])+
  ylab("Harga")

# Download the image to a temporary location
# save to a temp file
file <- tempfile( fileext = ".png")
ggsave(file, plot = p, device = "png", dpi = 144, width = 8, height = 8, units = "in" )

# Post the image to Twitter
rtweet::post_tweet(
  status = status_details,
  media = file,
  token = pangan_token
)
