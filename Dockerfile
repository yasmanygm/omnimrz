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
RUN python -m pip install --no-cache-dir paddlepaddle==3.0.0b1 -i https://www.paddlepaddle.org.cn/packages/stable/cpu/

# ============================================
# INSTALAR NUMPY 1.X PRIMERO (CRUCIAL)
# ============================================
RUN pip install --no-cache-dir numpy==1.23.5
RUN pip install --no-cache-dir scipy==1.10.1

RUN pip install --no-cache-dir \
    opencv-python-headless \
    paddleocr==2.10.0 \
    'numpy>=1.21,<=1.23.5' \
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

# ============================================
# DESCARGAR MODELOS MANUALMENTE
# ============================================
# ============================================
# DESCARGAR MODELOS PP-OCRv3 (NO v4 o v5)
# ============================================
RUN mkdir -p /root/.paddleocr/whl/det/en /root/.paddleocr/whl/rec/en /root/.paddleocr/whl/cls && \
    echo "📥 Descargando modelo DETECCIÓN PP-OCRv3..." && \
    curl -L https://paddleocr.bj.bcebos.com/PP-OCRv3/english/en_PP-OCRv3_det_infer.tar -o /tmp/det.tar && \
    tar -xf /tmp/det.tar -C /root/.paddleocr/whl/det/en && \
    rm /tmp/det.tar && \
    echo "📥 Descargando modelo RECONOCIMIENTO PP-OCRv3..." && \
    curl -L https://paddleocr.bj.bcebos.com/PP-OCRv3/english/en_PP-OCRv3_rec_infer.tar -o /tmp/rec.tar && \
    tar -xf /tmp/rec.tar -C /root/.paddleocr/whl/rec/en && \
    rm /tmp/rec.tar && \
    echo "📥 Descargando modelo CLASIFICACIÓN de texto (0°/180°)..." && \
    curl -L https://paddleocr.bj.bcebos.com/dygraph_v2.0/ch/ch_ppocr_mobile_v2.0_cls_infer.tar -o /tmp/cls.tar && \
    tar -xf /tmp/cls.tar -C /root/.paddleocr/whl/cls/ && \
    rm /tmp/cls.tar && \
    echo "✅ Modelos descargados correctamente"

# Verificar modelos
RUN echo "=== VERIFICANDO MODELOS ===" && \
    ls -la /root/.paddleocr/whl/det/en/ && \
    ls -la /root/.paddleocr/whl/rec/en/ && \
    du -sh /root/.paddleocr/
    
# ============================================
# VERIFICAR MODELOS
# ============================================
RUN echo "=== Verificando modelos descargados ===" && \
    ls -la /root/.paddleocr/whl/det/en/ && \
    ls -la /root/.paddleocr/whl/rec/en/ && \
    ls -la /root/.paddleocr/whl/cls/ && \
    du -sh /root/.paddleocr/

# ============================================
# CREAR ENLACES PARA COMPATIBILIDAD
# ============================================
RUN mkdir -p /root/.paddlex && \
    ln -sf /root/.paddleocr /root/.paddlex/official_models

RUN mkdir -p /root/.omnimrz && \
    ln -sf /root/.paddleocr /root/.omnimrz/models

RUN ln -sf /root/.paddleocr /root/.paddleocr-models

# ============================================
# INICIALIZACIÓN COMPLETA DE PADDLEOCR (DESCARGA TODOS LOS MODELOS)
# ============================================
# Este paso REQUIERE conexión a internet durante el build
# Descargará automáticamente todos los modelos necesarios (PP-OCRv3, clasificadores, etc.)
COPY init_paddle.py /tmp/init_paddle.py

RUN python /tmp/init_paddle.py
# Verificar modelos descargados
RUN echo "=== Modelos descargados ===" && \
    ls -la /root/.paddleocr/ && \
    ls -la /root/.paddlex/ && \
    du -sh /root/.paddleocr /root/.paddlex

CMD ["python"]
