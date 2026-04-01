FROM python:3.9-slim-bookworm

# Dependencias del sistema
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    git \
    && rm -rf /var/lib/apt/lists/*

# Instalar PaddlePaddle (versión estable 2.6.2 con AVX)
RUN python -m pip install --no-cache-dir paddlepaddle==2.6.2 -f https://www.paddlepaddle.org.cn/whl/linux/mkl/noavx/stable.html

# Instalar PaddleOCR y sus dependencias
RUN python -m pip install --no-cache-dir paddleocr

# Instalar dependencias adicionales que omnimrz necesita
RUN python -m pip install --no-cache-dir pytesseract opencv-python scipy ScreenshotScanner

# Clonar el repositorio de omnimrz desde GitHub
RUN git clone https://github.com/IRailean/omnimrz.git /tmp/omnimrz

# Instalar omnimrz manualmente desde el código fuente
RUN cd /tmp/omnimrz && python setup.py install

# Verificar que el módulo se importa correctamente
RUN python -c "import sys; print('Python path:', sys.path)" && \
    python -c "import omnimrz; print('OmniMRZ installed successfully')"

CMD ["python"]
