import os
import sys
import joblib

import pandas as pd
from sklearn.preprocessing import StandardScaler

# Ruta al archivo del modelo
modelo_path = os.path.join(os.getcwd() + '/app/', 'modelo_fraudev3.pkl')

# Cargar el modelo si existe
if os.path.exists(modelo_path):
    modelo = joblib.load(modelo_path)
else:
    print(f"Archivo de modelo no encontrado. Path: {modelo_path}")
    sys.exit(1)

# Inicializar el escalador
escalador = StandardScaler()

# Definir las columnas necesarias (las que se usaron para entrenar el modelo)
columnas_modelo = [
        'income', 'name_email_similarity',
       'current_address_months_count', 'customer_age', 'days_since_request',
       'bank_branch_count_8w', 'date_of_birth_distinct_emails_4w',
       'credit_risk_score', 'email_is_free', 'phone_home_valid',
       'phone_mobile_valid', 'bank_months_count', 'has_other_cards',
       'proposed_credit_limit', 'foreign_request', 'session_length_in_minutes',
       'keep_alive_session', 'device_distinct_emails_8w', 'payment_type_AA',
       'payment_type_AB', 'payment_type_AC', 'payment_type_AD',
       'payment_type_AE', 'employment_status_CA', 'employment_status_CB',
       'employment_status_CC', 'employment_status_CD', 'employment_status_CE',
       'employment_status_CF', 'employment_status_CG', 'housing_status_BA',
       'housing_status_BB', 'housing_status_BC', 'housing_status_BD',
       'housing_status_BE', 'housing_status_BF', 'housing_status_BG',
       'source_INTERNET', 'source_TELEAPP', 'device_os_linux',
       'device_os_macintosh', 'device_os_other', 'device_os_windows',
       'device_os_x11'
]

def preparar_dataframe(df: pd.DataFrame):
    # Verificar si las columnas requeridas están en el DataFrame
    faltantes = [col for col in columnas_modelo if col not in df.columns]
    if faltantes:
        return None, f"Faltan las siguientes columnas: {', '.join(faltantes)}"
    
    df_filtrado = df[columnas_modelo].copy()
    return df_filtrado, None

def preprocesar_datos(data_df):
    data_df_normalizado = escalador.fit_transform(data_df)
    return pd.DataFrame(data_df_normalizado, columns=data_df.columns)