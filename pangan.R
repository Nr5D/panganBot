# Read Data from Elephant SQL
library(RPostgreSQL)

drv <- dbDriver("PostgreSQL")
con <- dbConnect(drv,
                 dbname = Sys.getenv("ELEPHANT_SQL_DBNAME"), 
                 host = Sys.getenv("ELEPHANT_SQL_HOST"),
                 port = 5432,
                 user = Sys.getenv("ELEPHANT_SQL_USER"),
                 password = Sys.getenv("ELEPHANT_SQL_PASSWORD")
)

df <- dbGetQuery(con, statement = paste("SELECT * FROM Pangan"))

# Looking for the Latest Data to Make Status Message

library(dplyr)
data <- df %>% 
  filter(as.Date(date, "%d/%m/%Y") == max(as.Date(df$date, "%d/%m/%Y")))

baris <- c(1:nrow(data))
terpilih <- sample(baris, 1)

dataSiap <- data %>%
  filter(commodity == data$commodity[terpilih])

dataSiap$price <- formatC(as.numeric(dataSiap$price)*1000, format="d", big.mark=".", decimal.mark=",")

# Build the status message (text and URL)
status_details <- paste0(
  dataSiap$date[1],": Harga ", dataSiap$commodity[1],
  " di :", "\n","\n",
  "⛺ ",dataSiap$type[1], " adalah Rp",dataSiap$price[1],",-", "\n",
  "🏪 ",dataSiap$type[2], " adalah Rp",dataSiap$price[2],",-", "\n",
  "🎪 ",dataSiap$type[3], " adalah Rp",dataSiap$price[3],",-", "\n",
  "👨🏻‍🌾 ",dataSiap$type[4], " adalah Rp",dataSiap$price[4],",-", "\n")

library(rtweet)

# Create Twitter token
pangan_token <- rtweet::create_token(
  app = "PanganBOT",
  consumer_key =    Sys.getenv("TWITTER_CONSUMER_API_KEY"),
  consumer_secret = Sys.getenv("TWITTER_CONSUMER_API_SECRET"),
  access_token =    Sys.getenv("TWITTER_ACCESS_TOKEN"),
  access_secret =   Sys.getenv("TWITTER_ACCESS_TOKEN_SECRET")
)

# Post the image to Twitter
rtweet::post_tweet(
  status = status_details,
  token = pangan_token
)
