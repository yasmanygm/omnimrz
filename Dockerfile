FROM python:3.9-slim-bookworm

# Instalar dependencias del sistema (incluyendo herramientas para compilar)
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    wget \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Instalar PaddlePaddle (versión estable 2.6.1 con AVX, ajusta según hardware)
RUN python -m pip install --no-cache-dir paddlepaddle==2.6.1 -f https://www.paddlepaddle.org.cn/whl/linux/mkl/avx/stable.html

# Instalar paddleocr y sus dependencias completas
RUN python -m pip install --no-cache-dir paddleocr

# Descargar el código fuente de omnimrz y compilarlo/instalarlo manualmente
RUN python -m pip download --no-deps omnimrz -d /tmp && \
    tar -xzf /tmp/omnimrz-*.tar.gz -C /tmp && \
    cd /tmp/omnimrz-* && \
    python -m pip install --no-cache-dir .

# Instalar dependencias que pudieran faltar (por si acaso)
RUN python -m pip install --no-cache-dir ScreenshotScanner PyYAML

# Verificar instalación
RUN python -c "import sys; print('Python path:', sys.path)" && \
    python -c "import site; print('Site packages:', site.getsitepackages())" && \
    ls -la /usr/local/lib/python3.9/site-packages/ | grep omnimrz && \
    python -c "import omnimrz; print('OmniMRZ installed successfully')"

CMD ["python"]
