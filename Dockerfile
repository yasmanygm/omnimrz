FROM python:3.9-slim-bookworm

# Dependencias del sistema necesarias para OpenCV y PaddleOCR
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Instalar PaddlePaddle (versión estable 2.6.2 con AVX)
RUN python -m pip install --no-cache-dir paddlepaddle==2.6.2 -f https://www.paddlepaddle.org.cn/whl/linux/mkl/noavx/stable.html

# Instalar PaddleOCR (incluye todas sus dependencias)
RUN python -m pip install --no-cache-dir paddleocr

# Instalar OmniMRZ (se descargará el wheel desde PyPI)
RUN python -m pip install --no-cache-dir omnimrz

# Verificar que la instalación fue exitosa
RUN python -c "import omnimrz; print('OmniMRZ installed successfully')"

CMD ["python"]
