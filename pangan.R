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
data <- read.csv('https://raw.githubusercontent.com/Nr5D/panganBot/main/data/data.csv', check.names = FALSE)
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


posisi <- function(x){
  if ((data[x,ncol(data)]-data[x,ncol(data)-1])  > 0) {
    print("naik")
  } else if ((data[x,ncol(data)]-data[x,ncol(data)-1])  < 0) {
    print("turun")
  } else {
    print("tetap")
  }
}

# Build the status message (text and URL)
status_details <- paste0(
  colnames(data)[ncol(data)],": Harga ", name,
  " di Pasar Tradisional adalah Rp",price,
  ",- ",  posisi(terpilih)," dari harga sebelumnya Rp", price_before,",-"
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
  geom_line(color = "#00AFBB", size = 1)+
  geom_point(color = "#FC4E07", size = 2)+
  xlab(colnames(data_plot)[2])+
  ylab("Harga")+
  scale_y_continuous(labels = function(x) paste0("Rp", formatC(x, format="d", big.mark=".", decimal.mark=","),",-" )) +
  theme_light()

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
