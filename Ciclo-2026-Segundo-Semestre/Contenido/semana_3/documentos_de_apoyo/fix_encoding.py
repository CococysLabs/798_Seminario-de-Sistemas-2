from pathlib import Path
text = Path('documento_apoyo_semana3.txt').read_text(encoding='utf-8')
reps = {
    'Ã¡':'á','Ã©':'é','Ã­':'í','Ã³':'ó','Ãº':'ú',
    'Ã':'Á','Ã‰':'É','Ã':'Í','Ã“':'Ó','Ãš':'Ú',
    'Ã±':'ñ','Ã‘':'Ñ','Ã¼':'ü','Ãœ':'Ü',
    'Â¿':'¿','Â¡':'¡',
    'â€”':'—','â€“':'–','â€¦':'…','â€œ':'“','â€':'”','â€˜':'‘','â€™':'’',
    'Ã ':'à','Ã¨':'è','Ã§':'ç'
}
for a,b in reps.items():
    text = text.replace(a,b)
Path('documento_apoyo_semana3_clean.txt').write_text(text, encoding='utf-8')
