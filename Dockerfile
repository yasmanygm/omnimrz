FROM python:3.9-slim-bookworm

# Dependencias del sistema
RUN apt-get update && apt-get install -y wget \
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Instalar PaddlePaddle 2.4.2 (para hardware sin AVX)
RUN python -m pip install --no-cache-dir paddlepaddle==2.6.2 -f https://www.paddlepaddle.org.cn/whl/linux/mkl/noavx/stable.html

# Instalar PaddleOCR y sus dependencias
RUN python -m pip install --no-cache-dir paddleocr

# Descargar y extraer omnimrz
RUN curl -L https://files.pythonhosted.org/packages/source/o/omnimrz/omnimrz-0.2.1.tar.gz -o /tmp/omnimrz.tar.gz && \
    cd /tmp && tar -xzf omnimrz.tar.gz

# Copiar manualmente el código fuente a site-packages
RUN cp -r /tmp/omnimrz-0.2.1/omnimrz /usr/local/lib/python3.9/site-packages/

# Instalar dependencias adicionales
RUN python -m pip install --no-cache-dir ScreenshotScanner PyYAML pytesseract opencv-python scipy

# --- PREDESCARGA DE MODELOS CON DIAGNÓSTICO ---
RUN echo "=== Verificando instalación de PaddleOCR ===" && \
    python -c "import paddleocr; print('PaddleOCR version:', paddleocr.__version__)" && \
    echo "=== Iniciando descarga de modelos ===" && \
    python -c "\
import os; \
import sys; \
os.environ['PADDLE_HOME'] = '/root/.paddleocr'; \
os.environ['PADDLE_PDX_DISABLE_MODEL_SOURCE_CHECK'] = 'True'; \
print('PADDLE_HOME:', os.environ['PADDLE_HOME']); \
print('Python version:', sys.version); \
try: \
    from paddleocr import PaddleOCR; \
    print('📥 Descargando modelo inglés...'); \
    ocr_en = PaddleOCR(lang='en', use_angle_cls=False, show_log=False); \
    print('✅ Modelo inglés listo'); \
    print('📥 Descargando modelo español...'); \
    ocr_es = PaddleOCR(lang='es', use_angle_cls=False, show_log=False); \
    print('✅ Modelo español listo'); \
    print('🎉 Todos los modelos pre-descargados correctamente'); \
except Exception as e: \
    print(f'❌ Error: {e}'); \
    import traceback; \
    traceback.print_exc(); \
    sys.exit(1); \
" && \
    echo "=== Modelos descargados ===" && \
    ls -la /root/.paddleocr/ 2>/dev/null || echo "No se encontró el directorio" && \
    find /root/.paddleocr -type f -name "*.pdparams" 2>/dev/null | head -10 || echo "No se encontraron modelos"

# Verificar que el módulo omnimrz se importa correctamente
RUN python -c "import omnimrz; print('OmniMRZ installed successfully')"
# Crear script de descarga de modelos usando echo
RUN echo 'import os' > /tmp/download_models.py && \
    echo "os.environ['PADDLE_HOME'] = '/root/.paddleocr'" >> /tmp/download_models.py && \
    echo "os.environ['PADDLE_PDX_DISABLE_MODEL_SOURCE_CHECK'] = 'True'" >> /tmp/download_models.py && \
    echo '' >> /tmp/download_models.py && \
    echo 'from paddleocr import PaddleOCR' >> /tmp/download_models.py && \
    echo '' >> /tmp/download_models.py && \
    echo 'print("📥 Descargando modelo inglés...")' >> /tmp/download_models.py && \
    echo 'ocr_en = PaddleOCR(lang="en", use_angle_cls=False, show_log=False)' >> /tmp/download_models.py && \
    echo 'print("✅ Modelo inglés listo")' >> /tmp/download_models.py && \
    echo '' >> /tmp/download_models.py && \
    echo 'print("📥 Descargando modelo español...")' >> /tmp/download_models.py && \
    echo 'ocr_es = PaddleOCR(lang="es", use_angle_cls=False, show_log=False)' >> /tmp/download_models.py && \
    echo 'print("✅ Modelo español listo")' >> /tmp/download_models.py

# Ejecutar el script
RUN python /tmp/download_models.py
CMD ["python"]
