insts = []

def ext(s) :
    r = []
    for i in range(4) :
        t = '<td>'
        x = s.find(t) + len(t)
        s = s[x:]
        t = '</td>'
        x = s.find(t)
        r.append(s[:x])
        s = s[x+len(t):]
    return r


with open('venus.html', 'r', encoding='utf-8') as f :
    s = f.read()
    id = 0

    while True :
        t = '<tr id="instruction-' + str(id) + '"'
        x = s.find(t)
        if x == -1 :
            break
        s = s[x:]

        t = '</tr>'
        x = s.find(t) + len(t)
        insts.append(ext(s[:x]))
        s = s[x:]

        id += 4

fi = True
with open('tests/test.dat', 'w') as f :
    for inst in insts :
        if fi :
            fi = False
        else :
            f.write('\n')
        f.write(inst[1][2:])

fi = True
with open('tests/test.asm', 'w') as f :
    for inst in insts :
        if fi :
            fi = False
        else :
            f.write('\n')
        f.write(inst[2])