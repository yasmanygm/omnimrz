FROM python:3.9-slim-bookworm

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Instalar PaddlePaddle desde el índice oficial (versión estable 2.6.1)
RUN python -m pip install --no-cache-dir paddlepaddle==2.6.1 -f https://www.paddlepaddle.org.cn/whl/linux/mkl/avx/stable.html

# Instalar OmniMRZ y PaddleOCR de forma aislada, sin reinstalar dependencias globales
RUN python -m pip install --no-cache-dir --no-deps omnimrz paddleocr && \
    python -m pip install --no-cache-dir requests Pillow numpy opencv-python opencv-contrib-python pytesseract scipy

# Verificar instalación
RUN python -c "import sys; print('Python path:', sys.path)" && \
    python -c "import site; print('Site packages:', site.getsitepackages())" && \
    ls -la /usr/local/lib/python3.9/site-packages/ | grep omnimrz && \
    python -c "import omnimrz; print('OmniMRZ installed successfully')"

CMD ["python"]
