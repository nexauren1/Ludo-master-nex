#!/usr/bin/env python3
"""Generate original, low-poly PBR GLB models for Ludo Nex using only stdlib."""
from __future__ import annotations
import json, math, struct
from pathlib import Path

OUT = Path("assets/models")
MATS = {
    "midnight": ((0.012,0.025,0.055,1), .70,.24),
    "navy": ((0.025,0.065,0.12,1), .55,.28),
    "blue": ((0.065,0.16,0.27,1), .38,.30),
    "tile": ((0.12,0.25,0.39,1), .20,.32),
    "gold": ((0.88,0.61,0.24,1), .88,.19),
    "gold_light": ((1.0,0.82,0.46,1), .80,.16),
    "ivory": ((0.94,0.92,0.84,1), .12,.25),
    "ruby": ((0.72,0.045,0.11,1), .34,.22),
    "ruby_hi": ((1.0,0.22,0.30,1), .22,.18),
    "cyan": ((0.018,0.42,0.72,1), .38,.20),
    "cyan_hi": ((0.16,0.76,1.0,1), .20,.17),
    "emerald": ((0.025,0.38,0.19,1), .36,.21),
    "emerald_hi": ((0.13,0.80,0.42,1), .18,.18),
    "solar": ((0.82,0.43,0.035,1), .38,.21),
    "solar_hi": ((1.0,0.72,0.12,1), .19,.17),
    "black": ((0.012,0.018,0.028,1), .08,.22),
}

class Model:
    def __init__(self):
        self.groups = {k: {"p": [], "n": [], "i": []} for k in MATS}

    def face(self, mat, vertices, normal):
        g = self.groups[mat]
        base = len(g["p"]) // 3
        for v in vertices: g["p"].extend(v)
        for _ in vertices: g["n"].extend(normal)
        if len(vertices) == 4:
            g["i"].extend((base,base+1,base+2,base,base+2,base+3))
        else:
            g["i"].extend((base,base+1,base+2))

    def box(self, mat, c, s):
        x,y,z=c; w,h,d=s; X,Y,Z=w/2,h/2,d/2
        self.face(mat,[(x-X,y-Y,z+Z),(x+X,y-Y,z+Z),(x+X,y+Y,z+Z),(x-X,y+Y,z+Z)],(0,0,1))
        self.face(mat,[(x+X,y-Y,z-Z),(x-X,y-Y,z-Z),(x-X,y+Y,z-Z),(x+X,y+Y,z-Z)],(0,0,-1))
        self.face(mat,[(x+X,y-Y,z+Z),(x+X,y-Y,z-Z),(x+X,y+Y,z-Z),(x+X,y+Y,z+Z)],(1,0,0))
        self.face(mat,[(x-X,y-Y,z-Z),(x-X,y-Y,z+Z),(x-X,y+Y,z+Z),(x-X,y+Y,z-Z)],(-1,0,0))
        self.face(mat,[(x-X,y+Y,z+Z),(x+X,y+Y,z+Z),(x+X,y+Y,z-Z),(x-X,y+Y,z-Z)],(0,1,0))
        self.face(mat,[(x-X,y-Y,z-Z),(x+X,y-Y,z-Z),(x+X,y-Y,z+Z),(x-X,y-Y,z+Z)],(0,-1,0))

    def cylinder(self, mat, c, rb, rt, h, seg=24):
        x,y,z=c; y0=y-h/2; y1=y+h/2
        for j in range(seg):
            a=j*2*math.pi/seg; b=(j+1)*2*math.pi/seg
            ca,sa,cb,sb=math.cos(a),math.sin(a),math.cos(b),math.sin(b)
            v0=(x+rb*ca,y0,z+rb*sa); v1=(x+rb*cb,y0,z+rb*sb)
            v2=(x+rt*cb,y1,z+rt*sb); v3=(x+rt*ca,y1,z+rt*sa)
            slope=(rb-rt)/h
            normals=[]
            for angle in (a,b,b,a):
                n=(math.cos(angle),slope,math.sin(angle)); length=math.sqrt(sum(k*k for k in n))
                normals.append(tuple(k/length for k in n))
            g=self.groups[mat]; base=len(g["p"])//3
            for v,n in zip((v0,v1,v2,v3),normals):
                g["p"].extend(v); g["n"].extend(n)
            g["i"].extend((base,base+1,base+2,base,base+2,base+3))
            self.face(mat,[(x,y1,z),v3,v2],(0,1,0))
            self.face(mat,[(x,y0,z),v1,v0],(0,-1,0))

    def sphere(self, mat, c, radius, seg=16, rings=10):
        cx,cy,cz=c
        for v in range(rings):
            t0=math.pi*v/rings; t1=math.pi*(v+1)/rings
            for u in range(seg):
                p0=2*math.pi*u/seg; p1=2*math.pi*(u+1)/seg
                def nrm(t,p): return (math.sin(t)*math.cos(p),math.cos(t),math.sin(t)*math.sin(p))
                ns=(nrm(t0,p0),nrm(t0,p1),nrm(t1,p1),nrm(t1,p0))
                vs=tuple((cx+n[0]*radius,cy+n[1]*radius,cz+n[2]*radius) for n in ns)
                self.face(mat,vs,ns[0])
                # Use independent, per-vertex normals for a smooth glint sphere.
                g=self.groups[mat]; start=len(g["n"])-12
                g["n"][start:start+12]=[v for n in ns for v in n]

    def torus(self, mat, c, major, minor, seg=24, tube=8):
        cx,cy,cz=c
        for i in range(seg):
            u0=i*2*math.pi/seg; u1=(i+1)*2*math.pi/seg
            for j in range(tube):
                v0=j*2*math.pi/tube; v1=(j+1)*2*math.pi/tube
                def point(u,v):
                    rr=major+minor*math.cos(v)
                    return (cx+rr*math.cos(u),cy+minor*math.sin(v),cz+rr*math.sin(u))
                def normal(u,v): return (math.cos(v)*math.cos(u),math.sin(v),math.cos(v)*math.sin(u))
                vs=(point(u0,v0),point(u1,v0),point(u1,v1),point(u0,v1))
                ns=(normal(u0,v0),normal(u1,v0),normal(u1,v1),normal(u0,v1))
                self.face(mat,vs,ns[0])
                g=self.groups[mat]; start=len(g["n"])-12
                g["n"][start:start+12]=[v for n in ns for v in n]

    def triangle(self, mat, a, b, c, normal=(0,1,0)):
        self.face(mat,(a,b,c),normal)

    def write(self, path):
        binary=bytearray(); views=[]; accessors=[]; meshes=[]; nodes=[]
        material_list=[{"name":k,"pbrMetallicRoughness":{"baseColorFactor":list(v[0]),"metallicFactor":v[1],"roughnessFactor":v[2]}} for k,v in MATS.items()]
        material_index={k:i for i,k in enumerate(MATS)}
        def align():
            while len(binary)%4: binary.append(0)
        def view(data,target):
            align(); offset=len(binary); binary.extend(data)
            item={"buffer":0,"byteOffset":offset,"byteLength":len(data)}
            if target: item["target"]=target
            views.append(item); return len(views)-1
        for key,g in self.groups.items():
            if not g["i"]: continue
            p=g["p"]; n=g["n"]; ix=g["i"]; count=len(p)//3
            if count > 65535: raise ValueError("GLB geometry exceeds compact index limit")
            pv=view(struct.pack("<"+"f"*len(p),*p),34962)
            accessors.append({"bufferView":pv,"componentType":5126,"count":count,"type":"VEC3","min":[min(p[k::3]) for k in range(3)],"max":[max(p[k::3]) for k in range(3)]})
            pi=len(accessors)-1
            nv=view(struct.pack("<"+"f"*len(n),*n),34962)
            accessors.append({"bufferView":nv,"componentType":5126,"count":count,"type":"VEC3"})
            ni=len(accessors)-1
            iv=view(struct.pack("<"+"H"*len(ix),*ix),34963)
            accessors.append({"bufferView":iv,"componentType":5123,"count":len(ix),"type":"SCALAR"})
            ii=len(accessors)-1
            meshes.append({"name":key,"primitives":[{"attributes":{"POSITION":pi,"NORMAL":ni},"indices":ii,"material":material_index[key]}]})
            nodes.append({"name":key,"mesh":len(meshes)-1})
        doc={"asset":{"version":"2.0","generator":"Ludo Nex original PBR asset builder"},"scene":0,"scenes":[{"nodes":list(range(len(nodes)))}],"nodes":nodes,"meshes":meshes,"materials":material_list,"buffers":[{"byteLength":len(binary)}],"bufferViews":views,"accessors":accessors}
        js=json.dumps(doc,separators=(",",":")).encode("utf-8")
        js+=b" " *((-len(js))%4); align()
        total=12+8+len(js)+8+len(binary)
        with open(path,"wb") as f:
            f.write(struct.pack("<4sII",b"glTF",2,total))
            f.write(struct.pack("<II",len(js),0x4E4F534A)); f.write(js)
            f.write(struct.pack("<II",len(binary),0x004E4942)); f.write(binary)
        data=Path(path).read_bytes()
        assert data[:4]==b"glTF" and struct.unpack("<I",data[8:12])[0]==len(data)
        print(path, len(data))

def build_board():
    m=Model()
    m.box("midnight",(0,-.34,0),(15.2,.60,15.2))
    m.box("gold",(0,-.015,0),(15.0,.10,15.0))
    m.box("navy",(0,.065,0),(14.78,.12,14.78))
    m.box("blue",(0,.15,0),(14.58,.08,14.58))
    m.box("gold_light",(0,.205,0),(14.42,.035,14.42))
    colors=("ruby","cyan","emerald","solar")
    highlights=("ruby_hi","cyan_hi","emerald_hi","solar_hi")
    centers=((-4.7,-4.7),(4.7,-4.7),(4.7,4.7),(-4.7,4.7))
    for color,light,(cx,cz) in zip(colors,highlights,centers):
        m.box("gold",(cx,.33,cz),(4.55,.25,4.55))
        m.box(color,(cx,.48,cz),(4.38,.16,4.38))
        m.box(light,(cx,.59,cz),(3.95,.10,3.95))
        m.box(color,(cx,.66,cz),(3.76,.08,3.76))
        m.box("gold",(cx,.73,cz),(3.43,.10,3.43))
        m.box("midnight",(cx,.80,cz),(3.28,.08,3.28))
        for i in range(4):
            ox=-.78 if i%2==0 else .78
            oz=-.78 if i<2 else .78
            m.cylinder("gold",(cx+ox,.91,cz+oz),.43,.43,.14,28)
            m.cylinder("navy",(cx+ox,1.00,cz+oz),.34,.34,.09,24)
            m.torus("gold_light",(cx+ox,1.06,cz+oz),.28,.035,24,8)
            m.cylinder("blue",(cx+ox,1.08,cz+oz),.22,.22,.035,20)
    # Fifty-two raised track tiles, with a different color at each starting gate.
    starts={0:"ruby",13:"cyan",26:"emerald",39:"solar"}
    safe={5,18,31,44}
    for i in range(52):
        distance=i*24.0/52.0
        if distance<3: x=distance; z=-3
        elif distance<9: x=3; z=-3+(distance-3)
        elif distance<15: x=3-(distance-9); z=3
        elif distance<21: x=-3; z=3-(distance-15)
        else: x=-3+(distance-21); z=-3
        color=starts.get(i,"gold" if i in safe else "tile")
        m.box("gold",(x,.32,z),(.51,.18,.51))
        m.box(color,(x,.435,z),(.445,.115,.445))
        m.box("blue",(x,.495,z),(.355,.025,.355))
        if i in safe: m.sphere("gold_light",(x,.53,z),.105,12,8)
    # Colored home rows approaching the finish hub.
    lanes=[
      ("ruby",[(0,-2.5),(0,-2),(0,-1.5),(0,-1),(0,-.5)]),
      ("cyan",[(2.5,0),(2,0),(1.5,0),(1,0),(.5,0)]),
      ("emerald",[(0,2.5),(0,2),(0,1.5),(0,1),(0,.5)]),
      ("solar",[(-2.5,0),(-2,0),(-1.5,0),(-1,0),(-.5,0)]),
    ]
    for color,points in lanes:
        for x,z in points:
            m.box("gold",(x,.35,z),(.50,.16,.50))
            m.box(color,(x,.46,z),(.42,.105,.42))
            m.box("ivory",(x,.52,z),(.30,.025,.30))
    # Four inlaid wedges and a gold centre medallion.
    m.box("gold",(0,.36,0),(2.25,.18,2.25))
    m.box("midnight",(0,.48,0),(2.02,.10,2.02))
    m.triangle("ruby",(-.94,.54,-.94),(.94,.54,-.94),(0,.54,0))
    m.triangle("cyan",(.94,.54,-.94),(.94,.54,.94),(0,.54,0))
    m.triangle("emerald",(.94,.54,.94),(-.94,.54,.94),(0,.54,0))
    m.triangle("solar",(-.94,.54,.94),(-.94,.54,-.94),(0,.54,0))
    m.cylinder("gold",(0,.68,0),.47,.47,.15,40)
    m.cylinder("navy",(0,.78,0),.31,.31,.09,32)
    m.torus("gold_light",(0,.85,0),.25,.045,32,8)
    return m

def build_token(color,accent):
    m=Model()
    m.cylinder("gold",(0,.10,0),.43,.43,.16,32)
    m.cylinder("navy",(0,.21,0),.34,.34,.08,28)
    m.torus("gold_light",(0,.27,0),.29,.045,28,8)
    m.cylinder(color,(0,.60,0),.31,.18,.70,32)
    m.torus("gold",(0,.96,0),.185,.05,28,8)
    m.cylinder(accent,(0,1.04,0),.19,.19,.10,24)
    m.sphere(color,(0,1.34,0),.32,24,16)
    m.sphere("gold_light",(-.105,1.44,-.205),.07,12,8)
    m.torus("gold_light",(0,1.07,0),.205,.025,24,6)
    return m

def build_dice():
    m=Model()
    m.box("gold",(0,0,0),(1.25,1.25,1.25))
    m.box("ivory",(0,.015,0),(1.15,1.15,1.15))
    def pip(x,y,z): m.sphere("black",(x,y,z),.095,14,10)
    # The dice is a full six-sided model, not a flat icon.
    for x,z in ((-.27,-.27),(.27,-.27),(0,0),(-.27,.27),(.27,.27)): pip(x,.59,z)
    for x,z in ((-.27,-.27),(.27,.27)): pip(x,-.59,z)
    for x,y in ((-.27,-.27),(0,0),(.27,.27)): pip(x,y,-.59)
    for x,y in ((-.27,-.27),(.27,-.27),(-.27,.27),(.27,.27)): pip(x,y,.59)
    pip(.59,0,0)
    for x,y in ((-.27,-.27),(0,-.27),(.27,-.27),(-.27,.27),(0,.27),(.27,.27)): pip(-.59,y,x)
    return m

def main():
    OUT.mkdir(parents=True,exist_ok=True)
    build_board().write(OUT/"nex_board.glb")
    build_token("ruby","ruby_hi").write(OUT/"token_ruby.glb")
    build_token("cyan","cyan_hi").write(OUT/"token_cyan.glb")
    build_token("emerald","emerald_hi").write(OUT/"token_emerald.glb")
    build_token("solar","solar_hi").write(OUT/"token_solar.glb")
    build_dice().write(OUT/"dice.glb")

if __name__=="__main__": main()
