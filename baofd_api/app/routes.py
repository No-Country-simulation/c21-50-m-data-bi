import os
import pandas as pd

from flask import Blueprint, request, jsonify
from .model import modelo, preparar_dataframe, preprocesar_datos

main = Blueprint('main', __name__)

@main.route('/')
def home():
    return "API de detección de fraudes está activa"

@main.route('/predict', methods=['POST'])
def predict():
    if 'file' not in request.files:
        return jsonify({'error': 'No hay parte de archivo en la solicitud'}), 400
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'Archivo no cargado'}), 400
    
    try:
        data_df = pd.read_csv(file)
    except Exception as e:
        return jsonify({'error': f'Error al leer el archivo CSV: {str(e)}'}), 400

    data_df_preparado, error = preparar_dataframe(data_df)
    if error:
        return jsonify({'error': error}), 400

    data_df_preprocesado = preprocesar_datos(data_df_preparado)

    prediccion = modelo.predict(data_df_preprocesado)
    resultados_df = pd.DataFrame(data={'predicciones': prediccion})

    output_folder = 'resultados'
    os.makedirs(output_folder, exist_ok=True)

    original_filename = os.path.splitext(file.filename)[0]
    output_file_name = f"resultado_{original_filename}.csv"
    output_file_path = os.path.join(output_folder, output_file_name)

    resultados_df.to_csv(output_file_path, index=False)

    return jsonify({'message': 'Predicciones guardadas en CSV', 'output_file': output_file_name})