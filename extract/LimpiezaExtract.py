import pandas as pd

class LimpiezaExtract:  

    def __init__(self, file_path):
        self.file_path = file_path
        self.data = None

    def queries(self):
        # Soporta CSV y Excel (XLS/XLSX) de forma transparente
        try:
            lower_path = str(self.file_path).lower()
            if lower_path.endswith(('.xlsx', '.xls')):
                self.data = pd.read_excel(self.file_path)
            elif lower_path.endswith('.csv'):
                try:
                    self.data = pd.read_csv(self.file_path, encoding='utf-8', low_memory=False)
                except UnicodeDecodeError:
                    try:
                        self.data = pd.read_csv(self.file_path, encoding='cp1252', low_memory=False)
                    except Exception:
                        self.data = pd.read_csv(self.file_path, encoding='latin-1', low_memory=False)
            else:
                raise ValueError('Formato no soportado. Usa .csv, .xls o .xlsx')
        except Exception as e:
            raise RuntimeError(f"No se pudo leer el archivo '{self.file_path}': {e}")

    def response(self):
        return self.data.head(5)
    
    def info(self):
        return self.data.info()