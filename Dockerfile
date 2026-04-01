FROM python:3.9-slim-bookworm

# Dependencias del sistema
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Instalar PaddlePaddle (versión estable 2.6.1 con AVX)
RUN python -m pip install --no-cache-dir paddlepaddle==2.6.2 -f https://www.paddlepaddle.org.cn/whl/linux/mkl/avx/stable.html

# Instalar PaddleOCR y sus dependencias
RUN python -m pip install --no-cache-dir paddleocr

# Instalar omnimrz y forzar que se copie el módulo
RUN python -m pip install --no-cache-dir --force-reinstall --no-binary :all: omnimrz || \
    (python -m pip download --no-deps --no-binary :all: omnimrz -d /tmp && \
     cd /tmp && tar -xzf omnimrz-*.tar.gz && \
     cd omnimrz-* && python setup.py install)

# Verificar que el módulo existe en el sistema de archivos
RUN python -c "import sys; import site; print('Site packages:', site.getsitepackages())" && \
    find /usr/local/lib/python3.9/site-packages -name "*omnimrz*" && \
    python -c "import omnimrz; print('OmniMRZ installed successfully')"

CMD ["python"]
