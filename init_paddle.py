import os
os.environ['FLAGS_use_mkldnn'] = '0'
os.environ['PADDLE_WITH_MKLDNN'] = '0'
from paddleocr import PaddleOCR

print('🔄 Inicializando PaddleOCR...')
ocr = PaddleOCR(
    lang='en',
    use_textline_orientation=False
)
print('✅ PaddleOCR inicializado correctamente')

# Probar con imagen simple
from PIL import Image, ImageDraw
img = Image.new('RGB', (800, 300), 'white')
draw = ImageDraw.Draw(img)
draw.text((50, 100), 'P<ESPULPEREZ<<YASMANY<JOSE<<<<<<<<<<<<<<<<<<<', fill='black')
draw.text((50, 150), 'XC123456<3ESP8511015M2801015<<<<<<<<<<<<<<<4', fill='black')
img.save('/tmp/test.jpg')

result = ocr.ocr('/tmp/test.jpg')
if result and result[0]:
    for line in result[0]:
        print(f'   {line[1][0]}')
    print('✅ Prueba exitosa')
else:
    print('⚠️ No se detectó texto')
