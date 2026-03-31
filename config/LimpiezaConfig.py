from pathlib import Path

class LimpiezaConfig:
    """
    Clase de configuración para rutas y parámetros del ETL.
    """

    BASE_DIR = Path(__file__).parent.parent
    DATA_DIR = BASE_DIR / 'extract' / 'files'
    SQLITE_DB_PATH = DATA_DIR / 'Limpieza.db'
    SQLITE_TABLE = 'siniestros_limpios'
    # Rutas relativas basadas en el directorio base del proyecto
    INPUT_PATH = str(DATA_DIR / '3.1 NMERO DE SINIESTROS.XLSX')
    OUTPUT_PATH = str(DATA_DIR / '3.1 NMERO DE SINIESTROS_limpio.csv')
    OUTPUT_XLSX_PATH = str(DATA_DIR / '3.1 NMERO DE SINIESTROS_limpio.xlsx')
    