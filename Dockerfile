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
RUN python -m pip install --no-cache-dir paddlepaddle==3.3.1 -f https://www.paddlepaddle.org.cn/whl/linux/mkl/noavx/stable.html

# ============================================
# INSTALAR DEPENDENCIAS CON VERSIONES COMPATIBLES
# ============================================
# Primero numpy (debe ir antes que opencv)
RUN pip install --no-cache-dir numpy==1.24.3

RUN pip install --no-cache-dir \
    opencv-python-headless \
    paddleocr==3.4.0 \
    Flask==2.3.3 \
    Pillow \
    python-dateutil \
    pytesseract \
    PyYAML \
    scipy

# Descargar y extraer omnimrz
RUN curl -L https://files.pythonhosted.org/packages/source/o/omnimrz/omnimrz-0.2.1.tar.gz -o /tmp/omnimrz.tar.gz && \
    cd /tmp && tar -xzf omnimrz.tar.gz

# Copiar manualmente el código fuente a site-packages
RUN cp -r /tmp/omnimrz-0.2.1/omnimrz /usr/local/lib/python3.9/site-packages/

# Instalar dependencias adicionales
RUN python -m pip install --no-cache-dir ScreenshotScanner PyYAML pytesseract opencv-python scipy

# Verificar que el módulo omnimrz se importa correctamente
RUN python -c "import omnimrz; print('OmniMRZ installed successfully')"

# Descargar modelos durante el build (sintaxis corregida)
RUN python -c "from paddleocr import PaddleOCR; PaddleOCR(lang='en')"

# Verificar modelos descargados
RUN echo "=== Modelos descargados por PaddleOCR ===" && \
    ls -la /root/.paddlex/official_models/ && \
    du -sh /root/.paddlex/

# Crear enlace para PaddleOCR (por si busca en /root/.paddleocr)
RUN ln -sf /root/.paddlex /root/.paddleocr && \
    echo "✅ /root/.paddleocr -> /root/.paddlex"

# Crear enlace para OmniMRZ (busca en /root/.omnimrz/models)
RUN mkdir -p /root/.omnimrz && \
    ln -sf /root/.paddlex /root/.omnimrz/models && \
    echo "✅ /root/.omnimrz/models -> /root/.paddlex"

# Verificar enlaces
RUN echo "=== Verificando enlaces simbólicos ===" && \
    ls -la /root/.paddleocr && \
    ls -la /root/.omnimrz/models && \
    echo "✅ Enlaces creados correctamente"

ENV PADDLEOCR_DOWNLOAD_MODELS=0
ENV OMNIMRZ_DOWNLOAD_MODELS=0
ENV FLAGS_use_mkldnn=0

CMD ["python"]
