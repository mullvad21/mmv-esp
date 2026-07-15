#Requires AutoHotkey v2.0
#SingleInstance Force

global cfgPath := A_ScriptDir . "\mmv_hub_cfg.txt"
global esp := true, role := true, tracer := false, dist := true, hpbar := true, cross := false
global fb := false, fog := false, particle := false, gfx := false
global spd := false, spd_v := 16, jmp := false, jmp_v := 50, noclip := false, anti := false
global cx := 960, cy := 540

WriteCfg() {
    txt := "esp:" (esp ? "true" : "false") "`nrole:" (role ? "true" : "false") "`ntracer:" (tracer ? "true" : "false")
    txt .= "`ndist:" (dist ? "true" : "false") "`nhpbar:" (hpbar ? "true" : "false") "`ncross:" (cross ? "true" : "false")
    txt .= "`nfb:" (fb ? "true" : "false") "`nfog:" (fog ? "true" : "false") "`nparticle:" (particle ? "true" : "false") "`ngfx:" (gfx ? "true" : "false")
    txt .= "`nspd:" (spd ? "true" : "false") "`nspd_v:" spd_v "`njmp:" (jmp ? "true" : "false") "`njmp_v:" jmp_v
    txt .= "`nnoclip:" (noclip ? "true" : "false") "`nanti:" (anti ? "true" : "false") "`ncx:" cx "`ncy:" cy
    FileDelete(cfgPath), FileAppend(txt, cfgPath)
}

MyGui := Gui("+AlwaysOnTop", "MMV / MM2 Hub")
MyGui.SetFont("s10", "Segoe UI")
MyGui.BackColor := "1a1a2e"

MyGui.Add("Text", "c00b4ff", ">> ESP")
gEsp := MyGui.Add("Checkbox", "x10 y+5 w260 Checked1", "ESP Boxes")
gRole := MyGui.Add("Checkbox", "x10 y+2 w260 Checked1", "Role Colors")
gTracer := MyGui.Add("Checkbox", "x10 y+2 w260", "Tracers")
gDist := MyGui.Add("Checkbox", "x10 y+2 w260 Checked1", "Distance")
gHp := MyGui.Add("Checkbox", "x10 y+2 w260 Checked1", "Health Bar")
gCross := MyGui.Add("Checkbox", "x10 y+2 w260", "Crosshair")

MyGui.Add("Text", "x10 y+10 c00b4ff", ">> WORLD")
gFb := MyGui.Add("Checkbox", "x10 y+5 w260", "Fullbright")
gFog := MyGui.Add("Checkbox", "x10 y+2 w260", "No Fog")
gPart := MyGui.Add("Checkbox", "x10 y+2 w260", "No Particles")
gGfx := MyGui.Add("Checkbox", "x10 y+2 w260", "Low GFX")

MyGui.Add("Text", "x10 y+10 c00b4ff", ">> PLAYER")
gSpd := MyGui.Add("Checkbox", "x10 y+5 w260", "Speed Hack")
MyGui.Add("Text", "x10 y+2 c888888", "Speed:")
gSpdV := MyGui.Add("Edit", "x55 y-20 w80 +0x2000", spd_v)
MyGui.Add("Button", "x140 y-23 w25 h20", "+10").OnEvent("Click", (*) => (spd_v := Min(spd_v+10,200), gSpdV.Value := spd_v, WriteCfg()))
MyGui.Add("Button", "x170 y+3 w25 h20", "-10").OnEvent("Click", (*) => (spd_v := Max(spd_v-10,16), gSpdV.Value := spd_v, WriteCfg()))
gJmp := MyGui.Add("Checkbox", "x10 y+5 w260", "Jump Hack")
MyGui.Add("Text", "x10 y+2 c888888", "Jump:")
gJmpV := MyGui.Add("Edit", "x55 y-20 w80 +0x2000", jmp_v)
MyGui.Add("Button", "x140 y-23 w25 h20", "+20").OnEvent("Click", (*) => (jmp_v := Min(jmp_v+20,300), gJmpV.Value := jmp_v, WriteCfg()))
MyGui.Add("Button", "x170 y+3 w25 h20", "-20").OnEvent("Click", (*) => (jmp_v := Max(jmp_v-20,50), gJmpV.Value := jmp_v, WriteCfg()))
gNoclip := MyGui.Add("Checkbox", "x10 y+5 w260", "Noclip")
gAnti := MyGui.Add("Checkbox", "x10 y+2 w260", "Anti-Fling")

MyGui.Add("Text", "x10 y+10 c00b4ff", ">> ARROWS = Move ESP")

gEsp.OnEvent("Click", (*) => (esp := gEsp.Value, WriteCfg()))
gRole.OnEvent("Click", (*) => (role := gRole.Value, WriteCfg()))
gTracer.OnEvent("Click", (*) => (tracer := gTracer.Value, WriteCfg()))
gDist.OnEvent("Click", (*) => (dist := gDist.Value, WriteCfg()))
gHp.OnEvent("Click", (*) => (hpbar := gHp.Value, WriteCfg()))
gCross.OnEvent("Click", (*) => (cross := gCross.Value, WriteCfg()))
gFb.OnEvent("Click", (*) => (fb := gFb.Value, WriteCfg()))
gFog.OnEvent("Click", (*) => (fog := gFog.Value, WriteCfg()))
gPart.OnEvent("Click", (*) => (particle := gPart.Value, WriteCfg()))
gGfx.OnEvent("Click", (*) => (gfx := gGfx.Value, WriteCfg()))
gSpd.OnEvent("Click", (*) => (spd := gSpd.Value, WriteCfg()))
gJmp.OnEvent("Click", (*) => (jmp := gJmp.Value, WriteCfg()))
gNoclip.OnEvent("Click", (*) => (noclip := gNoclip.Value, WriteCfg()))
gAnti.OnEvent("Click", (*) => (anti := gAnti.Value, WriteCfg()))

MyGui.Show("w290")

F1::MyGui.Show(MyGui.Visible ? "Hide" : "Show")
1::(esp := !esp, gEsp.Value := esp, WriteCfg())
2::(tracer := !tracer, gTracer.Value := tracer, WriteCfg())
3::(gfx := !gfx, gGfx.Value := gfx, WriteCfg())
4::(anti := !anti, gAnti.Value := anti, WriteCfg())
5::(role := !role, gRole.Value := role, WriteCfg())
7::(fb := !fb, gFb.Value := fb, WriteCfg())
8::(noclip := !noclip, gNoclip.Value := noclip, WriteCfg())
9::(spd := !spd, gSpd.Value := spd, WriteCfg())
0::(jmp := !jmp, gJmp.Value := jmp, WriteCfg())
Up::(cy := Max(cy-20,0), WriteCfg())
Down::(cy := Min(cy+20,1080), WriteCfg())
Left::(cx := Max(cx-20,0), WriteCfg())
Right::(cx := Min(cx+20,1920), WriteCfg())
P::(spd_v := Min(spd_v+10,200), gSpdV.Value := spd_v, WriteCfg())
O::(spd_v := Max(spd_v-10,16), gSpdV.Value := spd_v, WriteCfg())
L::(jmp_v := Min(jmp_v+20,300), gJmpV.Value := jmp_v, WriteCfg())
K::(jmp_v := Max(jmp_v-20,50), gJmpV.Value := jmp_v, WriteCfg())

WriteCfg()
TrayTip("MMV Hub", "Ready!", 3000)
