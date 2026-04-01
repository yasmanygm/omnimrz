FROM python:3.9-slim-bookworm

# Dependencias del sistema
RUN apt-get update && apt-get install -y wget \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    && rm -rf /var/lib/apt/lists/*

# Instalar PaddlePaddle (versión estable 2.6.1 con AVX)
RUN python -m pip install --no-cache-dir paddlepaddle==2.6.2 -f https://www.paddlepaddle.org.cn/whl/linux/mkl/avx/stable.html

# Instalar PaddleOCR y sus dependencias completas
RUN python -m pip install --no-cache-dir paddleocr

# Instalar dependencias que omnimrz necesita (ScreenshotScanner ya viene con paddleocr, pero por si acaso)
RUN python -m pip install --no-cache-dir pytesseract opencv-python scipy

# Descargar el tar.gz de omnimrz desde PyPI
RUN wget https://files.pythonhosted.org/packages/source/o/omnimrz/omnimrz-0.2.1.tar.gz -O /tmp/omnimrz.tar.gz && \
    cd /tmp && tar -xzf omnimrz.tar.gz

# Instalar omnimrz en modo editable (esto asegura que el código se copie correctamente)
RUN cd /tmp/omnimrz-0.2.1 && pip install --no-cache-dir -e .

# Verificar que el módulo se importa correctamente
RUN python -c "import sys; print('Python path:', sys.path)" && \
    python -c "import omnimrz; print('OmniMRZ installed successfully')"

CMD ["python"]
