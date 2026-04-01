# Usar imagen oficial de PaddlePaddle desde registro de Baidu
FROM ccr-2vdh3abv-pub.cnc.bj.baidubce.com/paddlepaddle/paddle:3.0.0

# Variable de entorno para almacenar modelos descargados
ENV PADDLE_HOME=/root/.paddleocr

# Actualizar pip e instalar dependencias necesarias
RUN pip install --upgrade pip

# Instalar OmniMRZ y PaddleOCR
RUN pip install omnimrz paddleocr --no-cache-dir

# Verificar instalación
RUN python -c "import omnimrz; print('OmniMRZ installed successfully')"

CMD ["python"]
