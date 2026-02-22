--[[
╔════════════════════════════════════════════════════════════╗
║          🥟  P E L M E N   P V P   v4.3                   ║
║     CFG · Auto Reload · Fly · Fast Collect (E)            ║
║     PC + Mobile · Delta · Arceus X · Fluxus · Synapse     ║
╚════════════════════════════════════════════════════════════╝
  Fly (R6+R15) · Fast Collect E Spam · Speed · InfJump
  Fling · Anti-AC · Anti-Rag · ShiftLock · Spam
  Rejoin · ServerHop · ServerLag · CFG Save/Load
]]

-- ════════════════════════════════════════
--  EXECUTOR COMPATIBILITY LAYER
--  Поддержка: Delta · Arceus X · Fluxus
--             Codex · Synapse · Krnl
--             PC и Mobile экзекуторы
-- ════════════════════════════════════════

-- Определяем тип экзекутора
local ExecName = "Unknown"
pcall(function()
    ExecName = (identifyexecutor and identifyexecutor())
        or (getexecutorname and getexecutorname())
        or "Unknown"
end)

-- Безопасная обёртка для PC-only функций (Delta mobile не имеет keypress и т.д.)
local safeKeypress       = type(keypress)=="function"          and keypress          or nil
local safeMouse1Click    = type(mouse1click)=="function"        and mouse1click        or nil
local safeFireProximity  = type(fireproximityprompt)=="function" and fireproximityprompt or nil
local safeFireClick      = type(fireclickdetector)=="function"  and fireclickdetector  or nil

-- writefile/readfile совместимость для экзекуторов без ФС
if not writefile then
    writefile = function() end
end
if not readfile then
    readfile = function() return nil end
end

-- Совместимость task для старых экзекуторов
if not task then
    task = {
        wait  = function(t) return wait(t) end,
        spawn = function(f) return spawn(f) end,
        defer = function(f) spawn(f) end,
        delay = function(t,f) delay(t,f) end,
    }
end

print("🥟 PelmenPVP v4.3 | Executor: "..tostring(ExecName))

-- ════════════════════════════════════════
--  SERVICES
-- ════════════════════════════════════════
local Players             = game:GetService("Players")
local RunService          = game:GetService("RunService")
local UserInputService    = game:GetService("UserInputService")
local TweenService        = game:GetService("TweenService")
local HttpService         = game:GetService("HttpService")
local TeleportService     = game:GetService("TeleportService")
local ContextActionService= game:GetService("ContextActionService")
local Camera              = workspace.CurrentCamera
local LP                  = Players.LocalPlayer
local Mouse               = LP:GetMouse()
local IsMobile            = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

-- ════════════════════════════════════════
--  DEFAULT CONFIG
-- ════════════════════════════════════════
local DEFAULT_CFG = {
    Speed      = { On=false, Value=32   },
    InfJump    = { On=false, Power=50   },
    Fling      = { On=false, Power=300, Range=25 },
    AntiAC     = { On=false },
    AntiRag    = { On=false },
    ShiftLock  = { On=false },
    Spam       = { On=false, Delay=7    },
    ServLag    = { On=false, Threads=50 },
    Fly        = { On=false, Speed=1    },  -- speed = multiplier 1-10
    FastCollect= { On=false, Delay=3    },  -- delay in ms *10
}
local CFG_FILE = "PelmenPVP_cfg.json"

-- ════════════════════════════════════════
--  CFG SYSTEM
-- ════════════════════════════════════════
local function DeepCopy(t)
    local c={} for k,v in pairs(t) do c[k]=type(v)=="table" and DeepCopy(v) or v end return c
end
local function MergeCfg(base,saved)
    local m=DeepCopy(base)
    if type(saved)~="table" then return m end
    for k,v in pairs(saved) do
        if type(v)=="table" and type(m[k])=="table" then
            for kk,vv in pairs(v) do if m[k][kk]~=nil then m[k][kk]=vv end end
        end
    end
    return m
end
local function LoadCfg()
    if readfile then
        local ok,raw=pcall(readfile,CFG_FILE)
        if ok and raw and #raw>2 then
            local ok2,parsed=pcall(function() return HttpService:JSONDecode(raw) end)
            if ok2 and parsed then return MergeCfg(DEFAULT_CFG,parsed) end
        end
    end
    return DeepCopy(DEFAULT_CFG)
end
local function SaveCfg(cfg)
    if writefile then
        local ok,json=pcall(function() return HttpService:JSONEncode(cfg) end)
        if ok then pcall(writefile,CFG_FILE,json) end
    end
end

local Cfg       = LoadCfg()
local saveTimer = 0
local function ScheduleSave() saveTimer=tick() end
RunService.Heartbeat:Connect(function()
    if saveTimer>0 and tick()-saveTimer>1.5 then saveTimer=0 SaveCfg(Cfg) end
end)

-- ════════════════════════════════════════
--  HELPERS
-- ════════════════════════════════════════
local function Char()  return LP.Character end
local function Root()  local c=Char() return c and c:FindFirstChild("HumanoidRootPart") end
local function Hum()   local c=Char() return c and c:FindFirstChildOfClass("Humanoid") end

local function Tw(o,p,t,s)
    TweenService:Create(o,TweenInfo.new(t or 0.18,s or Enum.EasingStyle.Quart,Enum.EasingDirection.Out),p):Play()
end
local function Corner(p,r) local c=Instance.new("UICorner") c.CornerRadius=UDim.new(0,r or 8) c.Parent=p return c end
local function Stroke(p,c,t) local s=Instance.new("UIStroke") s.Color=c s.Thickness=t or 1.2 s.Parent=p return s end
local function Pad(p,l,r,t,b)
    local u=Instance.new("UIPadding")
    u.PaddingLeft=UDim.new(0,l or 0) u.PaddingRight=UDim.new(0,r or 0)
    u.PaddingTop=UDim.new(0,t or 0)  u.PaddingBottom=UDim.new(0,b or 0)
    u.Parent=p
end

-- ════════════════════════════════════════
--  THEME
-- ════════════════════════════════════════
local T={
    BG=Color3.fromRGB(8,8,12),        Panel=Color3.fromRGB(14,14,20),
    Card=Color3.fromRGB(20,20,30),     CardHov=Color3.fromRGB(26,26,38),
    Acc=Color3.fromRGB(255,70,0),      Acc2=Color3.fromRGB(255,150,30),
    Blue=Color3.fromRGB(40,130,255),   Red=Color3.fromRGB(220,50,50),
    Green=Color3.fromRGB(40,210,90),   Purple=Color3.fromRGB(140,80,255),
    Cyan=Color3.fromRGB(30,210,210),   Yellow=Color3.fromRGB(255,210,40),
    Sky=Color3.fromRGB(80,180,255),    Lime=Color3.fromRGB(100,255,80),
    On=Color3.fromRGB(255,70,0),       Off=Color3.fromRGB(38,38,55),
    Text=Color3.fromRGB(220,220,230),  Sub=Color3.fromRGB(100,100,125),
    White=Color3.fromRGB(255,255,255),
}

-- ════════════════════════════════════════
--  CLEANUP
-- ════════════════════════════════════════
if game.CoreGui:FindFirstChild("PelmenV4") then game.CoreGui.PelmenV4:Destroy() end

-- ════════════════════════════════════════
--  ROOT GUI
-- ════════════════════════════════════════
local GUI=Instance.new("ScreenGui")
GUI.Name="PelmenV4" GUI.ResetOnSpawn=false
GUI.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
GUI.DisplayOrder=1000 GUI.IgnoreGuiInset=true
GUI.Parent=(pcall(function() return game.CoreGui end) and game.CoreGui) or LP.PlayerGui

local W=IsMobile and 335 or 320
local H=IsMobile and 540 or 520

local Win=Instance.new("Frame",GUI)
Win.Size=UDim2.new(0,W,0,H)
Win.Position=UDim2.new(0,20,0.5,-(H/2))
Win.BackgroundColor3=T.BG Win.BorderSizePixel=0 Win.ClipsDescendants=true
Corner(Win,14) Stroke(Win,T.Acc,1.2)

local TLine=Instance.new("Frame",Win)
TLine.Size=UDim2.new(1,0,0,3) TLine.BackgroundColor3=T.Acc TLine.BorderSizePixel=0 TLine.ZIndex=10
local TG=Instance.new("UIGradient",TLine)
TG.Color=ColorSequence.new{ColorSequenceKeypoint.new(0,T.Acc),ColorSequenceKeypoint.new(0.5,T.Acc2),ColorSequenceKeypoint.new(1,T.Acc)}

-- HEADER
local Head=Instance.new("Frame",Win)
Head.Size=UDim2.new(1,0,0,54) Head.Position=UDim2.new(0,0,0,3)
Head.BackgroundColor3=T.Panel Head.BorderSizePixel=0 Head.ZIndex=5

local LBg=Instance.new("Frame",Head)
LBg.Size=UDim2.new(0,38,0,38) LBg.Position=UDim2.new(0,12,0.5,-19)
LBg.BackgroundColor3=T.Acc LBg.BorderSizePixel=0 LBg.ZIndex=6
Corner(LBg,10)
local LI=Instance.new("TextLabel",LBg)
LI.Text="🥟" LI.Size=UDim2.new(1,0,1,0) LI.BackgroundTransparency=1 LI.TextScaled=true LI.ZIndex=7

local TitleL=Instance.new("TextLabel",Head)
TitleL.Text="PELMEN PVP" TitleL.Size=UDim2.new(0,150,0,20)
TitleL.Position=UDim2.new(0,58,0,8) TitleL.BackgroundTransparency=1
TitleL.TextColor3=T.White TitleL.Font=Enum.Font.GothamBold TitleL.TextSize=15
TitleL.TextXAlignment=Enum.TextXAlignment.Left TitleL.ZIndex=6

local SubBadges=Instance.new("Frame",Head)
SubBadges.Size=UDim2.new(0,200,0,18) SubBadges.Position=UDim2.new(0,58,0,30)
SubBadges.BackgroundTransparency=1 SubBadges.ZIndex=6

local function Badge(text,color,xOff)
    local F=Instance.new("Frame",SubBadges)
    F.Size=UDim2.new(0,65,1,0) F.Position=UDim2.new(0,xOff,0,0)
    F.BackgroundColor3=T.Card F.BorderSizePixel=0 F.ZIndex=7
    Corner(F,5)
    local dot=Instance.new("Frame",F)
    dot.Size=UDim2.new(0,5,0,5) dot.Position=UDim2.new(0,5,0.5,-2.5)
    dot.BackgroundColor3=color dot.BorderSizePixel=0 dot.ZIndex=8
    Corner(dot,3)
    local lbl=Instance.new("TextLabel",F)
    lbl.Text=text lbl.Size=UDim2.new(1,-13,1,0) lbl.Position=UDim2.new(0,13,0,0)
    lbl.BackgroundTransparency=1 lbl.TextColor3=color
    lbl.Font=Enum.Font.GothamBold lbl.TextSize=9
    lbl.TextXAlignment=Enum.TextXAlignment.Left lbl.ZIndex=8
    return lbl
end
local CfgLbl   = Badge("CFG: OK",  T.Green,  0)
local ARLbl    = Badge("AUTO: ON", T.Blue,   68)
local PlatLbl  = Badge(IsMobile and "MOBILE" or "PC",T.Sub, 136)

local MinBtn=Instance.new("TextButton",Head)
MinBtn.Text="−" MinBtn.Size=UDim2.new(0,28,0,28)
MinBtn.Position=UDim2.new(1,-42,0.5,-14)
MinBtn.BackgroundColor3=T.Card MinBtn.TextColor3=T.Sub
MinBtn.Font=Enum.Font.GothamBold MinBtn.TextSize=18
MinBtn.BorderSizePixel=0 MinBtn.AutoButtonColor=false MinBtn.ZIndex=6
Corner(MinBtn,8)

-- TABS
local TabBar=Instance.new("Frame",Win)
TabBar.Size=UDim2.new(1,-24,0,30) TabBar.Position=UDim2.new(0,12,0,60)
TabBar.BackgroundColor3=T.Panel TabBar.BorderSizePixel=0 TabBar.ZIndex=5
Corner(TabBar,8)
local TBL=Instance.new("UIListLayout",TabBar)
TBL.FillDirection=Enum.FillDirection.Horizontal TBL.SortOrder=Enum.SortOrder.LayoutOrder
TBL.Padding=UDim.new(0,3)
Pad(TabBar,4,4,4,4)

-- SCROLL
local Scroll=Instance.new("ScrollingFrame",Win)
Scroll.Size=UDim2.new(1,-20,1,-100) Scroll.Position=UDim2.new(0,10,0,96)
Scroll.BackgroundTransparency=1 Scroll.BorderSizePixel=0
Scroll.ScrollBarThickness=2 Scroll.ScrollBarImageColor3=T.Acc
Scroll.CanvasSize=UDim2.new(0,0,0,0) Scroll.AutomaticCanvasSize=Enum.AutomaticSize.Y
local SLL=Instance.new("UIListLayout",Scroll)
SLL.Padding=UDim.new(0,7) SLL.SortOrder=Enum.SortOrder.LayoutOrder
Pad(Scroll,0,0,6,6)

-- ════════════════════════════════════════
--  NOTIFICATIONS
-- ════════════════════════════════════════
local nStack=0
local function Notify(title,msg,col,dur)
    nStack=nStack+1
    dur=dur or 3 col=col or T.Acc
    local slot=nStack
    local N=Instance.new("Frame",GUI)
    N.Size=UDim2.new(0,270,0,56) N.Position=UDim2.new(1,10,1,-(64*slot+10))
    N.BackgroundColor3=T.Panel N.BorderSizePixel=0 N.ZIndex=200
    Corner(N,10) Stroke(N,col,1)
    local Bar=Instance.new("Frame",N)
    Bar.Size=UDim2.new(0,3,0.65,0) Bar.Position=UDim2.new(0,0,0.175,0)
    Bar.BackgroundColor3=col Bar.BorderSizePixel=0 Bar.ZIndex=201
    Corner(Bar,2)
    local TL=Instance.new("TextLabel",N)
    TL.Text=title TL.Size=UDim2.new(1,-14,0,20) TL.Position=UDim2.new(0,10,0,7)
    TL.BackgroundTransparency=1 TL.TextColor3=T.White
    TL.Font=Enum.Font.GothamBold TL.TextSize=12
    TL.TextXAlignment=Enum.TextXAlignment.Left TL.ZIndex=201
    local ML=Instance.new("TextLabel",N)
    ML.Text=msg ML.Size=UDim2.new(1,-14,0,16) ML.Position=UDim2.new(0,10,0,30)
    ML.BackgroundTransparency=1 ML.TextColor3=T.Sub
    ML.Font=Enum.Font.Gotham ML.TextSize=10
    ML.TextXAlignment=Enum.TextXAlignment.Left ML.ZIndex=201
    Tw(N,{Position=UDim2.new(1,-283,1,-(64*slot+10))},0.35,Enum.EasingStyle.Back)
    task.delay(dur,function()
        Tw(N,{Position=UDim2.new(1,10,1,-(64*slot+10))},0.25)
        task.wait(0.3) N:Destroy() nStack=math.max(0,nStack-1)
    end)
end

-- ════════════════════════════════════════
--  COMPONENTS
-- ════════════════════════════════════════
local function Sec(txt,color)
    color=color or T.Sub
    local F=Instance.new("Frame",Scroll)
    F.Size=UDim2.new(1,0,0,20) F.BackgroundTransparency=1
    local B=Instance.new("Frame",F)
    B.Size=UDim2.new(0,3,0.7,0) B.Position=UDim2.new(0,0,0.15,0)
    B.BackgroundColor3=color B.BorderSizePixel=0
    Corner(B,2)
    local L=Instance.new("TextLabel",F)
    L.Text=txt:upper() L.Size=UDim2.new(1,-10,1,0) L.Position=UDim2.new(0,8,0,0)
    L.BackgroundTransparency=1 L.TextColor3=color L.Font=Enum.Font.GothamBold
    L.TextSize=10 L.TextXAlignment=Enum.TextXAlignment.Left
end

local function Toggle(label,icon,desc,acc,getCfg,setCfg,onChange)
    acc=acc or T.Acc
    local Card=Instance.new("Frame",Scroll)
    Card.Size=UDim2.new(1,0,0,IsMobile and 58 or 52)
    Card.BackgroundColor3=T.Card Card.BorderSizePixel=0
    Corner(Card,10)
    local stk=Stroke(Card,T.Off,1)

    local IB=Instance.new("Frame",Card)
    IB.Size=UDim2.new(0,34,0,34) IB.Position=UDim2.new(0,10,0.5,-17)
    IB.BackgroundColor3=getCfg() and acc or T.Panel IB.BorderSizePixel=0
    Corner(IB,9)
    local IL=Instance.new("TextLabel",IB)
    IL.Text=icon IL.Size=UDim2.new(1,0,1,0) IL.BackgroundTransparency=1 IL.TextScaled=true IL.ZIndex=2

    local NL=Instance.new("TextLabel",Card)
    NL.Text=label NL.Size=UDim2.new(0,140,0,18) NL.Position=UDim2.new(0,52,0,8)
    NL.BackgroundTransparency=1 NL.TextColor3=getCfg() and T.White or T.Text
    NL.Font=Enum.Font.GothamBold NL.TextSize=13 NL.TextXAlignment=Enum.TextXAlignment.Left

    local DL=Instance.new("TextLabel",Card)
    DL.Text=desc DL.Size=UDim2.new(0,155,0,13) DL.Position=UDim2.new(0,52,0,27)
    DL.BackgroundTransparency=1 DL.TextColor3=T.Sub
    DL.Font=Enum.Font.Gotham DL.TextSize=10 DL.TextXAlignment=Enum.TextXAlignment.Left

    local Pill=Instance.new("Frame",Card)
    Pill.Size=UDim2.new(0,44,0,22) Pill.Position=UDim2.new(1,-54,0.5,-11)
    Pill.BackgroundColor3=getCfg() and acc or T.Off Pill.BorderSizePixel=0
    Corner(Pill,11)
    local Knob=Instance.new("Frame",Pill)
    Knob.Size=UDim2.new(0,16,0,16)
    Knob.Position=getCfg() and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8)
    Knob.BackgroundColor3=T.White Knob.BorderSizePixel=0
    Corner(Knob,8)

    local Dot=Instance.new("Frame",Card)
    Dot.Size=UDim2.new(0,6,0,6) Dot.Position=UDim2.new(1,-14,0,8)
    Dot.BackgroundColor3=getCfg() and T.Green or T.Sub Dot.BorderSizePixel=0
    Corner(Dot,3)

    local function Refresh(s)
        Tw(Pill,{BackgroundColor3=s and acc or T.Off})
        Tw(Knob,{Position=s and UDim2.new(1,-19,0.5,-8) or UDim2.new(0,3,0.5,-8),
                 BackgroundColor3=s and T.White or Color3.fromRGB(160,160,180)})
        Tw(IB,{BackgroundColor3=s and acc or T.Panel})
        Tw(stk,{Color=s and acc or T.Off})
        Tw(Dot,{BackgroundColor3=s and T.Green or T.Sub})
        NL.TextColor3=s and T.White or T.Text
    end

    Card.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then
            setCfg(not getCfg()) Refresh(getCfg()) ScheduleSave()
            if onChange then onChange(getCfg()) end
        end
    end)
    return Card, Refresh
end

local function Slider(label,icon,acc,minV,maxV,getCfg,setCfg,suffix,onChange)
    suffix=suffix or "" acc=acc or T.Acc
    local Card=Instance.new("Frame",Scroll)
    Card.Size=UDim2.new(1,0,0,IsMobile and 68 or 62)
    Card.BackgroundColor3=T.Card Card.BorderSizePixel=0
    Corner(Card,10)
    local IL=Instance.new("TextLabel",Card)
    IL.Text=icon IL.Size=UDim2.new(0,26,0,26) IL.Position=UDim2.new(0,10,0,10)
    IL.BackgroundTransparency=1 IL.TextScaled=true
    local NL=Instance.new("TextLabel",Card)
    NL.Text=label NL.Size=UDim2.new(0,140,0,18) NL.Position=UDim2.new(0,40,0,8)
    NL.BackgroundTransparency=1 NL.TextColor3=T.Text
    NL.Font=Enum.Font.GothamBold NL.TextSize=12 NL.TextXAlignment=Enum.TextXAlignment.Left
    local VL=Instance.new("TextLabel",Card)
    VL.Text=getCfg()..suffix VL.Size=UDim2.new(0,65,0,18) VL.Position=UDim2.new(1,-72,0,8)
    VL.BackgroundTransparency=1 VL.TextColor3=acc
    VL.Font=Enum.Font.GothamBold VL.TextSize=12 VL.TextXAlignment=Enum.TextXAlignment.Right
    local Track=Instance.new("Frame",Card)
    Track.Size=UDim2.new(1,-20,0,6) Track.Position=UDim2.new(0,10,0,40)
    Track.BackgroundColor3=T.Panel Track.BorderSizePixel=0
    Corner(Track,3)
    local pct=(getCfg()-minV)/(maxV-minV)
    local Fill=Instance.new("Frame",Track)
    Fill.Size=UDim2.new(pct,0,1,0) Fill.BackgroundColor3=acc Fill.BorderSizePixel=0
    Corner(Fill,3)
    local Handle=Instance.new("Frame",Track)
    Handle.Size=UDim2.new(0,14,0,14) Handle.AnchorPoint=Vector2.new(0.5,0.5)
    Handle.Position=UDim2.new(pct,0,0.5,0) Handle.BackgroundColor3=T.White
    Handle.BorderSizePixel=0 Handle.ZIndex=3
    Corner(Handle,7)
    local dragging=false
    local function SetVal(x)
        local a=Track.AbsolutePosition.X local w=Track.AbsoluteSize.X
        local p=math.clamp((x-a)/w,0,1)
        local v=math.floor(minV+p*(maxV-minV))
        setCfg(v) VL.Text=v..suffix
        Tw(Fill,{Size=UDim2.new(p,0,1,0)})
        Tw(Handle,{Position=UDim2.new(p,0,0.5,0)})
        ScheduleSave()
        if onChange then onChange(v) end
    end
    Track.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then dragging=true SetVal(i.Position.X) end
    end)
    UserInputService.InputChanged:Connect(function(i)
        if dragging and (i.UserInputType==Enum.UserInputType.MouseMovement
        or i.UserInputType==Enum.UserInputType.Touch) then SetVal(i.Position.X) end
    end)
    UserInputService.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then dragging=false end
    end)
end

local function ActionBtn(label,icon,color,desc,onClick)
    local Card=Instance.new("Frame",Scroll)
    Card.Size=UDim2.new(1,0,0,IsMobile and 58 or 52)
    Card.BackgroundColor3=T.Card Card.BorderSizePixel=0
    Corner(Card,10) local stk=Stroke(Card,T.Off,1)
    local IB=Instance.new("Frame",Card)
    IB.Size=UDim2.new(0,34,0,34) IB.Position=UDim2.new(0,10,0.5,-17)
    IB.BackgroundColor3=T.Panel IB.BorderSizePixel=0
    Corner(IB,9)
    local IL=Instance.new("TextLabel",IB)
    IL.Text=icon IL.Size=UDim2.new(1,0,1,0) IL.BackgroundTransparency=1 IL.TextScaled=true IL.ZIndex=2
    local NL=Instance.new("TextLabel",Card)
    NL.Text=label NL.Size=UDim2.new(0,140,0,18) NL.Position=UDim2.new(0,52,0,8)
    NL.BackgroundTransparency=1 NL.TextColor3=T.Text
    NL.Font=Enum.Font.GothamBold NL.TextSize=13 NL.TextXAlignment=Enum.TextXAlignment.Left
    local DL=Instance.new("TextLabel",Card)
    DL.Text=desc DL.Size=UDim2.new(0,145,0,13) DL.Position=UDim2.new(0,52,0,27)
    DL.BackgroundTransparency=1 DL.TextColor3=T.Sub
    DL.Font=Enum.Font.Gotham DL.TextSize=10 DL.TextXAlignment=Enum.TextXAlignment.Left
    local RunBtn=Instance.new("TextButton",Card)
    RunBtn.Text="▶ Run" RunBtn.Size=UDim2.new(0,58,0,28)
    RunBtn.Position=UDim2.new(1,-68,0.5,-14)
    RunBtn.BackgroundColor3=color RunBtn.TextColor3=T.White
    RunBtn.Font=Enum.Font.GothamBold RunBtn.TextSize=11
    RunBtn.BorderSizePixel=0 RunBtn.AutoButtonColor=false
    Corner(RunBtn,8)
    local function flash()
        Tw(RunBtn,{BackgroundColor3=T.White},0.08)
        Tw(IB,{BackgroundColor3=color},0.08) Tw(stk,{Color=color})
        task.delay(0.15,function()
            Tw(RunBtn,{BackgroundColor3=color},0.15)
            Tw(IB,{BackgroundColor3=T.Panel},0.5) Tw(stk,{Color=T.Off},0.5)
        end)
        onClick()
    end
    RunBtn.MouseButton1Click:Connect(flash) RunBtn.TouchTap:Connect(flash)
    Card.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then Tw(Card,{BackgroundColor3=T.CardHov},0.1) end
    end)
    Card.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1
        or i.UserInputType==Enum.UserInputType.Touch then Tw(Card,{BackgroundColor3=T.Card},0.1) end
    end)
end

-- ════════════════════════════════════════
--  FLY SYSTEM  (FlyGuiV3 adapted)
-- ════════════════════════════════════════
local flyActive   = false
local flyBG       = nil
local flyBV       = nil
local tpwalking   = false
local flyThreads  = 0

local flyCtrl      = {f=0,b=0,l=0,r=0}
local flyLastCtrl  = {f=0,b=0,l=0,r=0}
local flySpd       = 0

local function GetFlyMaxSpeed()
    return Cfg.Fly.Speed * 8  -- 1-10 → 8-80 studs/s
end

-- Input state for fly direction
local function UpdateFlyCtrl()
    flyCtrl.f = (UserInputService:IsKeyDown(Enum.KeyCode.W) or UserInputService:IsKeyDown(Enum.KeyCode.Up))    and 1 or 0
    flyCtrl.b = (UserInputService:IsKeyDown(Enum.KeyCode.S) or UserInputService:IsKeyDown(Enum.KeyCode.Down))  and -1 or 0
    flyCtrl.l = (UserInputService:IsKeyDown(Enum.KeyCode.A) or UserInputService:IsKeyDown(Enum.KeyCode.Left))  and -1 or 0
    flyCtrl.r = (UserInputService:IsKeyDown(Enum.KeyCode.D) or UserInputService:IsKeyDown(Enum.KeyCode.Right)) and 1 or 0
end

local function StopFly()
    flyActive=false tpwalking=false
    local plr=LP local char=Char()
    if char then
        local h=char:FindFirstChildOfClass("Humanoid")
        if h then
            for _,s in pairs(Enum.HumanoidStateType:GetEnumItems()) do
                pcall(function() h:SetStateEnabled(s,true) end)
            end
            h:ChangeState(Enum.HumanoidStateType.RunningNoPhysics)
            h.PlatformStand=false
        end
        local anim=char:FindFirstChild("Animate")
        if anim then anim.Disabled=false end
    end
    if flyBG  and flyBG.Parent  then flyBG:Destroy()  flyBG=nil  end
    if flyBV  and flyBV.Parent  then flyBV:Destroy()  flyBV=nil  end
    flySpd=0 flyCtrl={f=0,b=0,l=0,r=0} flyLastCtrl={f=0,b=0,l=0,r=0}
end

local function StartFly()
    if flyActive then StopFly() return end
    local char=Char() if not char then return end
    local h=char:FindFirstChildOfClass("Humanoid") if not h then return end

    flyActive=true
    local isR6=h.RigType==Enum.HumanoidRigType.R6
    local torso=isR6 and char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
    if not torso then flyActive=false return end

    -- Disable states
    for _,s in pairs(Enum.HumanoidStateType:GetEnumItems()) do
        pcall(function() h:SetStateEnabled(s,false) end)
    end
    h:ChangeState(Enum.HumanoidStateType.Swimming)
    h.PlatformStand=true

    -- Freeze animation
    local anim=char:FindFirstChild("Animate")
    if anim then anim.Disabled=true end
    for _,tr in pairs(h:GetPlayingAnimationTracks()) do tr:AdjustSpeed(0) end

    -- TP walking speed thread (single, speed controlled by BV)
    tpwalking=true
    task.spawn(function()
        local hb=RunService.Heartbeat
        while tpwalking and hb:Wait() and char and h and h.Parent do
            -- movement handled by BodyVelocity
        end
    end)

    -- Body movers
    flyBG=Instance.new("BodyGyro",torso)
    flyBG.P=9e4 flyBG.MaxTorque=Vector3.new(9e9,9e9,9e9)
    flyBG.CFrame=torso.CFrame

    flyBV=Instance.new("BodyVelocity",torso)
    flyBV.Velocity=Vector3.new(0,0.1,0)
    flyBV.MaxForce=Vector3.new(9e9,9e9,9e9)

    -- Fly loop
    task.spawn(function()
        flySpd=0
        while flyActive and char and h and h.Parent do
            RunService.RenderStepped:Wait()
            UpdateFlyCtrl()
            local maxS=GetFlyMaxSpeed()

            local moving=(flyCtrl.l+flyCtrl.r~=0 or flyCtrl.f+flyCtrl.b~=0)
            if moving then
                flySpd=math.min(flySpd+0.5+(flySpd/maxS), maxS)
            else
                flySpd=math.max(flySpd-1, 0)
            end

            local camCF=Camera.CFrame
            if (flyCtrl.l+flyCtrl.r)~=0 or (flyCtrl.f+flyCtrl.b)~=0 then
                flyBV.Velocity=((camCF.LookVector*(flyCtrl.f+flyCtrl.b))
                    +((camCF*CFrame.new(flyCtrl.l+flyCtrl.r,(flyCtrl.f+flyCtrl.b)*0.2,0)).Position-camCF.Position))*flySpd
                flyLastCtrl={f=flyCtrl.f,b=flyCtrl.b,l=flyCtrl.l,r=flyCtrl.r}
            elseif flySpd~=0 then
                flyBV.Velocity=((camCF.LookVector*(flyLastCtrl.f+flyLastCtrl.b))
                    +((camCF*CFrame.new(flyLastCtrl.l+flyLastCtrl.r,(flyLastCtrl.f+flyLastCtrl.b)*0.2,0)).Position-camCF.Position))*flySpd
            else
                flyBV.Velocity=Vector3.new(0,0,0)
            end

            -- Up/Down: Space=up, C/LeftControl=down
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                torso.CFrame=torso.CFrame*CFrame.new(0,1,0)
            elseif UserInputService:IsKeyDown(Enum.KeyCode.C)
                or UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                torso.CFrame=torso.CFrame*CFrame.new(0,-1,0)
            end

            flyBG.CFrame=camCF*CFrame.Angles(-math.rad((flyCtrl.f+flyCtrl.b)*50*flySpd/math.max(GetFlyMaxSpeed(),1)),0,0)
        end
        -- Clean up if loop ended naturally
        if flyActive then StopFly() end
    end)
end

-- Mobile fly up/down buttons
local FlyUpBtn, FlyDownBtn

if IsMobile then
    local FlyCtrlBar=Instance.new("Frame",GUI)
    FlyCtrlBar.Size=UDim2.new(0,110,0,54)
    FlyCtrlBar.Position=UDim2.new(1,-125,0.5,-27)
    FlyCtrlBar.BackgroundColor3=T.Panel FlyCtrlBar.BorderSizePixel=0
    Corner(FlyCtrlBar,12) Stroke(FlyCtrlBar,T.Sky,1)
    local BL=Instance.new("UIListLayout",FlyCtrlBar)
    BL.FillDirection=Enum.FillDirection.Horizontal
    BL.HorizontalAlignment=Enum.HorizontalAlignment.Center
    BL.VerticalAlignment=Enum.VerticalAlignment.Center
    BL.Padding=UDim.new(0,6)
    Pad(FlyCtrlBar,8,8,8,8)

    FlyUpBtn=Instance.new("TextButton",FlyCtrlBar)
    FlyUpBtn.Text="▲ UP" FlyUpBtn.Size=UDim2.new(0,42,0,38)
    FlyUpBtn.BackgroundColor3=T.Sky FlyUpBtn.TextColor3=T.White
    FlyUpBtn.Font=Enum.Font.GothamBold FlyUpBtn.TextSize=11
    FlyUpBtn.BorderSizePixel=0 FlyUpBtn.AutoButtonColor=false
    Corner(FlyUpBtn,8)

    FlyDownBtn=Instance.new("TextButton",FlyCtrlBar)
    FlyDownBtn.Text="▼ DN" FlyDownBtn.Size=UDim2.new(0,42,0,38)
    FlyDownBtn.BackgroundColor3=Color3.fromRGB(50,100,200) FlyDownBtn.TextColor3=T.White
    FlyDownBtn.Font=Enum.Font.GothamBold FlyDownBtn.TextSize=11
    FlyDownBtn.BorderSizePixel=0 FlyDownBtn.AutoButtonColor=false
    Corner(FlyDownBtn,8)

    -- Hold to move up/down
    local upHeld, downHeld = false, false
    FlyUpBtn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch then upHeld=true end
    end)
    FlyUpBtn.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch then upHeld=false end
    end)
    FlyDownBtn.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch then downHeld=true end
    end)
    FlyDownBtn.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.Touch then downHeld=false end
    end)

    RunService.Heartbeat:Connect(function()
        if not flyActive then return end
        local char=Char() if not char then return end
        local torso=char:FindFirstChild("UpperTorso") or char:FindFirstChild("Torso")
        if not torso then return end
        if upHeld   then torso.CFrame=torso.CFrame*CFrame.new(0,1,0) end
        if downHeld then torso.CFrame=torso.CFrame*CFrame.new(0,-1,0) end
    end)
end

-- ════════════════════════════════════════
--  FAST COLLECT (E SPAM)
-- ════════════════════════════════════════
-- Spams E key press to auto-collect items/quests
local lastCollect=0

local function FireCollectE()
    -- Method 1: Virtual input (some executors)
    pcall(function()
        local vInput=Instance.new("InputObject")
        vInput.KeyCode=Enum.KeyCode.E
        vInput.UserInputType=Enum.UserInputType.Keyboard
        vInput.UserInputState=Enum.UserInputState.Begin
        game:GetService("UserInputService"):InputBegan:Fire(vInput,false)
    end)

    -- Method 2: ContextActionService fire
    pcall(function()
        local caf=ContextActionService:GetAllBoundActionInfo()
        for name,_ in pairs(caf) do
            -- Fire collect/interact actions
            if name:lower():find("collect") or name:lower():find("interact")
            or name:lower():find("pick") or name:lower():find("gather")
            or name:lower():find("use") then
                ContextActionService:CallFunction(name, Enum.UserInputState.Begin, nil)
            end
        end
    end)

    -- Method 3: keypress() для PC-экзекуторов (Delta/Arceus mobile не поддерживают)
    if safeKeypress then pcall(safeKeypress, 0x45) end

    -- Method 4: ProximityPrompts
    local char=Char()
    local myRoot=Root()
    if char and myRoot then
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("ProximityPrompt") and v.Enabled then
                local checkPart = v.Parent:IsA("BasePart") and v.Parent
                    or (v.Parent:IsA("Model") and (v.Parent.PrimaryPart or v.Parent:FindFirstChildOfClass("BasePart")))
                if checkPart then
                    local dist=(myRoot.Position-checkPart.Position).Magnitude
                    if dist<=v.MaxActivationDistance+5 then
                        if safeFireProximity then
                            pcall(safeFireProximity, v)
                        else
                            -- Fallback для Delta/Arceus
                            pcall(function() v:InputHoldBegin() end)
                        end
                    end
                end
            end
        end
    end

    -- Method 5: ClickDetectors
    if char and myRoot then
        for _,v in pairs(workspace:GetDescendants()) do
            if v:IsA("ClickDetector") then
                local part=v.Parent
                if part and part:IsA("BasePart") then
                    local dist=(myRoot.Position-part.Position).Magnitude
                    if dist<=v.MaxActivationDistance+5 then
                        if safeFireClick then
                            pcall(safeFireClick, v)
                        else
                            -- Fallback для Delta/Arceus
                            pcall(function() v.MouseClick:Fire(LP) end)
                        end
                    end
                end
            end
        end
    end
end

RunService.Heartbeat:Connect(function()
    if not Cfg.FastCollect.On then return end
    -- Delay slider 1-20 maps to 0.05s – 1s interval (lower = faster spam)
    local interval = 0.05 + (Cfg.FastCollect.Delay - 1) * (0.95/19)
    if tick()-lastCollect < interval then return end
    lastCollect=tick()
    FireCollectE()
end)

-- ════════════════════════════════════════
--  TABS
-- ════════════════════════════════════════
local TABS={
    {name="Combat", icon="⚔️"},
    {name="Move",   icon="🏃"},
    {name="Fly",    icon="✈️"},
    {name="Server", icon="🌐"},
    {name="Config", icon="💾"},
}
local TabBtns={} local ActiveTab=nil

for _,tab in ipairs(TABS) do
    local Btn=Instance.new("TextButton",TabBar)
    Btn.Size=UDim2.new(0.2,-3,1,0)
    Btn.BackgroundColor3=T.Card Btn.Text=tab.icon.." "..tab.name
    Btn.TextSize=IsMobile and 10 or 10
    Btn.BorderSizePixel=0 Btn.Font=Enum.Font.GothamBold
    Btn.TextColor3=T.Sub Btn.AutoButtonColor=false
    Corner(Btn,6)
    TabBtns[tab.name]=Btn
end

local function ClearScroll()
    for _,c in pairs(Scroll:GetChildren()) do
        if not c:IsA("UIListLayout") and not c:IsA("UIPadding") then c:Destroy() end
    end
end

local function SwitchTab(name)
    if ActiveTab==name then return end
    if ActiveTab and TabBtns[ActiveTab] then
        Tw(TabBtns[ActiveTab],{BackgroundColor3=T.Card,TextColor3=T.Sub})
    end
    ClearScroll() ActiveTab=name
    Tw(TabBtns[name],{BackgroundColor3=T.Acc,TextColor3=T.White})

    -- ─── COMBAT ─────────────────────────────
    if name=="Combat" then
        Sec("Fling",T.Red)
        Toggle("Mini Fling","💥","G = кинуть",T.Red,
            function() return Cfg.Fling.On end,
            function(v) Cfg.Fling.On=v end,
            function(v) Notify("💥 Fling",v and "ON" or "OFF",T.Red,2) end)
        Slider("Fling Power","🚀",T.Red,50,800,
            function() return Cfg.Fling.Power end,
            function(v) Cfg.Fling.Power=v end," pw")
        Slider("Fling Range","📡",T.Red,5,50,
            function() return Cfg.Fling.Range end,
            function(v) Cfg.Fling.Range=v end," st")
        Sec("Auto Spam",T.Acc)
        Toggle("Auto Spam","⚡","Авто-стрельба/удар",T.Acc,
            function() return Cfg.Spam.On end,
            function(v) Cfg.Spam.On=v end,
            function(v) Notify("⚡ Spam",v and "ON" or "OFF",T.Acc,2) end)
        Slider("Spam Delay","⏱",T.Acc,1,30,
            function() return Cfg.Spam.Delay end,
            function(v) Cfg.Spam.Delay=v end," ms")
        Sec("Fast Collect",T.Lime)
        Toggle("Fast Collect E","🌿","Авто-сбор: спам E",T.Lime,
            function() return Cfg.FastCollect.On end,
            function(v) Cfg.FastCollect.On=v end,
            function(v) Notify("🌿 Fast Collect",v and "E-спам включён!" or "OFF",T.Lime,2) end)
        Slider("Collect Speed","⏩",T.Lime,1,20,
            function() return Cfg.FastCollect.Delay end,
            function(v) Cfg.FastCollect.Delay=v end," (1=fast)")

    -- ─── MOVE ───────────────────────────────
    elseif name=="Move" then
        Sec("Speed",T.Blue)
        Toggle("Speed Hack","💨","Кастомная скорость",T.Blue,
            function() return Cfg.Speed.On end,
            function(v) Cfg.Speed.On=v
                local h=Hum() if h then h.WalkSpeed=v and Cfg.Speed.Value or 16 end
            end,
            function(v) Notify("💨 Speed",v and "ON "..Cfg.Speed.Value.." WS" or "OFF",T.Blue,2) end)
        Slider("Speed Value","🔢",T.Blue,16,500,
            function() return Cfg.Speed.Value end,
            function(v) Cfg.Speed.Value=v
                if Cfg.Speed.On then local h=Hum() if h then h.WalkSpeed=v end end
            end," ws")
        Sec("Jump",T.Purple)
        Toggle("Infinity Jump","🚀","Без ограничений",T.Purple,
            function() return Cfg.InfJump.On end,
            function(v) Cfg.InfJump.On=v end,
            function(v) Notify("🚀 InfJump",v and "ON" or "OFF",T.Purple,2) end)
        Slider("Jump Power","⬆️",T.Purple,50,400,
            function() return Cfg.InfJump.Power end,
            function(v) Cfg.InfJump.Power=v end," jp")
        Sec("Lock & Protect",T.Cyan)
        Toggle("Shift Lock","🔒","Поворот за камерой",T.Cyan,
            function() return Cfg.ShiftLock.On end,
            function(v) Cfg.ShiftLock.On=v end,
            function(v) Notify("🔒 ShiftLock",v and "ON" or "OFF",T.Cyan,2) end)
        Toggle("Anti Ragdoll","🛡️","Kill joint constraints",T.Green,
            function() return Cfg.AntiRag.On end,
            function(v) Cfg.AntiRag.On=v end,
            function(v) Notify("🛡️ AntiRag",v and "ON" or "OFF",T.Green,2) end)
        Toggle("Anti Anti-Cheat","🔮","Защита значений",T.Cyan,
            function() return Cfg.AntiAC.On end,
            function(v) Cfg.AntiAC.On=v end,
            function(v) Notify("🔮 AntiAC",v and "ON" or "OFF",T.Cyan,2) end)

    -- ─── FLY ────────────────────────────────
    elseif name=="Fly" then
        Sec("✈️ Fly (FlyGuiV3)", T.Sky)

        -- Fly info card
        local InfoCard=Instance.new("Frame",Scroll)
        InfoCard.Size=UDim2.new(1,0,0,IsMobile and 92 or 82)
        InfoCard.BackgroundColor3=T.Card InfoCard.BorderSizePixel=0
        Corner(InfoCard,10) Stroke(InfoCard,T.Sky,1)
        local controlLines= IsMobile and {
            "✈️ WASD / Joystick — направление",
            "▲ UP  /  ▼ DN — высота (кнопки справа)",
            "📱 Fly кнопка — включить/выключить",
        } or {
            "✈️ WASD        — направление",
            "Space         — подняться вверх",
            "C / LCtrl     — опуститься вниз",
            "F key         — вкл/выкл полёт",
        }
        for i,l in ipairs(controlLines) do
            local LL=Instance.new("TextLabel",InfoCard)
            LL.Text=l LL.Size=UDim2.new(1,-16,0,15) LL.Position=UDim2.new(0,10,0,(i-1)*17+7)
            LL.BackgroundTransparency=1 LL.TextColor3=T.Text
            LL.Font=Enum.Font.Gotham LL.TextSize=11 LL.TextXAlignment=Enum.TextXAlignment.Left
        end

        -- Fly toggle
        Toggle("Fly","✈️","Полёт (R6 + R15)",T.Sky,
            function() return flyActive end,
            function(v)
                if v and not flyActive then StartFly()
                elseif not v and flyActive then StopFly() end
            end,
            function(v)
                Cfg.Fly.On=v ScheduleSave()
                Notify("✈️ Fly",v and "Полёт включён!" or "Приземляемся",T.Sky,2)
            end)

        Slider("Fly Speed","🏎️",T.Sky,1,10,
            function() return Cfg.Fly.Speed end,
            function(v)
                Cfg.Fly.Speed=v
                -- Speed applies dynamically via GetFlyMaxSpeed() in the fly loop
            end," x")

    -- ─── SERVER ─────────────────────────────
    elseif name=="Server" then
        Sec("Server Tools",T.Blue)
        ActionBtn("Rejoin","🔄",T.Blue,"Переподключение",function()
            Notify("🔄 Rejoin","Переподключаемся...",T.Blue,2)
            task.delay(1,function() TeleportService:Teleport(game.PlaceId,LP) end)
        end)
        ActionBtn("Server Hop","🌐",T.Purple,"Найти новый сервер",function()
            Notify("🌐 ServerHop","Ищем сервер...",T.Purple,3)
            task.spawn(function()
                local ok,servers=pcall(function()
                    return HttpService:JSONDecode(
                        game:HttpGet("https://games.roblox.com/v1/games/"..game.PlaceId
                        .."/servers/Public?sortOrder=Desc&limit=100"))
                end)
                if ok and servers and servers.data then
                    for _,s in ipairs(servers.data) do
                        if s.id~=game.JobId and s.playing<s.maxPlayers then
                            Notify("🌐 Прыгаем!","Нашли сервер",T.Purple,2)
                            task.wait(0.5)
                            pcall(function()
                                TeleportService:TeleportToPlaceInstance(game.PlaceId,s.id,LP)
                            end)
                            return
                        end
                    end
                end
                Notify("🌐 Fallback","Новый сервер",T.Purple,2)
                task.wait(0.5) TeleportService:Teleport(game.PlaceId,LP)
            end)
        end)
        Sec("Lag",T.Red)
        Toggle("Server Lag","⚡","Спам RemoteEvents",T.Red,
            function() return Cfg.ServLag.On end,
            function(v) Cfg.ServLag.On=v end,
            function(v) Notify("⚡ ServLag",v and "ЛАГАЕМ!" or "Стоп",T.Red,2) end)
        Slider("Lag Threads","🧵",T.Red,10,200,
            function() return Cfg.ServLag.Threads end,
            function(v) Cfg.ServLag.Threads=v end," thr")

    -- ─── CONFIG ─────────────────────────────
    elseif name=="Config" then
        Sec("💾 Config Manager",T.Yellow)
        local InfoCard=Instance.new("Frame",Scroll)
        InfoCard.Size=UDim2.new(1,0,0,56) InfoCard.BackgroundColor3=T.Card
        InfoCard.BorderSizePixel=0
        Corner(InfoCard,10) Stroke(InfoCard,T.Yellow,1)
        local function cfgStatus()
            if readfile then
                local ok,raw=pcall(readfile,CFG_FILE)
                if ok and raw and #raw>2 then return "✅ Найден ("..#raw.." байт)" end
            end
            return writefile and "⚠️ Не создан (нажми Save)" or "❌ FS не поддерживается"
        end
        local FL=Instance.new("TextLabel",InfoCard)
        FL.Text="📂 "..CFG_FILE FL.Size=UDim2.new(1,-16,0,18) FL.Position=UDim2.new(0,10,0,6)
        FL.BackgroundTransparency=1 FL.TextColor3=T.Yellow FL.Font=Enum.Font.GothamBold FL.TextSize=11
        FL.TextXAlignment=Enum.TextXAlignment.Left
        local SL=Instance.new("TextLabel",InfoCard)
        SL.Text=cfgStatus() SL.Size=UDim2.new(1,-16,0,14) SL.Position=UDim2.new(0,10,0,28)
        SL.BackgroundTransparency=1 SL.TextColor3=T.Sub SL.Font=Enum.Font.Gotham SL.TextSize=10
        SL.TextXAlignment=Enum.TextXAlignment.Left
        local AL=Instance.new("TextLabel",InfoCard)
        AL.Text="⚡ Auto-save: 1.5с после изменения" AL.Size=UDim2.new(1,-16,0,13)
        AL.Position=UDim2.new(0,10,0,40) AL.BackgroundTransparency=1 AL.TextColor3=T.Sub
        AL.Font=Enum.Font.Gotham AL.TextSize=9 AL.TextXAlignment=Enum.TextXAlignment.Left

        ActionBtn("Save Now","💾",T.Yellow,"Принудительно сохранить",function()
            SaveCfg(Cfg) SL.Text=cfgStatus()
            Notify("💾 Сохранено","CFG обновлён",T.Yellow,2)
        end)
        ActionBtn("Reset Defaults","🔄",T.Red,"Сброс всех настроек",function()
            Cfg=DeepCopy(DEFAULT_CFG) SaveCfg(Cfg) SL.Text=cfgStatus()
            if flyActive then StopFly() end
            Notify("🔄 Сброс","Настройки по умолчанию",T.Red,2)
        end)

        Sec("Auto-Reload Info",T.Blue)
        local ALCard=Instance.new("Frame",Scroll)
        ALCard.Size=UDim2.new(1,0,0,100) ALCard.BackgroundColor3=T.Card
        ALCard.BorderSizePixel=0
        Corner(ALCard,10) Stroke(ALCard,T.Blue,1)
        local alL={"🔄 Respawn → все фичи восстановятся","💨 Speed WalkSpeed","🚀 InfJump JumpPower",
                   "🛡️ AntiRag суставы","🔮 AntiAC property guard","✈️ Fly — НЕ авто (ручной старт)"}
        for i,l in ipairs(alL) do
            local LL=Instance.new("TextLabel",ALCard)
            LL.Text=l LL.Size=UDim2.new(1,-16,0,14) LL.Position=UDim2.new(0,10,0,(i-1)*15+5)
            LL.BackgroundTransparency=1 LL.TextColor3=T.Text LL.Font=Enum.Font.Gotham
            LL.TextSize=10 LL.TextXAlignment=Enum.TextXAlignment.Left
        end
    end
end

SwitchTab("Combat")
for _,tab in ipairs(TABS) do
    TabBtns[tab.name].MouseButton1Click:Connect(function() SwitchTab(tab.name) end)
    TabBtns[tab.name].TouchTap:Connect(function() SwitchTab(tab.name) end)
end

-- ════════════════════════════════════════
--  MINIMIZE + DRAG
-- ════════════════════════════════════════
local minimized=false
MinBtn.MouseButton1Click:Connect(function()
    minimized=not minimized
    Tw(Win,{Size=minimized and UDim2.new(0,W,0,57) or UDim2.new(0,W,0,H)},0.3,Enum.EasingStyle.Back)
    TabBar.Visible=not minimized Scroll.Visible=not minimized
    MinBtn.Text=minimized and "+" or "−"
end)
local dS,dWP
Head.InputBegan:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.UserInputType==Enum.UserInputType.Touch then dS=i.Position dWP=Win.Position end
end)
UserInputService.InputChanged:Connect(function(i)
    if dS and (i.UserInputType==Enum.UserInputType.MouseMovement
    or i.UserInputType==Enum.UserInputType.Touch) then
        local d=i.Position-dS
        Win.Position=UDim2.new(dWP.X.Scale,dWP.X.Offset+d.X,dWP.Y.Scale,dWP.Y.Offset+d.Y)
    end
end)
UserInputService.InputEnded:Connect(function(i)
    if i.UserInputType==Enum.UserInputType.MouseButton1
    or i.UserInputType==Enum.UserInputType.Touch then dS=nil end
end)

-- ════════════════════════════════════════
--  MOBILE BOTTOM BAR
-- ════════════════════════════════════════
if IsMobile then
    local BBar=Instance.new("Frame",GUI)
    BBar.Size=UDim2.new(0,330,0,54)
    BBar.Position=UDim2.new(0.5,-165,1,-70)
    BBar.BackgroundColor3=T.Panel BBar.BorderSizePixel=0
    Corner(BBar,14) Stroke(BBar,T.Acc,1)
    local BL=Instance.new("UIListLayout",BBar)
    BL.FillDirection=Enum.FillDirection.Horizontal
    BL.HorizontalAlignment=Enum.HorizontalAlignment.Center
    BL.VerticalAlignment=Enum.VerticalAlignment.Center
    BL.Padding=UDim.new(0,5)
    Pad(BBar,6,6,8,8)

    local function MobBtn(icon,col,cb)
        local B=Instance.new("TextButton",BBar)
        B.Size=UDim2.new(0,52,0,38) B.BackgroundColor3=col
        B.Text=icon B.TextSize=11 B.Font=Enum.Font.GothamBold
        B.TextColor3=T.White B.BorderSizePixel=0 B.AutoButtonColor=false
        Corner(B,10)
        local function act()
            Tw(B,{BackgroundColor3=T.White},0.08)
            task.delay(0.15,function() Tw(B,{BackgroundColor3=col},0.15) end)
            cb()
        end
        B.TouchTap:Connect(act) B.MouseButton1Click:Connect(act)
        return B
    end

    MobBtn("✈️ Fly",T.Sky,function()
        if not flyActive then StartFly() else StopFly() end
        Notify("✈️ Fly",flyActive and "ON" or "OFF",T.Sky,1.5)
    end)
    MobBtn("💨Speed",T.Blue,function()
        Cfg.Speed.On=not Cfg.Speed.On ScheduleSave()
        local h=Hum() if h then h.WalkSpeed=Cfg.Speed.On and Cfg.Speed.Value or 16 end
        Notify("💨 Speed",Cfg.Speed.On and "ON" or "OFF",T.Blue,1.5)
    end)
    MobBtn("🚀Jump",T.Purple,function()
        Cfg.InfJump.On=not Cfg.InfJump.On ScheduleSave()
        Notify("🚀 Jump",Cfg.InfJump.On and "ON" or "OFF",T.Purple,1.5)
    end)
    MobBtn("🌿Colct",T.Lime,function()
        Cfg.FastCollect.On=not Cfg.FastCollect.On ScheduleSave()
        Notify("🌿 Collect",Cfg.FastCollect.On and "E-спам ON" or "OFF",T.Lime,1.5)
    end)
    MobBtn("💥Fling",T.Red,function()
        if not Cfg.Fling.On then return end
        local root=Root() if not root then return end
        local near,d=nil,math.huge
        for _,p in pairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                local pr=p.Character:FindFirstChild("HumanoidRootPart")
                if pr then
                    local dd=(root.Position-pr.Position).Magnitude
                    if dd<d and dd<Cfg.Fling.Range then d=dd near=pr end
                end
            end
        end
        if near then
            local dir=(near.Position-root.Position).Unit
            near.Velocity=dir*Cfg.Fling.Power+Vector3.new(math.random(-50,50),Cfg.Fling.Power*0.6,math.random(-50,50))
        end
    end)
    MobBtn("🌐Hop",T.Purple,function()
        Notify("🌐 Hop","Прыгаем...",T.Purple,2)
        task.delay(1,function() TeleportService:Teleport(game.PlaceId,LP) end)
    end)
end

-- ════════════════════════════════════════
--  PC KEYBINDS
-- ════════════════════════════════════════
UserInputService.InputBegan:Connect(function(input,gpe)
    if gpe then return end

    -- F = fly toggle
    if input.KeyCode==Enum.KeyCode.F then
        if not flyActive then StartFly() else StopFly() end
        Notify("✈️ Fly",flyActive and "Включён!" or "Выключен",T.Sky,2)
    end

    -- G = fling
    if input.KeyCode==Enum.KeyCode.G and Cfg.Fling.On then
        local root=Root() if not root then return end
        local near,d=nil,math.huge
        for _,p in pairs(Players:GetPlayers()) do
            if p~=LP and p.Character then
                local pr=p.Character:FindFirstChild("HumanoidRootPart")
                if pr then
                    local dd=(root.Position-pr.Position).Magnitude
                    if dd<d and dd<Cfg.Fling.Range then d=dd near=pr end
                end
            end
        end
        if near then
            local dir=(near.Position-root.Position).Unit
            near.Velocity=dir*Cfg.Fling.Power+Vector3.new(math.random(-60,60),Cfg.Fling.Power*0.65,math.random(-60,60))
            Notify("💥 Fling!",near.Parent.Name,T.Red,1.5)
        end
    end
end)

-- ════════════════════════════════════════
--  AUTO-APPLY ON RESPAWN
-- ════════════════════════════════════════
local function ApplyAll(char,isRespawn)
    task.wait(0.7)
    local h=char and char:FindFirstChildOfClass("Humanoid")
    if not h then return end
    if Cfg.Speed.On   then h.WalkSpeed=Cfg.Speed.Value end
    if Cfg.InfJump.On then h.JumpPower=Cfg.InfJump.Power end
    if Cfg.AntiRag.On then
        for _,v in pairs(char:GetDescendants()) do
            if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") then
                pcall(function() v.Enabled=false end)
            end
        end
        char.DescendantAdded:Connect(function(d)
            if Cfg.AntiRag.On and (d:IsA("BallSocketConstraint") or d:IsA("HingeConstraint")) then
                pcall(function() d.Enabled=false end)
            end
        end)
    end
    if Cfg.AntiAC.On then
        h:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
            if Cfg.AntiAC.On and Cfg.Speed.On then task.defer(function() pcall(function() h.WalkSpeed=Cfg.Speed.Value end) end) end
        end)
        h:GetPropertyChangedSignal("JumpPower"):Connect(function()
            if Cfg.AntiAC.On and Cfg.InfJump.On then task.defer(function() pcall(function() h.JumpPower=Cfg.InfJump.Power end) end) end
        end)
    end
    if flyActive then StopFly() end -- Reset fly on respawn
    if isRespawn then
        local feats={}
        if Cfg.Speed.On    then table.insert(feats,"💨"..Cfg.Speed.Value) end
        if Cfg.InfJump.On  then table.insert(feats,"🚀") end
        if Cfg.AntiRag.On  then table.insert(feats,"🛡️") end
        if Cfg.AntiAC.On   then table.insert(feats,"🔮") end
        if Cfg.FastCollect.On then table.insert(feats,"🌿") end
        if #feats>0 then Notify("🔄 Reload",table.concat(feats," "),T.Blue,3) end
    end
end

LP.CharacterAdded:Connect(function(char) ApplyAll(char,true) end)
if LP.Character then ApplyAll(LP.Character,false) end

-- ════════════════════════════════════════
--  HEARTBEAT LOOPS
-- ════════════════════════════════════════
RunService.Heartbeat:Connect(function()
    -- Speed
    if Cfg.Speed.On then
        local h=Hum()
        if h and h.WalkSpeed~=Cfg.Speed.Value then h.WalkSpeed=Cfg.Speed.Value end
    end
    -- AntiRag
    if Cfg.AntiRag.On then
        local c=Char() if c then
            for _,v in pairs(c:GetDescendants()) do
                if v:IsA("BallSocketConstraint") or v:IsA("HingeConstraint") then
                    pcall(function() v.Enabled=false end)
                end
            end
        end
    end
    -- AntiAC
    if Cfg.AntiAC.On then
        local h=Hum() if h then
            if Cfg.Speed.On and h.WalkSpeed~=Cfg.Speed.Value then h.WalkSpeed=Cfg.Speed.Value end
            if Cfg.InfJump.On and h.JumpPower~=Cfg.InfJump.Power then h.JumpPower=Cfg.InfJump.Power end
        end
    end
end)

-- InfJump
UserInputService.JumpRequest:Connect(function()
    if not Cfg.InfJump.On then return end
    local h=Hum() if not h then return end
    h:ChangeState(Enum.HumanoidStateType.Jumping)
    local root=Root()
    if root then
        local bv=Instance.new("BodyVelocity")
        bv.Velocity=Vector3.new(root.Velocity.X,Cfg.InfJump.Power,root.Velocity.Z)
        bv.MaxForce=Vector3.new(0,4e5,0) bv.P=1e5
        bv.Parent=root game:GetService("Debris"):AddItem(bv,0.12)
    end
end)

-- ShiftLock
RunService.RenderStepped:Connect(function()
    local char=Char() if not char then return end
    local root=char:FindFirstChild("HumanoidRootPart")
    local h=char:FindFirstChildOfClass("Humanoid")
    if not (root and h) then return end
    if Cfg.ShiftLock.On then
        UserInputService.MouseBehavior=Enum.MouseBehavior.LockCenter
        local lv=Camera.CFrame.LookVector
        local xz=Vector3.new(lv.X,0,lv.Z)
        if xz.Magnitude>0.01 then
            root.CFrame=root.CFrame:Lerp(
                CFrame.new(root.CFrame.Position,root.CFrame.Position+xz),0.6)
        end
        h.CameraOffset=h.CameraOffset:Lerp(Vector3.new(1.75,0,0),0.2)
    else
        if UserInputService.MouseBehavior==Enum.MouseBehavior.LockCenter then
            UserInputService.MouseBehavior=Enum.MouseBehavior.Default
        end
        h.CameraOffset=h.CameraOffset:Lerp(Vector3.new(0,0,0),0.2)
    end
end)

-- Auto Spam
local lastSpam=0
RunService.Heartbeat:Connect(function()
    if not Cfg.Spam.On then return end
    if tick()-lastSpam<Cfg.Spam.Delay/100 then return end
    lastSpam=tick()
    local char=Char() if not char then return end
    local tool=char:FindFirstChildOfClass("Tool")
    if tool then
        for _,v in pairs(tool:GetDescendants()) do
            if v:IsA("RemoteEvent") then pcall(function() v:FireServer(Mouse.Hit) end) end
        end
    end
    if safeMouse1Click then pcall(safeMouse1Click) end
end)

-- Server Lag
local lagRunning=false
RunService.Heartbeat:Connect(function()
    if not Cfg.ServLag.On then lagRunning=false return end
    if lagRunning then return end
    lagRunning=true
    task.spawn(function()
        while Cfg.ServLag.On do
            for _=1,Cfg.ServLag.Threads do
                task.spawn(function()
                    for _,v in pairs(game:GetDescendants()) do
                        if v:IsA("RemoteEvent") and Cfg.ServLag.On then
                            pcall(function() v:FireServer() end)
                        end
                    end
                end)
            end
            task.wait(0.05)
        end
        lagRunning=false
    end)
end)

-- ════════════════════════════════════════
--  STARTUP
-- ════════════════════════════════════════
if not readfile then CfgLbl.Text="CFG:NO FS" end

task.delay(0.3,function()
    Notify("🥟 Pelmen PVP v4.1",
        "✈️ Fly · 🌿 FastCollect · 💾 CFG · "..(IsMobile and "Mobile" or "PC"),
        T.Acc,5)
end)
task.delay(2,function()
    local on={}
    if Cfg.Speed.On      then table.insert(on,"💨Speed") end
    if Cfg.InfJump.On    then table.insert(on,"🚀Jump") end
    if Cfg.Fling.On      then table.insert(on,"💥Fling") end
    if Cfg.FastCollect.On then table.insert(on,"🌿Collect") end
    if Cfg.Spam.On       then table.insert(on,"⚡Spam") end
    if Cfg.AntiRag.On    then table.insert(on,"🛡️AntiRag") end
    if #on>0 then Notify("📂 CFG Восстановлен",table.concat(on," "),T.Yellow,5) end
end)

print("╔══════════════════════════════════════════╗")
print("║   🥟 PELMEN PVP v4.3 — PC + MOBILE     ║")
print("║   ✈️ Fly:      F key (PC) | Button (mob) ║")
print("║   🌿 Collect:  E-спам + ProximityPrompt  ║")
print("║   ⬆️ Fly Up:   Space | ⬇️ Down: C/LCtrl  ║")
print("║   📱 Delta · Arceus X · Fluxus · Synapse ║")
print("║   🔧 Executor: "..tostring(ExecName)..string.rep(" ",26-#tostring(ExecName)).."║")
print("╚══════════════════════════════════════════╝")
