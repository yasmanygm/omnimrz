FROM python:3.9-slim-bookworm

# Instalar dependencias del sistema necesarias para OpenCV y PaddleOCR
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Instalar PaddlePaddle 3.0.0 (CPU con AVX - ajusta según tu hardware)
RUN python3 -m pip install paddlepaddle==3.0.0 -f https://www.paddlepaddle.org.cn/whl/linux/mkl/avx/stable.html

# Instalar OmniMRZ y PaddleOCR usando el mismo intérprete
RUN python3 -m pip install --force-reinstall omnimrz paddleocr --no-cache-dir

# Verificar que el módulo se importa correctamente
RUN python3 -c "import sys; print('Python path:', sys.path)" && \
    python3 -c "import omnimrz; print('OmniMRZ installed successfully')"

CMD ["python3"]
