# 📊 Proyecto de Data Cleaning - MySQL


## 📌 Contenido  

1. [Descripción](#Descripción)  
2. [Objetivo](#Objetivo)  
3. [Proceso de limpieza paso a paso](#Proceso-de-limpieza-paso-a-paso)  
   - [PASO 1: Eliminación de Duplicados](#paso-1-eliminación-de-duplicados)  
   - [PASO 2: Estandarización de Datos](#paso-2-estandarización-de-datos)  
   - [PASO 3: Manejo de valores nulos](#paso-3-manejo-de-valores-nulos)  
   - [PASO 4: Eliminación de datos NULL y columnas innecesarias](#paso-4-eliminación-de-datos-null-y-columnas-innecesarias)  
4. [Resultado final](#-resultado-final)  
  
---

## Descripción
Este proyecto muestra cómo **limpiar y preparar una base de datos usando solo SQL**, tal como se hace en escenarios reales de trabajo.  
El dataset original contenía errores comunes como **duplicados, valores vacíos, formatos inconsistentes y columnas innecesarias**.

Durante el proceso se aplicaron pasos clave como:
- **Eliminación de duplicados**  
- **Tratamiento de valores nulos**  
- **Normalización de datos**  
- **Reestructuración de la tabla final**  

Con esto, se obtiene un **dataset confiable y ordenado**, listo para usar en herramientas como **Tableau, Power BI o en modelos de Machine Learning**.

🛠️ **Tecnología usada:** `SQL`  
📊 **Uso práctico:** Dejar los datos **limpios y listos para análisis, visualización o predicción**.



## **Objetivo** 
El objetivo de este proyecto es **mostrar cómo transformar un conjunto de datos desordenado en una base limpia, estructurada y útil para análisis**.

Esto incluye:
- **Detectar y corregir errores** en los datos.
- **Estandarizar campos** para lograr consistencia.  
- Asegurar que la tabla final sea **clara, funcional y reutilizable**.


Es un ejemplo práctico de cómo se trabaja con datos reales en cualquier puesto relacionado con **Data Analysis**, **Business Intelligence** o **Data Engineering**.

--- 

## Proceso de limpieza paso a paso

### 📂 Dataset original

A continuación se muestra una vista previa del dataset recibido:

![Vista Dataset](images/image-26.png)

### 📏 Dimensión del dataset

El conjunto de datos original cuenta con una cantidad significativa de registros y columnas, lo cual hace aún más importante asegurar su calidad antes de analizarlo:

![Dimension Dataset](images/image-1.png)

---

## Creación de una tabla de trabajo

Antes de iniciar el proceso de limpieza, se crea una **tabla de trabajo** a partir del dataset original.  
Esta es una buena práctica común en entornos profesionales de análisis de datos, ya que permite trabajar de forma segura, ordenada y sin comprometer la información original.

Se realiza una copia exacta de la estructura y los datos de la tabla `company_layoffs`, creando una nueva tabla llamada `company_layoffs_cleaned`, sobre la cual se aplicarán todas las transformaciones necesarias.

![Copia de tabla](images/image-2.png)

### Ventajas de trabajar con una copia

- **Preservar la fuente de datos original** ante cualquier error o pérdida de información.  
- **Probar distintas técnicas de limpieza** sin afectar el dataset base.  
- **Permitir retrocesos y ajustes rápidos** si se detectan problemas durante el proceso.

---

## PASO 1: Eliminación de Duplicados

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



## **PASO 2: Estandarización de Datos**

### Eliminación de espacios en blanco

Análisis de la Columna `company`

Para garantizar coherencia en los nombres de las compañías, se aplica `TRIM()`, que elimina espacios en blanco al inicio y al final de cada valor en la columna `company`. 

- `TRIM()` elimina espacios en blanco (del principio o del final de la columna `company`).

![image.png](image%2011.png)

📌 **Estado del Dataset tras la estandarización**

Después de eliminar espacios en blanco y estandarizar los nombres de la columna `company`, el dataset ya presenta una mayor uniformidad y calidad para su análisis.

![image.png](image%2012.png)

### Análisis de la Columna `industry`

### **Problemas detectados en la columna `industry`**

**1️⃣ Valores vacíos: Algunas filas tienen `NULL`, lo que puede afectar el análisis. (VACIOS O NULL?)**

📷 **Ejemplo de valores nulos en `industry`** 

![image.png](image%2013.png)

![image.png](image%2014.png)

**Solución aplicada:**

- Se completan valores `NULL` en `industry` utilizando información de la misma empresa cuando está disponible. En este caso para `company` se tiene la industria `Travel` . Por lo que se completa con ese mismo dato a la fila con valor **VACÍO**.
- En caso de no contar con datos suficientes, los valores permanecen como `NULL` para evitar asumir información incorrecta.

✔ **Beneficio:** Se mejora la calidad del dataset, reduciendo la pérdida de datos sin introducir sesgos.

2️⃣ **Inconsistencias en los nombres**

Existen variaciones en la misma industria (ej. distintas versiones de "Crypto"), lo que requiere normalización.

**📌 Antes de la Estandarización de `industry`**

🔍 Se observan valores inconsistentes en la columna `industry`, con variaciones en nombres que deberían representar la misma categoría.

![image.png](image%2015.png)

**📌 Después de la estandarización de `industry`**

✅ Se unificaron los nombres de las industrias para evitar inconsistencias y mejorar la calidad del análisis. Ahora, todas las variaciones de una misma categoría se agrupan bajo un único nombre estándar.

![image.png](image%2016.png)

### Análisis de la Columna `country`

✅ Se eliminaron caracteres innecesarios y se unificó la nomenclatura de los países para evitar registros inconsistentes.

![image.png](image%2017.png)

### **📌 Análisis de la Columna `date`**

- La columna `date` estaba almacenada como texto, lo que dificultaba su manipulación y análisis.
- Se convirtió al formato `DATE` utilizando `STR_TO_DATE()`, permitiendo operaciones como filtrado por rango de fechas o cálculos temporales.

📷 **Antes de la conversión (`company_layoffs_cleaned2`):**

![image.png](image%2018.png)

📷 **Después del `UPDATE` en `date` :**

![image.png](image%2019.png)

Luego de ejecutar `ALTER TABLE`, la columna `date` cambia de tipo `TEXT` a `DATE`, asegurando su correcto tratamiento en consultas temporales y facilitando análisis como filtros por fecha o cálculos de intervalos.

![image.png](image%2020.png)

✅ **Resultado:** `date` ahora está en un formato adecuado para operaciones analíticas y reportes. 

## PASO 3: Manejo de valores nulos

En esta etapa, identificamos y tratamos los valores faltantes en la columna `industry`.

- **Valores VACÍOS en `industry`**: Se reemplazan los valores vacíos con `NULL`, ya que esto permite un mejor manejo de datos en consultas SQL posteriores.

![image.png](image%2021.png)

Para completar los valores faltantes en la columna `industry`, realizamos un **JOIN** con los registros existentes de la misma compañía. De esta forma, si una empresa ya tiene una industria asociada en otra fila, se copia ese valor en las filas donde `industry` es `NULL`.

![image.png](image%2022.png)

Después de realizar el `JOIN`, ejecutamos un `SELECT` para comprobar que los valores de la columna `industry` han sido correctamente asignados a las compañías que tenían valores nulos.

![image.png](image%2023.png)

Después de aplicar el `UPDATE`, la columna `industry` ha sido actualizada correctamente. Ahora, todas las compañías tienen una industria asignada cuando era posible inferirla a partir de registros existentes.

![image.png](image%2024.png)

## PASO 4: Eliminación de datos NULL y columnas innecesarias

En esta etapa, refinamos la base de datos eliminando información que no aporta valor significativo para el análisis final.

E**liminación de datos NULL ( `total_laid_off` y `percentage_laid_off`):** Se eliminan las filas donde `total_laid_off` y `percentage_laid_off` no contienen datos. Aunque podríamos conservarlas, su ausencia genera incertidumbre en el análisis y puede afectar la calidad de las conclusiones.

![image.png](image%2025.png)

### **📌 Razones para eliminar estas filas**

✅ **Datos incompletos y sesgo en el análisis:** La falta de valores en variables clave como `total_laid_off` y `percentage_laid_off` impide obtener una visión clara del impacto de los despidos en cada empresa. Si estas filas permanecen, podrían generar sesgos o interpretaciones erróneas.

✅ **Dificultad para la imputación:** No contamos con información suficiente para completar estos datos de manera confiable. Métodos como la imputación por promedio o mediana podrían distorsionar los resultados.

✅ **Impacto en visualizaciones y modelos predictivos:** Mantener datos nulos en métricas clave podría afectar gráficos, dashboards y modelos de Machine Learning, ya que algunas herramientas no manejan bien los valores faltantes.

### **Eliminación de la columna `row_num`**

La columna `row_num` fue utilizada exclusivamente para depuración y ordenamiento temporal durante la limpieza de datos.

En la versión final del dataset, ya no aporta información relevante para el análisis.

Su permanencia solo incrementaría el tamaño del dataset sin un beneficio real.

### **📌 Razones para eliminar esta columna**

✅ **Evitar redundancia y reducir espacio:** Esta columna no tiene valor analítico y solo ocupa espacio en memoria.

✅ **Mejorar eficiencia en consultas:** Al eliminar columnas innecesarias, las consultas SQL son más rápidas y eficientes.

✅ **Facilitar exportación y visualización:** Un dataset más limpio y compacto es más fácil de manejar en herramientas como Tableau, Power BI o Pandas.

## **📊 Resultado Final**

Después de aplicar el proceso de limpieza y transformación, obtenemos un dataset optimizado para análisis.

✔ **Base de datos sin duplicados ni errores:** Se eliminaron inconsistencias y registros redundantes.

✔ **Formato homogéneo y estructurado:** Los datos fueron normalizados para facilitar consultas y visualización.

✔ **Mayor calidad y confiabilidad:** Se redujo la cantidad de valores nulos y se optimizó la estructura de la base de datos.

📎 **🔗 Código completo:** [`data_cleaning.sql`](https://www.notion.so/Data-Cleaning-MySQL-Full-Project-1ac30b66251980089dffda3ae4cf6f72?pvs=21)

📌 *Este proceso es fundamental en cualquier análisis de datos, asegurando información precisa y lista para visualización, reporting y modelado predictivo. 🚀*