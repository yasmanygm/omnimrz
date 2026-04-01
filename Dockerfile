FROM python:3.9-slim-bookworm

# Instalar dependencias del sistema (incluyendo herramientas para extraer el wheel)
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    wget \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Instalar PaddlePaddle (versión estable 2.6.1 con AVX, ajusta según tu hardware)
RUN python -m pip install --no-cache-dir paddlepaddle==2.6.1 -f https://www.paddlepaddle.org.cn/whl/linux/mkl/avx/stable.html

# Instalar paddleocr y todas sus dependencias (permite que pip resuelva)
RUN python -m pip install --no-cache-dir paddleocr

# Descargar el wheel de omnimrz y extraerlo manualmente
RUN python -m pip download --no-deps --no-binary :all: omnimrz -d /tmp && \
    unzip -q /tmp/omnimrz-*.whl -d /tmp/omnimrz_extracted && \
    cp -r /tmp/omnimrz_extracted/omnimrz /usr/local/lib/python3.9/site-packages/ && \
    cp -r /tmp/omnimrz_extracted/omnimrz-*.dist-info /usr/local/lib/python3.9/site-packages/

# Instalar dependencias faltantes de omnimrz (que no fueron instaladas por paddleocr)
RUN python -m pip install --no-cache-dir ScreenshotScanner PyYAML

# Verificar que todo está correcto
RUN python -c "import sys; print('Python path:', sys.path)" && \
    python -c "import site; print('Site packages:', site.getsitepackages())" && \
    ls -la /usr/local/lib/python3.9/site-packages/ | grep omnimrz && \
    python -c "import omnimrz; print('OmniMRZ installed successfully')"

CMD ["python"]
