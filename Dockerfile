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

# --- PREDESCARGA DE MODELOS PaddleOCR EN MÚLTIPLES IDIOMAS ---
RUN echo "=== Descargando modelos de PaddleOCR (inglés y español) ===" && \
    python -c "\
import os; \
os.environ['PADDLE_HOME'] = '/root/.paddleocr'; \
from paddleocr import PaddleOCR; \
print('📥 Descargando modelo inglés...'); \
ocr_en = PaddleOCR(lang='en', use_angle_cls=False); \
print('✅ Modelo inglés listo'); \
print('📥 Descargando modelo español...'); \
ocr_es = PaddleOCR(lang='es', use_angle_cls=False); \
print('✅ Modelo español listo'); \
print('🎉 Todos los modelos pre-descargados correctamente'); \
" && \
    echo "=== Modelos descargados ===" && \
    du -sh /root/.paddleocr/ && \
    ls -la /root/.paddleocr/

# Verificar que el módulo omnimrz se importa correctamente
RUN python -c "import omnimrz; print('OmniMRZ installed successfully')"

CMD ["python"]
