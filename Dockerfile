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

# Limpiar cualquier caché de pip existente
RUN rm -rf /root/.cache/pip

# Instalar setuptools y wheel primero (fundamental para Cython)
RUN python -m pip install --no-cache-dir --upgrade setuptools==69.5.1 wheel==0.43.0

# Instalar Cython con una versión estable
RUN python -m pip install --no-cache-dir cython==0.29.36

# Instalar numpy
RUN python -m pip install --no-cache-dir numpy==1.24.3

# Instalar PaddlePaddle
RUN python -m pip install --no-cache-dir paddlepaddle==2.6.2 -f https://www.paddlepaddle.org.cn/whl/linux/mkl/noavx/stable.html

# Instalar opencv-python
RUN python -m pip install --no-cache-dir opencv-python==4.8.1.78

# Instalar PaddleOCR y omnimrz juntos (sin versiones conflictivas)
RUN python -m pip install --no-cache-dir paddleocr==2.8.1 omnimrz

# Verificar instalación
RUN python -c "import numpy; print(f'NumPy: {numpy.__version__}')" && \
    python -c "import cv2; print(f'OpenCV: {cv2.__version__}')" && \
    python -c "import paddle; print(f'PaddlePaddle: {paddle.__version__}')" && \
    python -c "import omnimrz; print('OmniMRZ OK')"

CMD ["python"]
