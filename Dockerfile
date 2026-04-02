FROM python:3.9-slim-bookworm

ENV PADDLEOCR_DOWNLOAD_MODELS=0
ENV OMNIMRZ_DOWNLOAD_MODELS=0
ENV FLAGS_use_mkldnn=0
ENV FLAGS_cpu_quantize=0
ENV PADDLE_WITH_MKLDNN=0

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

# Instalar PaddlePaddle (versión estable 2.6.2)
RUN python -m pip install --no-cache-dir paddlepaddle==2.6.2 -i https://www.paddlepaddle.org.cn/packages/stable/cpu/

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
RUN curl -L https://github.com/AzwadFawadHasan/OmniMRZ/archive/refs/tags/v0.2.0.tar.gz -o /tmp/omnimrz.tar.gz && \
    cd /tmp && tar -xzf omnimrz.tar.gz

# Copiar manualmente el código fuente a site-packages
RUN cp -r /tmp/OmniMRZ-0.2.0/omnimrz /usr/local/lib/python3.9/site-packages/

# Instalar dependencias adicionales
RUN python -m pip install --no-cache-dir ScreenshotScanner PyYAML pytesseract opencv-python scipy

RUN python -m pip install --no-cache-dir Flask==2.3.3

# Verificar que el módulo omnimrz se importa correctamente
RUN python -c "import omnimrz; print('OmniMRZ installed successfully')"

# ============================================
# DESCARGAR MODELOS MANUALMENTE (SIN EJECUTAR PADDLEOCR)
# ============================================
# Esto evita el Segmentation Fault causado por oneDNN en CPUs sin AVX
RUN mkdir -p /root/.paddleocr/whl/det/en /root/.paddleocr/whl/rec/en /root/.paddleocr/whl/cls && \
    echo "Descargando modelo de detección..." && \
    curl -L https://paddleocr.bj.bcebos.com/PP-OCRv3/english/en_PP-OCRv3_det_infer.tar -o /tmp/det.tar && \
    tar -xf /tmp/det.tar -C /root/.paddleocr/whl/det/en && \
    rm /tmp/det.tar && \
    echo "Descargando modelo de reconocimiento..." && \
    curl -L https://paddleocr.bj.bcebos.com/PP-OCRv3/english/en_PP-OCRv3_rec_infer.tar -o /tmp/rec.tar && \
    tar -xf /tmp/rec.tar -C /root/.paddleocr/whl/rec/en && \
    rm /tmp/rec.tar && \
    echo "Descargando modelo de clasificación..." && \
    curl -L https://paddleocr.bj.bcebos.com/dygraph_v2.0/ch/ch_ppocr_mobile_v2.0_cls_infer.tar -o /tmp/cls.tar && \
    tar -xf /tmp/cls.tar -C /root/.paddleocr/whl/cls && \
    rm /tmp/cls.tar && \
    echo "✅ Modelos descargados correctamente"

# ============================================
# VERIFICAR MODELOS EN LA UBICACIÓN CORRECTA
# ============================================
RUN echo "=== Verificando modelos descargados ===" && \
    echo "Buscando en /root/.paddleocr/:" && \
    ls -la /root/.paddleocr/ && \
    echo "" && \
    echo "Modelos de detección:" && \
    ls -la /root/.paddleocr/whl/det/en/ && \
    echo "" && \
    echo "Modelos de reconocimiento:" && \
    ls -la /root/.paddleocr/whl/rec/en/ && \
    echo "" && \
    echo "Modelos de clasificación:" && \
    ls -la /root/.paddleocr/whl/cls/ && \
    echo "" && \
    echo "Espacio total usado por modelos:" && \
    du -sh /root/.paddleocr/

# ============================================
# CREAR ENLACES PARA COMPATIBILIDAD
# ============================================
RUN mkdir -p /root/.paddlex && \
    ln -sf /root/.paddleocr /root/.paddlex/official_models

RUN mkdir -p /root/.omnimrz && \
    ln -sf /root/.paddleocr /root/.omnimrz/models

RUN ln -sf /root/.paddleocr /root/.paddleocr-models

# Verificar enlaces
RUN echo "=== Verificando enlaces simbólicos ===" && \
    ls -la /root/.paddleocr && \
    ls -la /root/.paddlex/ && \
    ls -la /root/.omnimrz/models && \
    echo "✅ Todos los enlaces creados correctamente"

CMD ["python"]
