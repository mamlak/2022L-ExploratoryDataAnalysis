library(dplyr)

df <- read.csv("house_data.csv")


# 1. Jaka jest �rednia cena nieruchomo�ci po�o�onych nad wod�, kt�rych jako� wyko�czenia jest r�wna lub wi�ksza od mediany jako�ci wyko�czenia?
df %>% select(price,waterfront,grade) %>%
  filter(waterfront==1) %>%
  mutate(Grade_median = median(grade)) %>%
  filter(grade >= Grade_median) %>% 
  summarise(Price_mean = mean(price))

# Odp:  �rednia cena nieruchomo�ci po�o�onych nad wod�, kt�rych jako� wyko�czenia jest r�wna lub wi�ksza od mediany jako�ci wyko�czenia to 2302236


# 2. Czy nieruchomo�ci o 2 pi�trach maj� wi�ksz� (w oparciu o warto�ci mediany) liczb� �azienek ni� nieruchomo�ci o 3 pi�trach?
df %>% select(floors,bathrooms) %>%
  filter(floors == 2.0 | floors==3.0) %>% 
  group_by(floors) %>%
  summarise(median_bathrooms = median(bathrooms))

# Odp: Nie, nieruchomo�ci o 2 i 3 pietrach maja taka sama liczbe lazienek w oparciu o wartosc mediany


# 3. O ile procent wi�cej jest nieruchomo�ci le�cych na p�nocy zach�d ni�  nieruchomo�ci le��cych na po�udniowy wsch�d?
latitude <- df %>% 
  summarise(m = median(lat)) 


longitude <- df %>% 
  summarise(m = median(long))

df %>%  select(lat, long) %>% 
  filter((lat > latitude[1,1] & long < longitude[1,1]) |
           (lat < latitude[1,1] & long > longitude[1,1])  ) %>% 
  mutate(Directions = ifelse((lat > latitude[1,1] & long < longitude[1,1]),
                             'north_west', 'south_east')) %>% 
  group_by(Directions) %>%  summarise(n=n()) %>%
  summarise(statistic = (n[1] - n[2])*100/ n[2] )
  

# Odp: nieruchomo�ci le�cych na p�nocy zach�d ni�  nieruchomo�ci le��cych na po�udniowy wsch�d jest wiecj o 0,148 %



# 4. Jak zmienia�a si� (mediana) liczba �azienek dla nieruchomo�ci wybudownych w latach 90 XX wieku wzgl�dem nieruchmo�ci wybudowanych roku 2000?

df %>%  select(yr_built, bathrooms) %>%
  filter(yr_built>= 1990 &  yr_built<=2000) %>%
  mutate(Time_period = ifelse(yr_built== 2000, 2000, 90)) %>% 
  group_by(Time_period) %>%
  summarise(Bathrooms_median = median(bathrooms))

# Odp: Mediana nie ulegla zmianie, utrzymuje sie na poziomie 2.5 


# 5. Jak wygl�da warto�� kwartyla 0.25 oraz 0.75 jako�ci wyko�czenia nieruchomo�ci po�o�onych na p�nocy bior�c pod uwag� czy ma ona widok na wod� czy nie ma?

df %>%  filter(lat >= latitude[1,1]) %>%
  select(grade, waterfront) %>%
  group_by(waterfront) %>% 
  summarise(q1 = quantile(grade, 0.25), q3 = quantile(grade, 0.75))


# Odp: Dla nieruchomosci NIE polozonych nad woda Q1 = 7, Q3 = 8, dla nieruchomosci polozonych nad woda Q1 = 8, Q3 = 11


# 6. Pod kt�rym kodem pocztowy jest po�o�onych najwi�cej nieruchomo�ci i jaki jest rozst�p miedzykwartylowy dla ceny nieruchomo�ci po�o�onych pod tym adresem?

df %>%  count(zipcode, sort = TRUE) %>% 
  slice(1) %>%
  left_join(df) %>% 
  select(zipcode,price) %>% 
  group_by(zipcode) %>% 
  summarise(IQR = quantile(price, 0.75)- quantile(price, 0.25))

# Odp: Kod pocztowy to 98103, a rozstep miedzykwartylowy tego adresu to 262875


# 7. Ile procent nieruchomo�ci ma wy�sz� �redni� powierzchni� 15 najbli�szych s�siad�w wzgl�dem swojej powierzchni?

df %>% select(sqft_living, sqft_living15) %>%
  mutate(less_than_living15 = ifelse(sqft_living < sqft_living15, 1, 0)) %>% 
  summarise(percentage = (sum(less_than_living15)/ nrow(.))* 100)


# Odp: Wyzsza srednia powierzchnie 15 najblizszych sasiadow wzgledem swojej powierzchni ma 42,59 % nieruchomosci


# 8. Jak� liczb� pokoi maj� nieruchomo�ci, kt�rych cena jest wi�ksza ni� trzeci kwartyl oraz mia�y remont w ostatnich 10 latach (pamietaj�c �e nie wiemy kiedy by�y zbierane dne) oraz zosta�y zbudowane po 1970?

# pokoj == sypialnia 

df %>% filter(yr_built> 1970 & price> quantile(price, 0.75) & yr_renovated>= 2012) %>%
  select(bedrooms) 

# Odp: Liczba pokoi to 3 , 4 lub 5


# 9. Patrz�c na definicj� warto�ci odstaj�cych wed�ug Tukeya (wykres boxplot) wska� ile jest warto�ci odstaj�cych wzgl�dem powierzchni nieruchomo�ci(dolna i g�rna granica warto�ci odstajacej).

#boxplot.stats(df$sqft_living)
#boxplot(df$sqft_living)

df %>% select(sqft_living) %>%
  filter(sqft_living %in% boxplot.stats(sqft_living)$out) %>%
  count()

# Odp: Jest 572 wartosci odstajacych, wszystkie gornej granicy


# 10. W�r�d nieruchomo�ci wska� jaka jest najwi�ksz� cena za metr kwadratowy bior�c pod uwag� tylko powierzchni� mieszkaln�.

# ft^2 - stopy kwadratowe 
# m^2 = ft^2/ 10.764

df %>%  select(sqft_living, price) %>%
  mutate(sqm_living = sqft_living/10.764) %>% 
  mutate(Cost_per_sq_meter =price/sqm_living ) %>%
  select(- c(sqft_living,price,sqm_living)) %>% top_n(1)

# Odp: Najwi�ksza cena za metr kwadratowy powierzchni mieszkalnej to 8720.335