FROM ccr-2vdh3abv-pub.cnc.bj.baidubce.com/paddlepaddle/paddle:3.0.0

ENV PADDLE_HOME=/root/.paddleocr

# Actualizar pip y asegurar que se usa el mismo Python
RUN python -m pip install --upgrade pip

# Instalar usando el módulo pip de Python
RUN python -m pip install omnimrz paddleocr --no-cache-dir

# Verificar con el mismo Python
RUN python -c "import omnimrz; print('OmniMRZ installed successfully')"

CMD ["python"]
