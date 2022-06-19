# panganBot

[![Project Status: Concept – Minimal or no implementation has been done
yet, or the repository is only intended to be a limited example, demo,
or
proof-of-concept.](https://www.repostatus.org/badges/latest/concept.svg)](https://www.repostatus.org/#concept)
[![](https://img.shields.io/badge/Twitter-@panganBot-white?style=flat&labelColor=blue&logo=Twitter&logoColor=white)](https://twitter.com/panganBot)
[![berasBOTpublish](https://github.com/Nr5D/panganBot/actions/workflows/berasBOTpublish.yml/badge.svg)](https://github.com/Nr5D/panganBot/actions/workflows/berasBOTpublish.yml)
[![panganBOTpublish](https://github.com/Nr5D/panganBot/actions/workflows/panganBOTpublish.yml/badge.svg)](https://github.com/Nr5D/panganBot/actions/workflows/panganBOTpublish.yml)

Source for the Twitter bot [@panganBot](https://www.twitter.com/panganBot). It posts daily price of several commodities in Indonesia, harvested from [hargapangan.id](http://hargapangan.id/) using [{rvest}](https://rvest.tidyverse.org/), diagrams is made using [{ggplot2}](https://ggplot2.tidyverse.org/) and send to twitter using [{rtweet}](https://docs.ropensci.org/rtweet/) and [GitHub Actions](https://docs.github.com/en/actions). Built by [@nurussadad](https://twitter.com/nurussadad). Inspired by [@londonmapbot](https://www.twitter.com/londonmapbot) and [@immunityunity](https://www.twitter.com/immunityunity).


# hargapangan.id

hargapangan.id by default publish six daily price data only (through some option, you can choose more), ~~by storing the result of harvesting, We will have a longer periode of time series data~~.  Note : No longer storing data, have some difficulties, with some data, updated several times in span 2~12 hours and another data did not updated at all.

![image description](blob/assests/panganBot_userR2020.png)
