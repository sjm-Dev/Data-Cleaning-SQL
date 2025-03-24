# 📊 Data Cleaning Project - MySQL

## About the project

This project was developed as a complete data cleaning practice using SQL, simulating a real-world scenario working with raw information.The goal was to apply best practices for cleaning, standardization, and validation, focusing on the quality and usefulness of the final data.

🔗 **Full SQL Code:** [`data_cleaning.sql`](./data_cleaning.sql)

---


## 📌 Table of Contents

1. [Description](#Description)  
2. [Objective](#Objective)  
3. [Step-by-step cleaning process](#Step-by-step-cleaning-process)  
   - [STEP 1: Duplicate Removal](#Step-1-duplicate-removal) 
   - [STEP 2: Data Standardization](#Step-2-data-standardization)  
   - [STEP 3: Handling Null Values](#Step-3-handling-null-values)  
   - [STEP 4: Deleting Null Records and Unnecessary Columns](#Step-4-deleting-null-records-and-unnecessary-columns)  
4. [Final Result](#Final-result)
5. [Possible Improvements](#Possible-improvements)  
  
---

## Description
This project demonstrates how to clean and prepare a database using only SQL, just like in real-world environments.The original dataset contained common issues such as duplicates, empty values, inconsistent formats, and unnecessary columns.

Key steps applied during the process:

- Duplicate removal
- Handling null values
- Data normalization
- Final table restructuring

As a result, we obtained a reliable and organized dataset, ready to be used in tools like Tableau, Power BI, or predictive models.

🛠️ Technology used: SQL.
📊 Use case: Ensuring data is clean and ready for analysis, visualization, or prediction.

---

## **Objective** 
The goal of this project is to show how to transform a messy dataset into a clean, structured, and analysis-ready one.

This includes:

- Identifying and fixing errors in the data.
- Standardizing fields for consistency.  
- Ensuring the final table is clear, functional, and reusable.

It is a practical example of how real-world data is prepared in roles related to **Data Analysis**, **Business Intelligence** or **Data Engineering**.

--- 

## Step-by-step cleaning process

### 📂 Original Dataset

Here is a preview of the original dataset:

![Vista Dataset](images/image-26.png)

### 📏 Dataset Dimensions

The original dataset contains a significant number of records and columns, which makes ensuring its quality even more important before starting the analysis:

![Dimension Dataset](images/image-1.png)

---

## Creating a Working Table

Before starting the cleaning process, a working table was created from the original dataset.This is a common best practice in professional data analysis environments, as it allows for safe and orderly work without compromising the original information.

An exact copy of the structure and data from the `company_layoffs` table was made, creating a new table named `company_layoffs_cleaned`, where all necessary transformations were applied.

![Copia de tabla](images/image-2.png)

### Benefits of working with a copy

- **Preservar la fuente de datos original** ante cualquier error o pérdida de información.  
- **Probar distintas técnicas de limpieza** sin afectar el dataset base.  
- **Permitir retrocesos y ajustes rápidos** si se detectan problemas durante el proceso.

---

## STEP 1: Duplicate Removal

Los datos duplicados pueden distorsionar análisis y visualizaciones, generando **resultados incorrectos o inconsistencias**. Para evitar esto, el primer paso del proceso consistió en identificar y eliminar registros repetidos.

### Identificación de duplicados

- Se utilizó la función `ROW_NUMBER()` para asignar un número secuencial a cada fila, agrupando por columnas clave.
- El objetivo fue detectar registros duplicados y conservar solo uno, eliminando aquellos con `row_num > 1`.

Visualización de filas duplicadas identificadas:

![Duplicados identificados](images/image-3.png)

Ejemplo específico de duplicados para la compañía `Oda`:

![Duplicados Oda](images/image-4.png)  

---

### Dificultades al eliminar duplicados

Durante el proceso, se intentó eliminar los registros duplicados directamente desde una CTE que utilizaba `ROW_NUMBER()`.

![DELETE cte](images/image-5.png)

Sin embargo, MySQL arrojó el siguiente error:

**Error 1288:** 
*"The target table of the DELETE is not updatable."*

![Error 1288](images/image-6.png)

**Causa técnica:**  
MySQL no permite realizar operaciones de eliminación (`DELETE`) directamente sobre tablas derivadas como las CTE (Common Table Expressions), ya que no son actualizables.

**Solución aplicada:**  
Para resolver este inconveniente:

- Se creó una nueva tabla llamada `company_layoffs_cleaned2`, replicando los datos existentes.
- A esta tabla se le agregó manualmente la columna `row_num` como un campo de tipo `INT`.
- Con esta estructura, será posible ejecutar el `DELETE` sin restricciones y eliminar correctamente los registros duplicados.

![Codigo tabla nueva](images/image-8.png)
  
---

### Eliminación final de duplicados

Una vez creada `company_layoffs_cleaned2`, se eliminaron todas las filas con `row_num > 1`.

Visualización previa a la eliminación:

![Registros a eliminar](images/image-9.png)

Resultado final tras eliminar duplicados:

![Dataset sin duplicados](images/image-10.png)



## **STEP 2: Data Standardization**

### Limpieza de espacios en blanco — Columna `company`

Para garantizar la coherencia en los nombres de las compañías, se aplicó la función `TRIM()`, que elimina los espacios en blanco al inicio y al final de los valores.

Esto evita inconsistencias como registros duplicados por pequeñas diferencias invisibles:

Por ejemplo: `" E Inc."` vs `"E Inc."`

![Aplicación de TRIM](images/image-11.png)

**Estado del dataset tras la estandarización:**

Luego de aplicar `TRIM()`, los nombres de la columna `company` presentan una mayor uniformidad y calidad para el análisis.

![Company limpia](images/image-12.png)

---

### Análisis de la columna `industry`

#### Problema 1: Valores vacíos o `NULL`

Se detectaron varias filas con valores faltantes en la columna `industry`. Esto puede afectar análisis agrupados o categorizaciones por rubro.

📷 Ejemplo de registros con valores nulos:

![NULL en industry 1](images/image-13.png)  

![NULL en industry 2](images/image-14.png)

**Solución aplicada:**

- Se completaron los valores `NULL` utilizando información de otras filas de la misma empresa (por ejemplo: si `Airbnb` tiene "Travel" en otra fila, se replica ese valor).
- Si no se encontró información confiable, se dejó el campo como `NULL` para evitar introducir datos incorrectos.

✔ **Resultado:** Reducción de valores nulos sin forzar datos ni introducir sesgos.

---

#### Problema 2: Inconsistencias en los nombres

Se identificaron variantes en los nombres de industrias que, aunque diferentes, representaban la misma categoría (ej: "Crypto", "crypto", "Cryptocurrency").

**Antes de la estandarización:**

![Industry inconsistente](images/image-15.png)

**Después de la estandarización:**

![Industry limpia](images/image-16.png)

✅ Todos los valores fueron unificados bajo un criterio común para garantizar consistencia en los análisis.

---

### Análisis de la columna `country`

Se eliminaron caracteres innecesarios y se estandarizaron los nombres de países para evitar registros duplicados con distintas formas de escritura.

Por ejemplo: `"United States"` vs `"United States."`

![Países estandarizados](images/image-17.png)

---

### Conversión de la columna `date` a formato fecha

Originalmente, la columna `date` estaba en formato `TEXT`, lo que impedía realizar operaciones como filtrado por fechas o análisis temporal.

Se utilizó la función `STR_TO_DATE()` para convertir los valores y posteriormente se cambió el tipo de dato con `ALTER TABLE`.

📷 **Conversión:**
En la columna izquierda se muestra el formato por defecto de la variable `date`, mientras que en la columna de al lado se muestra la conversión hecha.

![Date antes](images/image-18.png)

📷 **Después del `UPDATE`:**

![Date después del update](images/image-19.png)

📷 **Cambio de tipo de columna:**

![Tipo cambiado a DATE](images/image-20.png)

✅ **Resultado final:** `date` ahora está en un formato adecuado para análisis cronológicos y reportes dinámicos.



## STEP 3: Handling Null Values

En esta etapa se identificaron y trataron los valores faltantes en la columna `industry`, con el objetivo de mejorar la calidad general del dataset y facilitar consultas más limpias.

![Valores vacíos a NULL](images/image-21.png)

### Reemplazo de valores vacíos

Primero, se reemplazaron los valores vacíos (cadenas vacías) por `NULL`. Esto permite manejar de forma más eficiente los datos faltantes en SQL, ya que las funciones y filtros están preparados para interpretar `NULL`, pero no espacios vacíos.

---

### Completado de valores nulos mediante JOIN

Luego, se intentó completar los valores `NULL` en `industry` tomando como referencia otras filas de la misma empresa que sí tenían ese dato.

Se realizó un `JOIN` entre registros de igual contenido de la columna `company`, copiando el valor existente de `industry` en los casos donde faltaba.

📌 Este enfoque evita cargar datos arbitrarios y mantiene la lógica interna del dataset.

![JOIN aplicado](images/image-22.png)

---

### Verificación del resultado

Después de realizar el `JOIN`, se ejecutó un `SELECT` para verificar que los valores hayan sido correctamente completados en las filas correspondientes.

![Verificación del SELECT](images/image-23.png)

---

### Final Result

Tras aplicar el `UPDATE`, la columna `industry` quedó actualizada. Todas las compañías, `company`, tienen una industria asignada **cuando fue posible inferirla con certeza** a partir de los datos existentes. En este caso, lo que se hizo con el `JOIN` es que para las filas de la companía `Airbnb` se asigna la misma industria `Travel`.

![Industry final actualizada](images/image-24.png)


## STEP 4: Deleting Null Records and Unnecessary Columns

En esta etapa, se refina el dataset eliminando información que no aporta valor al análisis final. Esto ayuda a mejorar la calidad, la eficiencia y la interpretabilidad del conjunto de datos.

---

### Eliminación de filas con datos faltantes `total_laid_off` y `percentage_laid_off` (condición 'AND')

Se eliminaron todas las filas donde las columnas `total_laid_off` y `percentage_laid_off` estaban vacías. Aunque podrían haberse conservado, su ausencia genera incertidumbre en el análisis y puede distorsionar los resultados.

Antes de la eliminación de filas nulas:
![Filas con valores nulos](images/image-25.png)
	
Luego de la eliminación de filas nulas:
![Filas sin valores nulos](images/image-26.png)


#### ¿Por qué eliminarlas?

- ✅ **Datos incompletos y riesgo de sesgo:** Estas variables son clave para entender el impacto de los despidos. Mantenerlas vacías debilita cualquier análisis basado en ellas.
- ✅ **Imputación poco confiable:** No hay suficiente contexto para completar los valores sin alterar la integridad del dataset.
- ✅ **Impacto negativo en visualizaciones y modelos:** Algunos dashboards o modelos de Machine Learning no manejan bien los valores `NULL`, lo que puede generar errores o resultados inconsistentes.

---

### Eliminación de la columna `row_num`

La columna `row_num` fue creada exclusivamente para fines de depuración durante los pasos anteriores (por ejemplo, para identificar duplicados). Una vez finalizado ese proceso, dejó de ser útil para el análisis.

#### ¿Por qué eliminarla?

- ✅ **Evitar redundancia:** No aporta información analítica relevante.
- ✅ **Reducir tamaño y limpiar estructura:** Eliminar columnas innecesarias mejora el rendimiento de consultas y simplifica la visualización.
- ✅ **Facilita la exportación a otras herramientas:** Un dataset más liviano es más eficiente para trabajar en Tableau, Power BI, Pandas, etc.

---

## 📊 Resultado Final

Después de aplicar todo el proceso de limpieza y transformación, se obtuvo un dataset **estructurado, confiable y listo para análisis**.

✔ **Sin duplicados ni errores:** Se eliminaron registros redundantes y filas inconsistentes.  
✔ **Formato homogéneo:** Los datos fueron normalizados y las columnas estandarizadas.  
✔ **Mayor calidad y precisión:** Se redujeron valores nulos y se optimizó la estructura general de la base de datos.

*Este tipo de limpieza es una etapa clave en cualquier pipeline de datos, y garantiza una base sólida para visualizaciones, reporting o desarrollo de modelos predictivos.*

📎 **Código completo del proceso:** [`data_cleaning.sql`](https://www.notion.so/Data-Cleaning-MySQL-Full-Project-1ac30b66251980089dffda3ae4cf6f72?pvs=21)

---

## Possible Improvements

Aunque el dataset quedó limpio y utilizable, en un entorno real podrían aplicarse mejoras adicionales como:

- Automatizar procesos con scripts SQL parametrizados.  
- Validar entradas con reglas de integridad o triggers.  
- Cruzar el dataset con fuentes externas para completar valores faltantes.  
- Integrar la limpieza en un pipeline ETL más amplio.

💡 *Una demostración práctica de cómo aplicar SQL para resolver problemas reales de datos, con criterio técnico y atención al detalle.*