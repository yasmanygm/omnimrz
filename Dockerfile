FROM python:3.9-slim

# Instalar dependencias del sistema necesarias para OpenCV y PaddleOCR
RUN apt-get update && apt-get install -y \
    libgl1-mesa-glx \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender-dev \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Instalar PaddlePaddle (versión CPU sin AVX para hardware antiguo)
RUN pip install paddlepaddle==3.0.0b1 -f https://www.paddlepaddle.org.cn/whl/linux/mkl/avx/stable.html

# Instalar OmniMRZ y PaddleOCR
RUN pip install omnimrz paddleocr --no-cache-dir

# Verificar que todo funciona
RUN python -c "import omnimrz; print('OmniMRZ installed successfully')"

CMD ["python"]
