import zipfile
import xml.etree.ElementTree as ET

docx_path = r'C:\bwvr\templates\99864ee8-1a49-422c-a30a-48831d163a81_Valuation Report.docx'

with zipfile.ZipFile(docx_path) as zf:
    xml_content = zf.read('word/document.xml')
    tree = ET.fromstring(xml_content)

    ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    
    for p in tree.findall('.//w:p', ns):
        # find pStyle
        pStyle = p.find('.//w:pStyle', ns)
        style_val = pStyle.attrib.get('{http://schemas.openxmlformats.org/wordprocessingml/2006/main}val') if pStyle is not None else 'Normal'
        
        texts = []
        for t in p.findall('.//w:t', ns):
            if t.text: texts.append(t.text)
        
        text = ''.join(texts).strip()
        if text and ('Heading' in style_val or style_val.startswith('1') or style_val.startswith('2') or len(text) < 50 and text.isupper()):
            print(f"[{style_val}] {text[:60]}")
