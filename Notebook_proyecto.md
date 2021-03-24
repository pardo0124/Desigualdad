---
title: "R Notebook"
output:
  html_document: 
    keep_md: yes
---


```r
#install.packages("utf8")
#install.packages("wbstats")
library(wbstats)
#GINI<- wb_search("GINI")
Desigualdad <- wb_data("SI.POV.GINI",country = "countries_only", start_date = 1960, end_date = 2019)

#Taxes<- wb_search("Taxes")
Progresividad<-wb_data("GC.TAX.YPKG.RV.ZS",country = "countries_only", start_date = 1960, end_date = 2019)

#waste_in_education<- wb_search("Government expenditure on education")
Gasto_educ<-wb_data("SE.XPD.TOTL.GD.ZS",country = "countries_only", start_date = 1960, end_date = 2019)

#INf<- wb_search("Inflation")
Inflacion <- wb_data("FP.CPI.TOTL.ZG",country = "countries_only", start_date = 1960, end_date = 2019)

#INf<- wb_search("PIB")
PIB_PER_CAPITA <- wb_data("NY.GDP.PCAP.CD",country = "countries_only", start_date = 1960, end_date = 2019)

#INf<- wb_search("Population")
Poblacion <- wb_data("SP.POP.TOTL",country = "countries_only", start_date = 1960, end_date = 2019)
```


```r
library(tidyverse)
```

```
## -- Attaching packages --------------------------------------- tidyverse 1.3.0 --
```

```
## v ggplot2 3.3.3     v purrr   0.3.4
## v tibble  3.1.0     v dplyr   1.0.5
## v tidyr   1.1.3     v stringr 1.4.0
## v readr   1.4.0     v forcats 0.5.1
```

```
## -- Conflicts ------------------------------------------ tidyverse_conflicts() --
## x dplyr::filter() masks stats::filter()
## x dplyr::lag()    masks stats::lag()
```

```r
base <- full_join(Desigualdad,Gasto_educ, by=c("iso3c","date","iso2c","country"))

 base <- full_join(base,Inflacion, by=c("iso3c","date","iso2c","country"))
 base <- full_join(base,PIB_PER_CAPITA, by=c("iso3c","date","iso2c","country"))
 base <- full_join(base,Poblacion, by=c("iso3c","date","iso2c","country"))
 base <- full_join(base,Progresividad, by=c("iso3c","date","iso2c","country"))
 
base_final=base[,c("iso3c","country","date","SI.POV.GINI","GC.TAX.YPKG.RV.ZS","SE.XPD.TOTL.GD.ZS","FP.CPI.TOTL.ZG","NY.GDP.PCAP.CD","SP.POP.TOTL")]
names(base_final)=c("Código","Pais","Año","Desigualdad", "Gasto_educ","Inflacion","PIB_PER_CAPITA","Poblacion","Progresividad")
```

## Pregunta de investigación e hipótesis:

¿Cuál es el efecto de la inversión en educación (como % del PIB) sobre la desigualdad (coeficiente Gini) en los países del mundo?

**Hipótesis**: Creemos que existe una relación negativa entre la inversión en educación y el GINI (desigualdad), es decir, que la inversión en educación ayuda a reducir la desigualdad.

## Bases de datos:

1.  **Nombres:**

    -   **SI.POV.GINI** *(coeficiente de Gini)*

    -   **GC.TAX.YPKG.RV.ZS** *(Impuestos sobre la renta, las utilidades y las ganancias de capital como porcentaje de la recaudación total)*

    -   **SE.XPD.TOTL.GD.ZS** *(gasto en educación como % del PIB)*

    -   **"FP.CPI.TOTL.ZG"** *(inflación)*

    -   **"NY.GDP.PCAP.CD"** *(PIB per cápita)*

    -   **"SP.POP.TOTL"** *(Población)*

2.  **Entidad que produjo las bases de datos:**

    Banco Mundial (base de acceso público).

3.  **Número de variables:**

    
    ```r
    ncol(base_final)
    ```
    
    ```
    ## [1] 9
    ```

    Las variables que vamos a utilizar son 9, y son las siguientes:

    -   **País y código**

        Estas son variables descriptivas que identifican los paises del cuales se está tomando cada una de las observaciónes, no existen agregados regionales (sólo países).

    -   **Año**

        Esta variable nos da la ubicación en el tiempo de cada observación y nos permite hacer un analisis longitudinal.

    -   **Coeficiente de Gini, variable dependiente**

        Este es un índice muy conocido mundialmente por ser el primer referente a la hora de medir la desigualdad dentro de los países. Este coeficiente oscila entre `0` y `100`, donde `0` indica perfecta igualdad y `100` señala una completa desigualdad.

        > El índice de Gini mide hasta qué punto la distribución del ingreso (o, en algunos casos, el gasto de consumo) entre individuos u hogares dentro de una economía se aleja de una distribución perfectamente equitativa. Una curva de Lorenz muestra los porcentajes acumulados de ingreso recibido total contra la cantidad acumulada de receptores, empezando a partir de la persona o el hogar más pobre. El índice de Gini mide la superficie entre la curva de Lorenz y una línea hipotética de equidad absoluta, expresada como porcentaje de la superficie máxima debajo de la línea. Así, un índice de Gini de 0 representa una equidad perfecta, mientras que un índice de 100 representa una inequidad perfecta. (Banco Mundial, 2020)

    -   **Gasto en educación (% del PIB), variable independiente principal**

        Esta variable nos indica el nivel de inversión en educación que realizan los diferentes países en relación con su producto interno bruto (PIB), con esta variable buscamos identificar los diferentes gastos en educación que se pueden encontrar en los diferentes países a nivel mundial y su relación con la desigualdad interna de los mismos.

        > El gasto público en educación como porcentaje del PIB comprende el gasto público total (corriente y de capital) en educación expresado como porcentaje del Producto Interno Bruto (PIB) en un año determinado. El gasto público en educación incluye el gasto del Gobierno en instituciones educativas (públicas y privadas), administración educativa y subsidios o transferencias para entidades privadas (estudiantes/hogares y otras entidades privadas). (Banco Mundial, 2020)

    -   **Impuestos sobre la renta, las utilidades y las ganancias de capital (% del total del recaudo), variable control**

        Esta es nuestra variable control del modelo econométrico que queremos construir pues, al medir el nivel porcentual de impuestos que se le cobran a los ingresos, utilidades y ganancias del capital de las empresas en relación con el recaudo total, es un buen indicador del nivel de progresividad de la tributación en los diferentes países, y esto está directamente relacionado con la desigualdad de estos.

        > Los impuestos sobre la renta, las utilidades y las ganancias de capital se gravan sobre el ingreso neto real o presunto de las personas, sobre las utilidades de las sociedades y empresas, y sobre las ganancias de capital, realizadas o no, la tierra, valores y otros activos. Los pagos intragubernamentales se eliminan en la consolidación. (Banco Mundial, 2020)

    -   **Inflación, precios al consumidor (% anual), variable control**

        Esta es una variable macroeconómica que mide la erosión del dinero, debido a esto puede afectar sustancialmente los niveles de desigualdad.

        > La inflación medida por el índice de precios al consumidor refleja la variación porcentual anual en el costo para el consumidor medio de adquirir una canasta de bienes y servicios que puede ser fija o variable a intervalos determinados, por ejemplo anualmente. Por lo general se utiliza la fórmula de Laspeyres. (Banco Mundial, 2020)

    -   **PIB per cápita, variable control**

        El PIB per cápita es el ingreso nacional dividido en el número de personas que conforman la económia, este indicador nos apróxima al nivel de productividad de un país.

        > El PIB per cápita es el producto interno bruto dividido por la población a mitad de año. El PIB es la suma del valor agregado bruto de todos los productores residentes en la economía más todo impuesto a los productos, menos todo subsidio no incluido en el valor de los productos. Se calcula sin hacer deducciones por depreciación de bienes manufacturados o por agotamiento y degradación de recursos naturales. Datos en US\$ a precios actuales. (Banco Mundial, 2020)

    -   **Población, variable control**

        Esta variable nos indica el número de habitantes por país, esto nos ayuda en nuestro modelo a encontrar si la desigualdad depende del tamaño poblacional.

        > Total population is based on the de facto definition of population, which counts all residents regardless of legal status or citizenship. The values shown are midyear estimates. (Banco Mundial, 2020)

4.  **Número de observaciones:**

    Las observaciones son los diferentes países del mundo para cada año entre 1960 y 2019, de este modo se encontraron un total 13020 observaciones.

    
    ```r
    nrow(base_final)
    ```
    
    ```
    ## [1] 13020
    ```

5.  **Tipo de base de datos:**

    Escogimos trabajar con una base de datos de **datos panel,** esto para obtener un gran número de observaciones que apoye la robustez del estudio.

6.  **Período que cubre las bases de datos:**

    El periodo para analizar va desde el año 1960 hsata 2019.

## Bibliografía

-   Banco Mundial (16 de diciembre, 2020). Índice de Gini. [SI.POV.GINI]. Recuperado de [\<https://datos.bancomundial.org/indicator/SI.POV.GINI\>](https://datos.bancomundial.org/indicator/SI.POV.GINI){.uri}

-   Banco Mundial (16 de diciembre, 2020). Impuestos sobre la renta, las utilidades y las ganancias de capital (% del total de impuestos) [GC.TAX.YPKG.ZS]. Recuperado de [\<https://datos.bancomundial.org/indicador/GC.TAX.YPKG.ZS\>](https://datos.bancomundial.org/indicador/GC.TAX.YPKG.ZS){.uri}

-   Banco Mundial (16 de diciembre, 2020). Gasto público en educación, total (% del PIB). [SE.XPD.TOTL.GD.ZS]. Recuperado de [\<https://datos.bancomundial.org/indicador/SE.XPD.TOTL.GD.ZS\>](https://datos.bancomundial.org/indicador/SE.XPD.TOTL.GD.ZS){.uri}

-   Banco Mundial (16 de diciembre, 2020). PIB per cápita (US\$ a precios actuales). [NY.GDP.PCAP.CD]. Recuperado de

    <https://datos.bancomundial.org/indicator/NY.GDP.PCAP.CD>

-   Banco Mundial (16 de diciembre, 2020). Población, total. [SP.POP.TOTL]. Recuperado de

    <https://datos.bancomundial.org/indicator/SP.POP.TOTL>

-   Banco Mundial (16 de diciembre, 2020). Inflación, precios al consumidor (% anual). [FP.CPI.TOTL.ZG]. Recuperado de

    <https://datos.bancomundial.org/indicator/FP.CPI.TOTL.ZG>
