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

# Instalar numpy primero con una versión compatible
RUN python -m pip install --no-cache-dir numpy==1.24.3

# Instalar PaddlePaddle 2.6.2
RUN python -m pip install --no-cache-dir paddlepaddle==2.6.2 -f https://www.paddlepaddle.org.cn/whl/linux/mkl/noavx/stable.html

# Instalar opencv con versión específica compatible
RUN python -m pip install --no-cache-dir opencv-python==4.8.1.78

# Instalar PaddleOCR 2.8.1 (compatible)
RUN python -m pip install --no-cache-dir paddleocr==2.8.1

# Descargar y extraer omnimrz
RUN curl -L https://files.pythonhosted.org/packages/source/o/omnimrz/omnimrz-0.2.1.tar.gz -o /tmp/omnimrz.tar.gz && \
    cd /tmp && tar -xzf omnimrz.tar.gz

# Copiar manualmente el código fuente a site-packages
RUN cp -r /tmp/omnimrz-0.2.1/omnimrz /usr/local/lib/python3.9/site-packages/

# Instalar dependencias adicionales con versiones fijas
RUN python -m pip install --no-cache-dir \
    ScreenshotScanner==0.1.2 \
    PyYAML==6.0.1 \
    pytesseract==0.3.10 \
    scipy==1.10.1 \
    typing-extensions==4.7.1

# Verificar que todo funciona
RUN python -c "import numpy; print(f'NumPy version: {numpy.__version__}')" && \
    python -c "import cv2; print(f'OpenCV version: {cv2.__version__}')" && \
    python -c "import paddle; print(f'PaddlePaddle version: {paddle.__version__}')" && \
    python -c "import omnimrz; print('OmniMRZ installed successfully')"

CMD ["python"]
