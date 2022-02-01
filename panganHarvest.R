library(rvest)

url <- "https://hargapangan.id/tabel-harga/pasar-tradisional/daerah"
# getting the html codes
pangan <- read_html(url)

data <- html_table(pangan)
data <- data[[1]]

data_semula <- read.csv('https://raw.githubusercontent.com/Nr5D/panganBot/main/data/data.csv', check.names = FALSE)
data_sedot <- data # From rvest

d1 <- strptime(colnames(data_sedot)[ncol(data_sedot)], "%d/%m/%Y")
d2 <- strptime(colnames(data_semula)[ncol(data_semula)], "%d/%m/%Y")

if (!dir.exists('data')) {dir.create('data')}

if (! d1==d2) { #bikin double if di sini, jika tanggal beda dan jika datanya beda
  data_akhir <- cbind.data.frame(data_semula, data_sedot[,length(data_sedot)])
  write.csv( data_akhir, file.path("data/pangan.csv"), row.names = FALSE )
}
