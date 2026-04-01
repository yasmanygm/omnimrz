FROM python:3.9-slim-bookworm

# Dependencias del sistema
RUN apt-get update && apt-get install -y wget\
    libgl1 \
    libglib2.0-0 \
    libsm6 \
    libxext6 \
    libxrender1 \
    libgomp1 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Instalar PaddlePaddle y PaddleOCR
RUN python -m pip install --no-cache-dir paddlepaddle==2.6.2 -f https://www.paddlepaddle.org.cn/whl/linux/mkl/noavx/stable.html
RUN python -m pip install --no-cache-dir paddleocr

# Descargar y extraer omnimrz
RUN curl -L https://files.pythonhosted.org/packages/source/o/omnimrz/omnimrz-0.2.1.tar.gz -o /tmp/omnimrz.tar.gz && \
    cd /tmp && tar -xzf omnimrz.tar.gz

# DIAGNÓSTICO: listar la estructura del código fuente
RUN echo "=== Contenido del directorio extraído ===" && \
    ls -la /tmp/omnimrz-0.2.1/ && \
    echo "=== Archivos Python encontrados ===" && \
    find /tmp/omnimrz-0.2.1 -name "*.py" -type f

# Instalar en modo editable con verbose
RUN cd /tmp/omnimrz-0.2.1 && \
    pip install --verbose -e . 2>&1 | tee /tmp/install.log

# DIAGNÓSTICO: ver qué se instaló realmente
RUN echo "=== Archivos instalados en site-packages ===" && \
    ls -la /usr/local/lib/python3.9/site-packages/ | grep -i omnimrz && \
    echo "=== Buscando archivos .pth (modo editable) ===" && \
    find /usr/local/lib/python3.9/site-packages -name "*.pth" -exec cat {} \; && \
    echo "=== Verificando si hay algún módulo relacionado ===" && \
    python -c "import sys; print('\n'.join(sys.path))" && \
    python -c "import pkgutil; print([m.name for m in pkgutil.iter_modules() if 'omni' in m.name])"

# Intento de importación forzada
RUN python -c "import sys; sys.path.insert(0, '/tmp/omnimrz-0.2.1'); import omnimrz; print('IMPORTADO DESDE FUENTE')"

CMD ["python"]
