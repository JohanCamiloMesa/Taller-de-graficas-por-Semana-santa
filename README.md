# Analisis de Datos de Siniestros - Taller de Graficas

Proyecto para limpiar un archivo de siniestros con Python y explorar los datos con graficas en R. El flujo principal genera una version depurada del dataset y despues la usa en un taller de analisis visual.

## Descripcion general

El repositorio contiene tres piezas principales:

- Un pipeline ETL en Python que lee un archivo Excel o CSV, limpia filas vacias y exporta resultados a CSV, Excel y SQLite.
- Un script en R para el taller principal, con 5 graficas comentadas y una conclusion final.
- Un dashboard en R, opcional, para exploracion interactiva de los mismos datos.

La pregunta de analisis que guia el taller es identificar en que localidades y en que momentos se concentran los siniestros, y como cambia su severidad segun la hora y el dia de la semana.

## Estructura

```text
Taller-de-graficas-por-Semana-santa/
├── main.py
├── dashboard.r
├── graficas.r
├── taller.r
├── README.md
├── requeriments.txt
├── LICENSE
├── config/
│   └── LimpiezaConfig.py
├── extract/
│   ├── LimpiezaExtract.py
│   └── files/
│       ├── 3.1 NMERO DE SINIESTROS.XLSX
│       ├── 3.1 NMERO DE SINIESTROS_limpio.csv
│       ├── 3.1 NMERO DE SINIESTROS_limpio.xlsx
│       └── Limpieza.db
├── transform/
│   └── LimpiezaTransform.py
└── load/
    └── LimpiezaLoader.py
```

## Que hace cada archivo

`main.py` ejecuta el flujo completo: carga el archivo original, aplica la limpieza y guarda las salidas limpias.

`extract/LimpiezaExtract.py` lee archivos `.xlsx`, `.xls` o `.csv` y prueba varias codificaciones si el origen es CSV.

`transform/LimpiezaTransform.py` elimina filas completamente vacias, normaliza valores tipo `n/a`, `sin dato` o `null`, y deja un resumen de limpieza en `DataFrame.attrs['cleaning_summary']`.

`load/LimpiezaLoader.py` exporta el resultado a CSV, Excel y SQLite.

`taller.r` genera el analisis principal con 5 graficas:

1. Barras por localidad.
2. Lineas de evolucion mensual por ano.
3. Mapa de calor dia vs hora.
4. Boxplot de hora por gravedad.
5. Barras apiladas proporcionales de severidad por dia.

`graficas.r` es una galeria de ejemplos con varios tipos de graficas en R.

`dashboard.r` crea un dashboard interactivo con Shiny, Plotly y Leaflet.

## Requisitos

### Python

- Python 3.8 o superior
- pandas
- openpyxl

### R

- R 4.0 o superior
- ggplot2
- reshape2
- corrplot

### Para el dashboard opcional

- shiny
- shinydashboard
- dplyr
- plotly
- leaflet
- leaflet.extras

## Instalacion

### 1. Abrir el proyecto

```bash
cd "Taller-de-graficas-por-Semana-santa"
```

### 2. Crear y activar un entorno Python

```bash
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requeriments.txt
```

Si prefieres Conda:

```bash
conda create -n taller-graficas python=3.10
conda activate taller-graficas
pip install -r requeriments.txt
```

### 3. Instalar R

Descargalo desde https://www.r-project.org/ si no lo tienes instalado.

## Uso

### Ejecutar el ETL

```bash
python main.py
```

Esto genera estas salidas:

- `extract/files/3.1 NMERO DE SINIESTROS_limpio.csv`
- `extract/files/3.1 NMERO DE SINIESTROS_limpio.xlsx`
- `extract/files/Limpieza.db`

La tabla SQLite se guarda como `siniestros_limpios`.

### Ejecutar el taller en R

```bash
Rscript taller.r
```

### Ver la galeria de ejemplos

```bash
Rscript graficas.r
```

### Ejecutar el dashboard

```bash
Rscript dashboard.r
```

## Configuracion

Las rutas del ETL estan en `config/LimpiezaConfig.py`.

Los valores principales son:

```python
BASE_DIR = Path(__file__).parent.parent
DATA_DIR = BASE_DIR / 'extract' / 'files'
INPUT_PATH = str(DATA_DIR / '3.1 NMERO DE SINIESTROS.XLSX')
OUTPUT_PATH = str(DATA_DIR / '3.1 NMERO DE SINIESTROS_limpio.csv')
OUTPUT_XLSX_PATH = str(DATA_DIR / '3.1 NMERO DE SINIESTROS_limpio.xlsx')
SQLITE_DB_PATH = DATA_DIR / 'Limpieza.db'
SQLITE_TABLE = 'siniestros_limpios'
```

## Datos esperados

Las columnas exactas dependen del archivo original, pero el analisis en R usa campos como estos:

| Columna | Uso |
|---|---|
| `FECHA_OCUR` | Fecha del evento |
| `FECHA_HORA` | Fecha y hora del registro |
| `HORA_OCURR` | Hora del siniestro |
| `ANO_OCURRE` | Ano del siniestro |
| `MES_OCURRE` | Mes del siniestro |
| `DIA_OCURRE` | Dia de la semana |
| `LOCALIDAD` | Ubicacion geografica |
| `GRAVEDAD` | Categoria de severidad |
| `LATITUD` / `LONGITUD` | Coordenadas para el dashboard |
| `UPL` | Campo auxiliar usado en la limpieza |

## Hallazgos que resume el taller

El archivo `taller.r` concluye que los siniestros no se distribuyen de forma uniforme: hay concentracion territorial, franjas horarias criticas y dias con mayor peso relativo de casos severos. Eso permite priorizar recursos por localidad, dia y hora.

## Autor

Johan Camilo Mesa Rios

## Licencia

Este proyecto se distribuye bajo licencia MIT. Ver `LICENSE` para mas detalles.

## Nota final

1. Ejecuta primero `python main.py`.
2. Luego corre `taller.r` o `dashboard.r` sobre el CSV limpio.
3. `graficas.r` sirve como apoyo didactico con ejemplos adicionales.