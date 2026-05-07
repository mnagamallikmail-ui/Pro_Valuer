import zipfile
import re
import xml.etree.ElementTree as ET

docx_path = r'C:\bwvr\templates\99864ee8-1a49-422c-a30a-48831d163a81_Valuation Report.docx'

with zipfile.ZipFile(docx_path) as zf:
    # Read the main document content
    xml_content = zf.read('word/document.xml')
    tree = ET.fromstring(xml_content)

    # Simple namespace handling for text extraction
    namespace = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
    
    texts = []
    for node in tree.iter():
        if node.tag == '{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t':
            if node.text:
                texts.append(node.text)

    # Let's combine texts and look for anything matching <<...>>
    # Note: text might be split across multiple <w:t> tags
    # So we join it all, then regex
    # Wait, joining all text without spaces might merge words, but it's safe for finding <<...>>
    full_text = ''.join(texts)
    
    matches = re.findall(r'<<[^>]+>>', full_text)
    print("Found placeholders in document.xml:")
    for m in set(matches):
        print(m)
