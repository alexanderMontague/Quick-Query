# Quick-Query
![Imgur](https://i.imgur.com/QF2YAQl.png)

A Census and Crime Data Query Engine

Created by: Alex Montague, Ahmed Mahmoud and Joshua Prpic

Final Project for UofG CIS2250


### About
* This program allows you to make single or cross queries about Canadaian Crime Data (Years 1998-2015) and Canadian Census Data (Years 2001, 2006, 2011)
* Displays the results in multiple data formats including graphs
* Lets you see correlation between census data and crime statistics
* Press enter at any input to see the full list of options/statistics


### Examples
* Simple Multiyear Crime Query
![Imgur](https://i.imgur.com/bMBKBCI.png)
![Imgur](https://i.imgur.com/SqIb1Hi.png)

* Cross Referenced Multi Crime Query
![Imgur](https://i.imgur.com/1scL4Es.png)
![Imgur](https://i.imgur.com/ELb0pOG.png)

* Cross Referenced Census and Crime Query for One Year
![Imgur](https://i.imgur.com/I2vRGn3.png)
![Imgur](https://i.imgur.com/pkIJrtm.png)


### Usage (Unix Based Systems)
* (Install Perl and libtext csv `sudo apt-get install libtext-csv-perl`)
* Clone Repository `git clone https://github.com/alexanderMontague/Quick-Query/`
* Navigate into Directory `cd Quick-Query`
* Run Program `perl queryEnginer.pl`
* ##### FOR GRAPHING RUN BELOW:
* Install R `sudo apt install r-cran-littler`
* Install Statistics::R `sudo  perl -MCPAN -e 'install Statistics::R'`
* Run R `R`
* Install ggPlot2 while in R environment`install.packages("ggplot2")`
* Should be good to Run!
