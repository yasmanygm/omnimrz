FROM python:3.9-slim-bookworm

# Dependencias del sistema
RUN apt-get update && apt-get install -y \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Instalar PaddlePaddle (para hardware sin AVX)
RUN python -m pip install --no-cache-dir paddlepaddle==3.2.2 -i https://www.paddlepaddle.org.cn/packages/stable/cpu/

# ============================================
# INSTALAR NUMPY 1.X PRIMERO (CRUCIAL)
# ============================================
RUN pip install --no-cache-dir numpy==1.26.4

RUN pip install --no-cache-dir \
    opencv-python-headless \
    paddleocr==2.6.1.2 \
    'numpy>=1.21,<2.0' \
    Flask==2.3.3 \
    Pillow \
    python-dateutil \
    pytesseract \
    PyYAML \
    scipy

# Descargar y extraer omnimrz
#RUN curl -L https://files.pythonhosted.org/packages/source/o/omnimrz/omnimrz-0.2.1.tar.gz -o /tmp/omnimrz.tar.gz &&  cd /tmp && tar -xzf omnimrz.tar.gz

# Descargar y extraer omnimrz
RUN curl -L https://github.com/AzwadFawadHasan/OmniMRZ/archive/refs/tags/v0.2.0.tar.gz -o /tmp/omnimrz.tar.gz &&  cd /tmp && tar -xzf omnimrz.tar.gz

# Copiar manualmente el código fuente a site-packages
RUN cp -r /tmp/OmniMRZ-0.2.0/omnimrz /usr/local/lib/python3.9/site-packages/

# Instalar dependencias adicionales
RUN python -m pip install --no-cache-dir ScreenshotScanner PyYAML pytesseract opencv-python scipy

RUN python -m pip install --no-cache-dir Flask==2.3.3

# Verificar que el módulo omnimrz se importa correctamente
RUN python -c "import omnimrz; print('OmniMRZ installed successfully')"

# Descargar modelos durante el build (sintaxis corregida)
#RUN python -c "from paddleocr import PaddleOCR; PaddleOCR(lang='en')"
RUN python -c "import os; os.environ['FLAGS_use_mkldnn']='0'; os.environ['PADDLE_WITH_MKLDNN']='0'; from paddleocr import PaddleOCR; PaddleOCR(lang='en', use_angle_cls=False, enable_mkldnn=False, use_gpu=False, show_log=False, cpu_threads=1)"
# Verificar modelos descargados
# ============================================
# VERIFICAR MODELOS EN LA UBICACIÓN CORRECTA
# ============================================
RUN echo "=== Verificando modelos descargados ===" && \
    echo "Buscando en /root/.paddleocr/:" && \
    ls -la /root/.paddleocr/ && \
    echo "" && \
    echo "Modelos de detección:" && \
    ls -la /root/.paddleocr/whl/det/ && \
    echo "" && \
    echo "Modelos de reconocimiento:" && \
    ls -la /root/.paddleocr/whl/rec/ && \
    echo "" && \
    echo "Espacio total usado por modelos:" && \
    du -sh /root/.paddleocr/

# ============================================
# CREAR ENLACES PARA COMPATIBILIDAD
# ============================================
# Crear enlace para compatibilidad con /root/.paddlex (si algún código lo espera)
RUN mkdir -p /root/.paddlex && \
    ln -sf /root/.paddleocr /root/.paddlex/official_models && \
    echo "✅ Enlace /root/.paddlex/official_models -> /root/.paddleocr"

# Crear enlace para OmniMRZ (busca en /root/.omnimrz/models)
RUN mkdir -p /root/.omnimrz && \
    ln -sf /root/.paddleocr /root/.omnimrz/models && \
    echo "✅ /root/.omnimrz/models -> /root/.paddleocr"

# Crear enlace adicional por si OmniMRZ busca en otra ubicación
RUN ln -sf /root/.paddleocr /root/.paddleocr-models && \
    echo "✅ Enlace adicional creado"

# Verificar enlaces
RUN echo "=== Verificando enlaces simbólicos ===" && \
    ls -la /root/.paddleocr && \
    ls -la /root/.paddlex/ && \
    ls -la /root/.omnimrz/models && \
    echo "✅ Todos los enlaces creados correctamente"

ENV PADDLEOCR_DOWNLOAD_MODELS=0
ENV OMNIMRZ_DOWNLOAD_MODELS=0
ENV FLAGS_use_mkldnn=0
ENV FLAGS_cpu_quantize=0
ENV PADDLE_WITH_MKLDNN=0

CMD ["python"]
