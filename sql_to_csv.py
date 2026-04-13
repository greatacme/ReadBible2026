import re, csv, sys

def parse_version(lines):
    rows = []
    for line in lines:
        m = re.search(r"INSERT INTO VERSION.*?VALUES\s*\('([^']+)',\s*'([^']+)'\)", line)
        if m:
            rows.append([m.group(1), m.group(2)])
    return ['version_id', 'name'], rows

def parse_book(lines):
    rows = []
    pattern = re.compile(r"\(\s*(\d+),\s*'([^']+)',\s*'([^']+)',\s*'([^']+)',\s*'([^']+)'\s*\)")
    in_book = False
    for line in lines:
        if 'INSERT INTO BOOK' in line:
            in_book = True
        elif in_book and line.strip().startswith('INSERT INTO'):
            in_book = False
        if in_book:
            for m in pattern.finditer(line):
                rows.append([m.group(1), m.group(2), m.group(3), m.group(4), m.group(5)])
    return ['book_id', 'book_code', 'testament', 'name_ko', 'name_abbr'], rows

def parse_verse(text):
    rows = []
    # Match each value tuple: ('version_id', book_id, chapter, verse, 'text', paragraph_start)
    pattern = re.compile(
        r"\(\s*'([^']+)',\s*(\d+),\s*(\d+),\s*(\d+),\s*'((?:[^'\\]|''|\\.)*)',\s*(\d+)\s*\)",
        re.DOTALL
    )
    for m in pattern.finditer(text):
        text_val = m.group(5).replace("''", "'")
        rows.append([m.group(1), m.group(2), m.group(3), m.group(4), text_val, m.group(6)])
    return ['version_id', 'book_id', 'chapter', 'verse', 'text', 'paragraph_start'], rows

def write_csv(filename, header, rows):
    with open(filename, 'w', newline='', encoding='utf-8') as f:
        w = csv.writer(f)
        w.writerow(header)
        w.writerows(rows)
    print(f"{filename}: {len(rows)} rows")

with open('/home/acme/dev/ReadBible2026/bible_insert.sql', encoding='utf-8') as f:
    content = f.read()
    lines = content.splitlines()

h, rows = parse_version(lines)
write_csv('/home/acme/dev/ReadBible2026/csv_version.csv', h, rows)

h, rows = parse_book(lines)
write_csv('/home/acme/dev/ReadBible2026/csv_book.csv', h, rows)

h, rows = parse_verse(content)
write_csv('/home/acme/dev/ReadBible2026/csv_verse.csv', h, rows)
