FROM python:3.9-slim-bookworm

# ============================================
# VARIABLES DE ENTORNO
# ============================================
ENV FLAGS_use_mkldnn=0
ENV PADDLE_WITH_MKLDNN=0
ENV PADDLEOCR_DOWNLOAD_MODELS=0

# Dependencias del sistema
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*


# Opción 1: Usar la versión especial para CPUs sin AVX
#RUN python -m pip install --no-cache-dir paddlepaddle==3.0.0b1 -i https://www.paddlepaddle.org.cn/packages/stable/cpu/
RUN python -m pip install --no-cache-dir paddlepaddle==3.0.0 -i https://www.paddlepaddle.org.cn/packages/stable/cpu/

# ============================================
# INSTALAR NUMPY 1.X PRIMERO (CRUCIAL)
# ============================================
# ============================================
# INSTALAR PADDLEOCR 3.3.2 Y PADDLEX 3.3.12 (versiones requeridas)
# ============================================
RUN pip install --no-cache-dir \
    opencv-python-headless==4.8.1.78 \
    paddleocr==3.3.2 \
    paddlex==3.3.12


RUN pip install --no-cache-dir \
    numpy \
    Flask==2.3.3 \
    flask-swagger-ui \
    Pillow \
    python-dateutil \
    pytesseract \
    PyYAML

# Descargar y extraer omnimrz
RUN curl -L https://github.com/AzwadFawadHasan/OmniMRZ/archive/refs/tags/v0.2.0.tar.gz -o /tmp/omnimrz.tar.gz && \
    cd /tmp && tar -xzf omnimrz.tar.gz

# Copiar manualmente el código fuente a site-packages
RUN cp -r /tmp/OmniMRZ-0.2.0/omnimrz /usr/local/lib/python3.9/site-packages/

# Instalar dependencias adicionales
RUN python -m pip install --no-cache-dir ScreenshotScanner PyYAML pytesseract opencv-python scipy

RUN python -m pip install --no-cache-dir Flask==2.3.3

# Verificar que el módulo omnimrz se importa correctamente
RUN python -c "import omnimrz; print('OmniMRZ installed successfully')"

CMD ["python"]
