# Usar la imagen oficial de PaddleOCR como base
FROM paddlepaddle/paddleocr:latest

# Variable de entorno para almacenar modelos descargados
ENV PADDLE_HOME=/root/.paddleocr

# Instalar OmniMRZ y asegurar que paddleocr está presente
RUN pip install omnimrz paddleocr --no-cache-dir

# Verificar que la instalación fue exitosa
RUN python -c "import omnimrz; print('OmniMRZ installed successfully')"

# Comando por defecto al ejecutar el contenedor
CMD ["python"]
