import pandas as pd
from typing import Union, List


MISSING_TEXT_VALUES = {
	'',
	'n/a',
	'na',
	'sin dato',
	's/d',
	'null',
	'none'
}


def _read_source_safe(path: str) -> pd.DataFrame:
	"""Lee CSV o Excel según la extensión del archivo."""
	lower_path = str(path).lower()
	if lower_path.endswith(('.xlsx', '.xls')):
		return pd.read_excel(path)
	if lower_path.endswith('.csv'):
		try:
			return pd.read_csv(path, encoding='utf-8', low_memory=False)
		except UnicodeDecodeError:
			try:
				return pd.read_csv(path, encoding='cp1252', low_memory=False)
			except Exception:
				return pd.read_csv(path, encoding='latin-1', low_memory=False)
	raise ValueError('Formato no soportado. Usa .csv, .xls o .xlsx')


def _clean_empty_rows(df: pd.DataFrame, drop_fully_empty_columns: bool = False) -> pd.DataFrame:
	"""Limpia filas vacias considerando espacios y placeholders textuales como nulos."""
	clean_df = df.copy()

	object_cols = clean_df.select_dtypes(include=['object']).columns
	if len(object_cols) > 0:
		for col in object_cols:
			clean_df[col] = clean_df[col].where(clean_df[col].isna(), clean_df[col].astype(str).str.strip())
			clean_df[col] = clean_df[col].where(
				clean_df[col].isna(),
				clean_df[col].astype(str).str.lower().str.replace(r'\s+', ' ', regex=True).str.strip()
			)
			clean_df.loc[clean_df[col].isin(MISSING_TEXT_VALUES), col] = pd.NA

	clean_df = clean_df.dropna(axis=0, how='all')
	if drop_fully_empty_columns:
		clean_df = clean_df.dropna(axis=1, how='all')

	return clean_df.reset_index(drop=True)


def _find_column_case_insensitive(columns: List[str], target_name: str) -> Union[str, None]:
	"""Busca una columna por nombre ignorando mayúsculas/minúsculas y espacios extremos."""
	target_normalized = target_name.strip().lower()
	for col in columns:
		if str(col).strip().lower() == target_normalized:
			return col
	return None


def _normalize_top_text(s: object) -> str:
	"""Normalización simple para textos de Top*: convierte a str, reemplaza &amp;, lowercase, trim y colapsa espacios."""
	if pd.isna(s):
		return ''
	s2 = str(s)
	s2 = s2.replace('&amp;', '&')
	s2 = s2.replace('\u2019', "'")
	s2 = s2.lower().strip()
	s2 = ' '.join(s2.split())
	return s2


class LimpiezaTransform:
	"""Versión simple de transform: parseo de fechas, tipos y filtrado básico."""

	def __init__(self, df: pd.DataFrame):
		self.df = df.copy()

	def verificar_nulos_ceros(self) -> pd.DataFrame:
		nulos = self.df.isnull().sum()
		ceros = (self.df == 0).sum()
		return pd.DataFrame({'Nulos': nulos, 'Ceros': ceros})

	def clean_basic(self, drop_rows_without_date: bool = True, drop_rows_without_any_top: bool = False, label_fill: int = -1, normalize_top: bool = True, deduplicate: bool = True) -> pd.DataFrame:
		"""
		Limpieza básica:
		- Convierte `Date` a datetime.
		- Convierte `Label` a entero rellenando NaN con `label_fill`.
		- Opcional: elimina filas sin `Date`.
		- Opcional: elimina filas donde todas las columnas Top1..Top25 están vacías.
		- Normaliza texto en Top columns y deduplica por Date+Top* si se solicita.
		"""
		df = self.df.copy()

		if 'Date' in df.columns:
			df['Date'] = pd.to_datetime(df['Date'], errors='coerce')

		if 'Label' in df.columns:
			df['Label'] = pd.to_numeric(df['Label'], errors='coerce').fillna(label_fill).astype(int)

		if drop_rows_without_date and 'Date' in df.columns:
			df = df.dropna(subset=['Date'])

		top_cols = [f'Top{i}' for i in range(1, 26) if f'Top{i}' in df.columns]
		if drop_rows_without_any_top and top_cols:
			df = df.dropna(subset=top_cols, how='all')

		# Normalizar textos de Top columns
		if normalize_top and top_cols:
			for c in top_cols:
				df[c] = df[c].apply(_normalize_top_text)

		# Deduplicado por Date + Top columns (si se solicita)
		if deduplicate and top_cols:
			subset = ['Date'] + top_cols if 'Date' in df.columns else top_cols
			df = df.drop_duplicates(subset=subset, keep='first')

		return df.reset_index(drop=True)


def full_clean_stock_sentiment(source: Union[str, pd.DataFrame], drop_rows_without_date: bool = True, drop_rows_without_any_top: bool = False, label_fill: int = -1, normalize_top: bool = True, deduplicate: bool = True) -> pd.DataFrame:
	"""
	Versión simplificada de la limpieza: carga (si se pasa path), aplica clean_basic y devuelve el DataFrame limpio.
	Mantiene las columnas Top1..Top25 tal cual están en el CSV original.
	"""
	if isinstance(source, str):
		df = _read_source_safe(source)
	elif isinstance(source, pd.DataFrame):
		df = source.copy()
	else:
		raise ValueError('source debe ser ruta a CSV o un pd.DataFrame')

	lt = LimpiezaTransform(df)
	df_clean = lt.clean_basic(drop_rows_without_date=drop_rows_without_date, drop_rows_without_any_top=drop_rows_without_any_top, label_fill=label_fill, normalize_top=normalize_top, deduplicate=deduplicate)

	# resumen
	df_clean.attrs['cleaning_summary'] = {
		'original_rows': len(df),
		'final_rows': len(df_clean)
	}

	return df_clean


def full_clean_siniestros(source: Union[str, pd.DataFrame], drop_fully_empty_columns: bool = False) -> pd.DataFrame:
	"""
	Limpia un dataset de siniestros eliminando filas totalmente vacias.
	Adicionalmente elimina filas donde localidad y upl estén vacíos o con placeholders
	(textos como N/A, NA o SIN DATO).
	Acepta ruta (CSV/XLS/XLSX) o DataFrame y devuelve DataFrame limpio.
	"""
	if isinstance(source, str):
		df = _read_source_safe(source)
	elif isinstance(source, pd.DataFrame):
		df = source.copy()
	else:
		raise ValueError('source debe ser ruta a CSV/XLSX o un pd.DataFrame')

	clean_df = _clean_empty_rows(df, drop_fully_empty_columns=drop_fully_empty_columns)

	localidad_col = _find_column_case_insensitive(list(clean_df.columns), 'localidad')
	upl_col = _find_column_case_insensitive(list(clean_df.columns), 'upl')

	removed_by_localidad_upl = 0
	if localidad_col and upl_col:
		before_len = len(clean_df)
		clean_df = clean_df[~(clean_df[localidad_col].isna() & clean_df[upl_col].isna())]
		removed_by_localidad_upl = before_len - len(clean_df)
		clean_df = clean_df.reset_index(drop=True)

	clean_df.attrs['cleaning_summary'] = {
		'original_rows': len(df),
		'final_rows': len(clean_df),
		'removed_rows': len(df) - len(clean_df),
		'removed_rows_localidad_upl_empty': removed_by_localidad_upl
	}

	return clean_df