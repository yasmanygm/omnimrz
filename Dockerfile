FROM python:3.9-slim-bookworm

# Dependencias del sistema
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

# Instalar PaddlePaddle (versión estable 2.4.2 sin AVX; ajusta según tu hardware)
RUN python -m pip install --no-cache-dir paddlepaddle==2.6.2 -f https://www.paddlepaddle.org.cn/whl/linux/mkl/noavx/stable.html

# Instalar PaddleOCR y todas sus dependencias (incluye PyYAML, etc.)
RUN python -m pip install --no-cache-dir paddleocr

# Descargar el código fuente de omnimrz (sin instalar)
RUN python -m pip download --no-deps omnimrz -d /tmp

# Extraer el archivo .tar.gz descargado
RUN tar -xzf /tmp/omnimrz-*.tar.gz -C /tmp

# Instalar omnimrz desde el código fuente
RUN cd /tmp/omnimrz-* && python -m pip install --no-cache-dir .

# Instalar dependencias que pudieran faltar (por seguridad)
RUN python -m pip install --no-cache-dir ScreenshotScanner PyYAML

# Verificar que el módulo existe
RUN python -c "import omnimrz; print('OmniMRZ installed successfully')"

CMD ["python"]
