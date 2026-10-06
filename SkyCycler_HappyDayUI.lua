--[[
  ★ Sky Cycler + 自動チャット(2連投防止) + ゲームUI緑グラデ
     + リアルグラフィック強化 + プレイヤー操作 + ビジュアル(ESP) + ユーティリティ
     UI: Happy DayUI (アップロードされたImoHub UIをベースに全面採用)
  - 起動時: 必ずサウンド再生 + スプラッシュ(ロゴ拡大+プログレスバー)モーション
  - メインウィンドウ: フェード+拡大のオープンアニメーション
  - トグル/タブ切替: Tweenでなめらかに変化
  - 通知: スライドイン/アウト対応のHappy DayUI標準Notify
]]

-- ==============================
-- サービス (Happy DayUIの命名に統一)
-- ==============================
local UIS=game:GetService("UserInputService")
local CG=game:GetService("CoreGui")
local T=game:GetService("TweenService")
local SS=game:GetService("SoundService")
local Players=game:GetService("Players")
local RS=game:GetService("ReplicatedStorage")
local WS=game:GetService("Workspace")
local RUN=game:GetService("RunService")
local LT=game:GetService("Lighting")
local TPS=game:GetService("TeleportService")
local TCS=game:GetService("TextChatService")
local LP=Players.LocalPlayer

local BGI="rbxassetid://104851146092192"
local SND="rbxassetid://9085027122"
local C={Sec=Color3.fromRGB(25,55,60),Ter=Color3.fromRGB(35,75,85),GS=Color3.fromRGB(80,255,180),GE=Color3.fromRGB(80,180,255),Acc=Color3.fromRGB(120,255,200),Tx=Color3.fromRGB(240,255,250),Sub=Color3.fromRGB(150,200,200),Brd=Color3.fromRGB(100,220,200),Tg=Color3.fromRGB(80,255,180),TgO=Color3.fromRGB(70,100,110)}

-- ==============================
-- ★ 起動サウンド (必ず再生) ★
-- ==============================
local function PlayBootSound()
	local ok=pcall(function()
		local s=Instance.new("Sound")
		s.Name="HDBootSound"
		s.SoundId=SND
		s.Volume=0.6
		s.Parent=SS
		if not s.IsLoaded then
			pcall(function() s.Loaded:Wait() end)
		end
		s:Play()
		task.delay(8,function() pcall(function() s:Destroy() end) end)
	end)
	if not ok then
		-- フォールバック: どんな状況でも必ず鳴らす
		pcall(function()
			local s2=Instance.new("Sound")
			s2.SoundId=SND
			s2.Volume=0.6
			s2.Parent=SS
			s2:Play()
			task.delay(8,function() pcall(function() s2:Destroy() end) end)
		end)
	end
end

-- ==============================
-- ★ 起動スプラッシュ (ロゴ拡大 + プログレスバー) ★
-- ==============================
local function ShowBootSplash(onDone)
	PlayBootSound()

	local boot=Instance.new("ScreenGui")
	boot.Name="HDBoot"
	boot.ResetOnSpawn=false
	boot.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
	boot.DisplayOrder=1000
	boot.Parent=CG

	local bg=Instance.new("Frame",boot)
	bg.Size=UDim2.new(1,0,1,0)
	bg.BackgroundColor3=Color3.fromRGB(8,15,16)
	bg.BackgroundTransparency=1
	bg.BorderSizePixel=0
	T:Create(bg,TweenInfo.new(.4),{BackgroundTransparency=0}):Play()

	local logo=Instance.new("TextLabel",bg)
	logo.AnchorPoint=Vector2.new(.5,.5)
	logo.Position=UDim2.new(.5,0,.42,0)
	logo.Size=UDim2.new(0,10,0,10)
	logo.BackgroundTransparency=1
	logo.Text="NEKO HUB"
	logo.TextColor3=C.Tx
	logo.Font=Enum.Font.GothamBlack
	logo.TextScaled=true
	logo.TextTransparency=1
	local logoGrad=Instance.new("UIGradient",logo)
	logoGrad.Color=ColorSequence.new(C.GS,C.GE)
	logoGrad.Rotation=45
	T:Create(logo,TweenInfo.new(.6,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
		{Size=UDim2.new(0,280,0,60),TextTransparency=0}):Play()

	local sub=Instance.new("TextLabel",bg)
	sub.AnchorPoint=Vector2.new(.5,.5)
	sub.Position=UDim2.new(.5,0,.52,0)
	sub.Size=UDim2.new(0,320,0,20)
	sub.BackgroundTransparency=1
	sub.Text="Sky Cycler Edition 起動中..."
	sub.TextColor3=C.Sub
	sub.Font=Enum.Font.Gotham
	sub.TextSize=13
	sub.TextTransparency=1
	task.delay(.3,function() T:Create(sub,TweenInfo.new(.4),{TextTransparency=0}):Play() end)

	local barBg=Instance.new("Frame",bg)
	barBg.AnchorPoint=Vector2.new(.5,.5)
	barBg.Position=UDim2.new(.5,0,.6,0)
	barBg.Size=UDim2.new(0,300,0,6)
	barBg.BackgroundColor3=C.TgO
	barBg.BackgroundTransparency=.2
	barBg.BorderSizePixel=0
	Instance.new("UICorner",barBg).CornerRadius=UDim.new(1,0)

	local barFill=Instance.new("Frame",barBg)
	barFill.Size=UDim2.new(0,0,1,0)
	barFill.BackgroundColor3=C.Acc
	barFill.BorderSizePixel=0
	Instance.new("UICorner",barFill).CornerRadius=UDim.new(1,0)
	local barGrad=Instance.new("UIGradient",barFill)
	barGrad.Color=ColorSequence.new(C.GS,C.GE)

	local pctLbl=Instance.new("TextLabel",bg)
	pctLbl.AnchorPoint=Vector2.new(.5,.5)
	pctLbl.Position=UDim2.new(.5,0,.65,0)
	pctLbl.Size=UDim2.new(0,100,0,16)
	pctLbl.BackgroundTransparency=1
	pctLbl.Text="0%"
	pctLbl.TextColor3=C.Sub
	pctLbl.Font=Enum.Font.GothamMedium
	pctLbl.TextSize=12
	pctLbl.TextTransparency=1
	task.delay(.3,function() T:Create(pctLbl,TweenInfo.new(.3),{TextTransparency=0}):Play() end)

	task.spawn(function()
		task.wait(.5)
		local steps={15,38,55,72,88,100}
		for _,p in ipairs(steps) do
			T:Create(barFill,TweenInfo.new(.25,Enum.EasingStyle.Quad),{Size=UDim2.new(p/100,0,1,0)}):Play()
			pctLbl.Text=p.."%"
			task.wait(.22)
		end
		task.wait(.3)
		local fadeOut=T:Create(bg,TweenInfo.new(.5),{BackgroundTransparency=1})
		T:Create(logo,TweenInfo.new(.4),{TextTransparency=1}):Play()
		T:Create(sub,TweenInfo.new(.4),{TextTransparency=1}):Play()
		T:Create(pctLbl,TweenInfo.new(.4),{TextTransparency=1}):Play()
		fadeOut:Play()
		fadeOut.Completed:Wait()
		pcall(function() boot:Destroy() end)
		if onDone then onDone() end
	end)
end

-- ==============================
-- ★ Happy DayUI ライブラリ本体 (アップロードされたUIをベースに移植 + モーション強化) ★
-- ==============================
local H={} local N={}

function H:Notify(t,d)
	d=d or 3
	local g=CG:FindFirstChild("HDN") or Instance.new("ScreenGui",CG)
	g.Name="HDN" g.ResetOnSpawn=false
	local f=Instance.new("Frame",g)
	f.Size=UDim2.new(0,280,0,52)
	f.Position=UDim2.new(1,20,0,20+#N*62)
	f.BackgroundColor3=C.Sec f.BackgroundTransparency=1 f.BorderSizePixel=0
	Instance.new("UICorner",f).CornerRadius=UDim.new(0,8)
	local st=Instance.new("UIStroke",f) st.Color=C.Brd st.Thickness=1 st.Transparency=.3
	local gr=Instance.new("UIGradient",st) gr.Color=ColorSequence.new(C.GS,C.GE) gr.Rotation=45
	local l=Instance.new("TextLabel",f)
	l.Size=UDim2.new(1,-25,1,0) l.Position=UDim2.new(0,18,0,0)
	l.BackgroundTransparency=1 l.Text=tostring(t) l.TextColor3=C.Tx
	l.Font=Enum.Font.GothamMedium l.TextSize=13
	l.TextXAlignment=Enum.TextXAlignment.Left l.TextWrapped=true
	table.insert(N,f)

	-- スライドイン
	T:Create(f,TweenInfo.new(.3,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
		{Position=UDim2.new(1,-300,0,20+(#N-1)*62),BackgroundTransparency=.15}):Play()

	task.delay(d,function()
		for i,n in ipairs(N) do if n==f then table.remove(N,i) break end end
		-- スライドアウト
		local outTween=T:Create(f,TweenInfo.new(.25,Enum.EasingStyle.Quad),
			{Position=UDim2.new(1,20,0,f.Position.Y.Offset),BackgroundTransparency=1})
		outTween:Play()
		outTween.Completed:Wait()
		pcall(function() f:Destroy() end)
		for i,n in ipairs(N) do
			T:Create(n,TweenInfo.new(.2),{Position=UDim2.new(1,-300,0,20+(i-1)*62)}):Play()
		end
	end)
end

function H:CreateWindow(cfg)
	cfg=cfg or {}
	local gui=Instance.new("ScreenGui",CG)
	gui.Name="HDUI" gui.ResetOnSpawn=false gui.ZIndexBehavior=Enum.ZIndexBehavior.Sibling
	local m=Instance.new("Frame",gui)
	m.Size=UDim2.new(0,550,0,400)
	m.Position=UDim2.new(.5,-275,.5,-200)
	m.BackgroundTransparency=1 m.BorderSizePixel=0 m.Active=true m.Draggable=true
	Instance.new("UICorner",m).CornerRadius=UDim.new(0,10)
	local bg=Instance.new("ImageLabel",m)
	bg.Size=UDim2.new(1,0,1,0) bg.BackgroundTransparency=1 bg.Image=BGI
	bg.ScaleType=Enum.ScaleType.Crop bg.ZIndex=0
	Instance.new("UICorner",bg).CornerRadius=UDim.new(0,10)
	local ov=Instance.new("Frame",m)
	ov.Size=UDim2.new(1,0,1,0) ov.BackgroundColor3=Color3.new(0,0,0)
	ov.BackgroundTransparency=1 ov.BorderSizePixel=0 ov.ZIndex=1
	Instance.new("UICorner",ov).CornerRadius=UDim.new(0,10)
	local ms=Instance.new("UIStroke",m) ms.Color=C.Brd ms.Thickness=2 ms.Transparency=1
	local mg=Instance.new("UIGradient",ms) mg.Color=ColorSequence.new(C.GS,C.GE) mg.Rotation=45
	local tb=Instance.new("Frame",m)
	tb.Size=UDim2.new(1,0,0,38) tb.BackgroundColor3=C.Sec tb.BackgroundTransparency=1
	tb.BorderSizePixel=0 tb.ZIndex=2
	Instance.new("UICorner",tb).CornerRadius=UDim.new(0,10)
	local tl=Instance.new("TextLabel",tb)
	tl.Size=UDim2.new(1,-90,1,0) tl.Position=UDim2.new(0,16,0,0)
	tl.BackgroundTransparency=1 tl.Text=cfg.Title or "Happy DayUI"
	tl.TextColor3=C.Tx tl.Font=Enum.Font.GothamBold tl.TextSize=16
	tl.TextXAlignment=Enum.TextXAlignment.Left tl.ZIndex=3
	local tg=Instance.new("UIGradient",tl) tg.Color=ColorSequence.new(C.GS,C.GE) tg.Rotation=45
	local minB=Instance.new("TextButton",tb)
	minB.Size=UDim2.new(0,26,0,26) minB.Position=UDim2.new(1,-66,0,6)
	minB.BackgroundColor3=C.Ter minB.BackgroundTransparency=.3
	minB.Text="-" minB.TextColor3=C.Tx minB.Font=Enum.Font.GothamBold minB.TextSize=16
	minB.BorderSizePixel=0 minB.ZIndex=3
	Instance.new("UICorner",minB).CornerRadius=UDim.new(0,6)
	local cb=Instance.new("TextButton",tb)
	cb.Size=UDim2.new(0,26,0,26) cb.Position=UDim2.new(1,-34,0,6)
	cb.BackgroundColor3=C.Ter cb.BackgroundTransparency=.3
	cb.Text="X" cb.TextColor3=C.Tx cb.Font=Enum.Font.GothamBold cb.TextSize=14
	cb.BorderSizePixel=0 cb.ZIndex=3
	Instance.new("UICorner",cb).CornerRadius=UDim.new(0,6)
	cb.MouseButton1Click:Connect(function() gui:Destroy() end)
	local opB=Instance.new("TextButton",gui)
	opB.Size=UDim2.new(0,50,0,50) opB.Position=UDim2.new(1,-70,0,20)
	opB.BackgroundColor3=C.Sec opB.BackgroundTransparency=.15
	opB.Text="開く" opB.TextColor3=C.Tx opB.Font=Enum.Font.GothamBold opB.TextSize=13
	opB.BorderSizePixel=0 opB.Visible=false opB.ZIndex=100
	Instance.new("UICorner",opB).CornerRadius=UDim.new(0,25)
	local obS=Instance.new("UIStroke",opB) obS.Color=C.Brd obS.Thickness=2 obS.Transparency=.2
	local obG=Instance.new("UIGradient",obS) obG.Color=ColorSequence.new(C.GS,C.GE) obG.Rotation=45
	local function doClose()
		if not m.Visible then return end
		local closeT=T:Create(m,TweenInfo.new(.2,Enum.EasingStyle.Quad),{Size=UDim2.new(0,0,0,0)})
		closeT:Play()
		closeT.Completed:Wait()
		m.Visible=false
		m.Size=UDim2.new(0,550,0,400)
		opB.Visible=true
		opB.Size=UDim2.new(0,0,0,0)
		T:Create(opB,TweenInfo.new(.2,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,50,0,50)}):Play()
	end
	local function doOpen()
		if m.Visible then return end
		m.Visible=true
		opB.Visible=false
		m.Size=UDim2.new(0,0,0,0)
		T:Create(m,TweenInfo.new(.25,Enum.EasingStyle.Back,Enum.EasingDirection.Out),{Size=UDim2.new(0,550,0,400)}):Play()
	end
	minB.MouseButton1Click:Connect(doClose)
	opB.MouseButton1Click:Connect(doOpen)
	win.Close=doClose
	win.Open=doOpen
	local tc=Instance.new("Frame",m)
	tc.Size=UDim2.new(0,120,1,-38) tc.Position=UDim2.new(0,0,0,38)
	tc.BackgroundColor3=C.Sec tc.BackgroundTransparency=.5 tc.BorderSizePixel=0 tc.ZIndex=2
	local ts=Instance.new("ScrollingFrame",tc)
	ts.Size=UDim2.new(1,0,1,0) ts.BackgroundTransparency=1 ts.BorderSizePixel=0
	ts.ScrollBarThickness=2 ts.ScrollBarImageColor3=C.Acc
	ts.CanvasSize=UDim2.new() ts.AutomaticCanvasSize=Enum.AutomaticSize.Y ts.ZIndex=3
	local tl2=Instance.new("UIListLayout",ts) tl2.SortOrder=Enum.SortOrder.LayoutOrder tl2.Padding=UDim.new(0,4)
	local tp=Instance.new("UIPadding",ts) tp.PaddingTop=UDim.new(0,8) tp.PaddingLeft=UDim.new(0,6) tp.PaddingRight=UDim.new(0,6)
	local cc=Instance.new("Frame",m)
	cc.Size=UDim2.new(1,-122,1,-42) cc.Position=UDim2.new(0,122,0,38)
	cc.BackgroundTransparency=1 cc.ZIndex=2
	local fl=Instance.new("TextLabel",m)
	fl.Size=UDim2.new(1,-14,0,18) fl.Position=UDim2.new(0,8,1,-22)
	fl.BackgroundTransparency=1 fl.Text=cfg.Footer or "v1.0"
	fl.TextColor3=C.Sub fl.Font=Enum.Font.Gotham fl.TextSize=10
	fl.TextXAlignment=Enum.TextXAlignment.Left fl.ZIndex=3
	local cur=nil
	local mkG
	local win={Gui=gui,MainFrame=m,OpenButton=opB,Notify=function(_,t,d) H:Notify(t,d) end}

	mkG=function(par,title)
		local gf=Instance.new("Frame",par)
		gf.Size=UDim2.new(1,0,0,30) gf.BackgroundColor3=C.Sec gf.BackgroundTransparency=.4
		gf.BorderSizePixel=0 gf.AutomaticSize=Enum.AutomaticSize.Y gf.ZIndex=5
		Instance.new("UICorner",gf).CornerRadius=UDim.new(0,8)
		local st=Instance.new("UIStroke",gf) st.Color=C.Brd st.Thickness=1 st.Transparency=.4
		local sg=Instance.new("UIGradient",st) sg.Color=ColorSequence.new(C.GS,C.GE) sg.Rotation=45
		local pd=Instance.new("UIPadding",gf)
		pd.PaddingTop=UDim.new(0,6) pd.PaddingBottom=UDim.new(0,6)
		pd.PaddingLeft=UDim.new(0,6) pd.PaddingRight=UDim.new(0,6)
		local t=Instance.new("TextLabel",gf)
		t.Size=UDim2.new(1,0,0,20) t.BackgroundTransparency=1 t.Text=title
		t.TextColor3=C.Acc t.Font=Enum.Font.GothamBold t.TextSize=12
		t.TextXAlignment=Enum.TextXAlignment.Left t.ZIndex=6
		local ly=Instance.new("UIListLayout",gf) ly.SortOrder=Enum.SortOrder.LayoutOrder ly.Padding=UDim.new(0,4)
		local g={Frame=gf}

		function g:AddToggle(name,tcfg)
			tcfg=tcfg or {}
			local stt=tcfg.Default or false
			local cbk=tcfg.Callback or function() end
			local f=Instance.new("Frame",gf)
			f.Size=UDim2.new(1,0,0,26) f.BackgroundColor3=C.Ter f.BackgroundTransparency=.5
			f.BorderSizePixel=0 f.ZIndex=6
			Instance.new("UICorner",f).CornerRadius=UDim.new(0,5)
			local lb=Instance.new("TextLabel",f)
			lb.Size=UDim2.new(1,-55,1,0) lb.Position=UDim2.new(0,8,0,0)
			lb.BackgroundTransparency=1 lb.Text=name lb.TextColor3=C.Tx
			lb.Font=Enum.Font.GothamMedium lb.TextSize=12
			lb.TextXAlignment=Enum.TextXAlignment.Left lb.ZIndex=7
			local b=Instance.new("TextButton",f)
			b.Size=UDim2.new(0,40,0,18) b.Position=UDim2.new(1,-48,.5,-9)
			b.BackgroundColor3=stt and C.Tg or C.TgO b.BackgroundTransparency=.2
			b.Text="" b.BorderSizePixel=0 b.ZIndex=7
			Instance.new("UICorner",b).CornerRadius=UDim.new(1,0)
			local i2=Instance.new("Frame",b)
			i2.Size=UDim2.new(0,14,0,14)
			i2.Position=stt and UDim2.new(1,-16,.5,-7) or UDim2.new(0,2,.5,-7)
			i2.BackgroundColor3=Color3.new(1,1,1) i2.BorderSizePixel=0 i2.ZIndex=8
			Instance.new("UICorner",i2).CornerRadius=UDim.new(1,0)
			local function setVisual(v)
				T:Create(b,TweenInfo.new(.15,Enum.EasingStyle.Quad),{BackgroundColor3=v and C.Tg or C.TgO}):Play()
				T:Create(i2,TweenInfo.new(.15,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
					{Position=v and UDim2.new(1,-16,.5,-7) or UDim2.new(0,2,.5,-7)}):Play()
			end
			b.MouseButton1Click:Connect(function()
				stt=not stt
				setVisual(stt)
				pcall(cbk,stt)
			end)
			return {
				SetValue=function(_,v)
					stt=v
					setVisual(stt)
					pcall(cbk,stt)
				end,
				Value=stt
			}
		end

		function g:AddButton(bcfg)
			bcfg=bcfg or {}
			local b=Instance.new("TextButton",gf)
			b.Size=UDim2.new(1,0,0,28) b.BackgroundColor3=C.Ter b.BackgroundTransparency=.5
			b.Text=bcfg.Text or "Button" b.TextColor3=C.Tx
			b.Font=Enum.Font.GothamMedium b.TextSize=12 b.BorderSizePixel=0 b.ZIndex=6
			Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
			b.MouseEnter:Connect(function()
				T:Create(b,TweenInfo.new(.15),{BackgroundColor3=C.Acc,BackgroundTransparency=.2}):Play()
			end)
			b.MouseLeave:Connect(function()
				T:Create(b,TweenInfo.new(.15),{BackgroundColor3=C.Ter,BackgroundTransparency=.5}):Play()
			end)
			b.MouseButton1Click:Connect(function()
				local push=T:Create(b,TweenInfo.new(.08),{Size=UDim2.new(1,-6,0,26)})
				push:Play()
				push.Completed:Once(function()
					T:Create(b,TweenInfo.new(.08),{Size=UDim2.new(1,0,0,28)}):Play()
				end)
				pcall(bcfg.Func or function() end)
			end)
		end

		function g:AddSlider(name,scfg)
			scfg=scfg or {}
			local mn,mx=scfg.Min or 0,scfg.Max or 100
			local vl=scfg.Default or mn
			local cbk=scfg.Callback or function() end
			local f=Instance.new("Frame",gf)
			f.Size=UDim2.new(1,0,0,38) f.BackgroundColor3=C.Ter f.BackgroundTransparency=.5
			f.BorderSizePixel=0 f.ZIndex=6
			Instance.new("UICorner",f).CornerRadius=UDim.new(0,5)
			local l=Instance.new("TextLabel",f)
			l.Size=UDim2.new(1,-60,0,16) l.Position=UDim2.new(0,8,0,2)
			l.BackgroundTransparency=1 l.Text=name l.TextColor3=C.Tx
			l.Font=Enum.Font.GothamMedium l.TextSize=11
			l.TextXAlignment=Enum.TextXAlignment.Left l.ZIndex=7
			local vL=Instance.new("TextLabel",f)
			vL.Size=UDim2.new(0,50,0,16) vL.Position=UDim2.new(1,-58,0,2)
			vL.BackgroundTransparency=1 vL.Text=tostring(vl) vL.TextColor3=C.Acc
			vL.Font=Enum.Font.GothamBold vL.TextSize=11
			vL.TextXAlignment=Enum.TextXAlignment.Right vL.ZIndex=7
			local br=Instance.new("Frame",f)
			br.Size=UDim2.new(1,-16,0,6) br.Position=UDim2.new(0,8,0,26)
			br.BackgroundColor3=C.TgO br.BackgroundTransparency=.3 br.BorderSizePixel=0 br.ZIndex=7
			Instance.new("UICorner",br).CornerRadius=UDim.new(1,0)
			local fl2=Instance.new("Frame",br)
			fl2.Size=UDim2.new(math.clamp((vl-mn)/math.max(mx-mn,1),0,1),0,1,0)
			fl2.BackgroundColor3=C.Acc fl2.BorderSizePixel=0 fl2.ZIndex=8
			Instance.new("UICorner",fl2).CornerRadius=UDim.new(1,0)
			local fg=Instance.new("UIGradient",fl2) fg.Color=ColorSequence.new(C.GS,C.GE) fg.Rotation=45
			local b=Instance.new("TextButton",br)
			b.Size=UDim2.new(1,0,1,0) b.BackgroundTransparency=1 b.Text="" b.ZIndex=9
			local dr=false
			local function upd(x)
				local rl=math.clamp((x-br.AbsolutePosition.X)/math.max(br.AbsoluteSize.X,1),0,1)
				vl=math.floor((mn+rl*(mx-mn))*10)/10
				vL.Text=tostring(vl)
				fl2.Size=UDim2.new(rl,0,1,0)
				pcall(cbk,vl)
			end
			b.MouseButton1Down:Connect(function() dr=true upd(UIS:GetMouseLocation().X) end)
			UIS.InputChanged:Connect(function(i)
				if dr and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
					upd(i.Position.X)
				end
			end)
			UIS.InputEnded:Connect(function(i)
				if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then dr=false end
			end)
			return {
				SetValue=function(_,v)
					vl=v
					local rl=(vl-mn)/math.max(mx-mn,1)
					vL.Text=tostring(vl)
					T:Create(fl2,TweenInfo.new(.15),{Size=UDim2.new(rl,0,1,0)}):Play()
					pcall(cbk,vl)
				end,
				Value=vl
			}
		end

		function g:AddLabel(text)
			local l=Instance.new("TextLabel",gf)
			l.Size=UDim2.new(1,0,0,18) l.BackgroundTransparency=1
			l.Text=text l.TextColor3=C.Sub l.Font=Enum.Font.Gotham l.TextSize=11
			l.TextXAlignment=Enum.TextXAlignment.Left l.ZIndex=6
			return {SetText=function(_,t) l.Text=t end}
		end

		function g:AddDropdown(name,dcfg)
			dcfg=dcfg or {}
			local vs=dcfg.Values or {}
			local df=dcfg.Default or (vs[1] or "")
			local cbk=dcfg.Callback or function() end
			local cr=df
			local op=false
			local b=Instance.new("TextButton",gf)
			b.Size=UDim2.new(1,0,0,28) b.BackgroundColor3=C.Ter b.BackgroundTransparency=.5
			b.Text=name..": "..tostring(cr) b.TextColor3=C.Tx
			b.Font=Enum.Font.GothamMedium b.TextSize=12 b.BorderSizePixel=0 b.ZIndex=6
			Instance.new("UICorner",b).CornerRadius=UDim.new(0,5)
			local lF=Instance.new("Frame",gf)
			lF.Size=UDim2.new(1,0,0,0) lF.BackgroundColor3=C.Sec lF.BackgroundTransparency=.3
			lF.BorderSizePixel=0 lF.Visible=false lF.ZIndex=7 lF.AutomaticSize=Enum.AutomaticSize.Y
			Instance.new("UICorner",lF).CornerRadius=UDim.new(0,5)
			local lL=Instance.new("UIListLayout",lF) lL.SortOrder=Enum.SortOrder.LayoutOrder lL.Padding=UDim.new(0,2)
			local lP=Instance.new("UIPadding",lF)
			lP.PaddingTop=UDim.new(0,4) lP.PaddingBottom=UDim.new(0,4)
			lP.PaddingLeft=UDim.new(0,4) lP.PaddingRight=UDim.new(0,4)
			local function rebuild(list)
				for _,ch in ipairs(lF:GetChildren()) do
					if ch:IsA("TextButton") then ch:Destroy() end
				end
				for _,v in ipairs(list or vs) do
					local o=Instance.new("TextButton",lF)
					o.Size=UDim2.new(1,0,0,24) o.BackgroundColor3=C.Ter o.BackgroundTransparency=.7
					o.Text=tostring(v) o.TextColor3=C.Tx o.Font=Enum.Font.Gotham o.TextSize=12
					o.BorderSizePixel=0 o.ZIndex=8
					Instance.new("UICorner",o).CornerRadius=UDim.new(0,4)
					o.MouseEnter:Connect(function()
						T:Create(o,TweenInfo.new(.1),{BackgroundTransparency=.3}):Play()
					end)
					o.MouseLeave:Connect(function()
						T:Create(o,TweenInfo.new(.1),{BackgroundTransparency=.7}):Play()
					end)
					o.MouseButton1Click:Connect(function()
						cr=v
						b.Text=name..": "..tostring(cr)
						lF.Visible=false
						op=false
						pcall(cbk,cr)
					end)
				end
			end
			rebuild(vs)
			b.MouseButton1Click:Connect(function()
				op=not op
				lF.Visible=op
			end)
			return {
				SetValue=function(_,v) cr=v b.Text=name..": "..tostring(cr) pcall(cbk,cr) end,
				SetValues=function(_,list) vs=list or {} rebuild(vs) end,
				Value=cr
			}
		end

		function g:AddSection(text)
			local s=Instance.new("TextLabel",gf)
			s.Size=UDim2.new(1,0,0,22) s.BackgroundTransparency=1
			s.Text="> "..text s.TextColor3=C.Acc s.Font=Enum.Font.GothamBold s.TextSize=11
			s.TextXAlignment=Enum.TextXAlignment.Left s.ZIndex=6
		end

		function g:AddDivider()
			local d=Instance.new("Frame",gf)
			d.Size=UDim2.new(1,0,0,1) d.BackgroundColor3=C.Brd
			d.BackgroundTransparency=.6 d.BorderSizePixel=0 d.ZIndex=6
		end

		return g
	end

	function win:AddTab(name)
		local b=Instance.new("TextButton",ts)
		b.Size=UDim2.new(1,0,0,32) b.BackgroundColor3=C.Ter b.BackgroundTransparency=.4
		b.Text="  "..name b.TextColor3=C.Sub b.Font=Enum.Font.GothamMedium b.TextSize=13
		b.TextXAlignment=Enum.TextXAlignment.Left b.BorderSizePixel=0 b.ZIndex=4
		Instance.new("UICorner",b).CornerRadius=UDim.new(0,6)
		local ct=Instance.new("Frame",cc)
		ct.Size=UDim2.new(1,0,1,0) ct.BackgroundTransparency=1 ct.Visible=false ct.ZIndex=3
		local sc=Instance.new("ScrollingFrame",ct)
		sc.Size=UDim2.new(1,0,1,0) sc.BackgroundTransparency=1 sc.BorderSizePixel=0
		sc.ScrollBarThickness=3 sc.ScrollBarImageColor3=C.Acc
		sc.CanvasSize=UDim2.new() sc.AutomaticCanvasSize=Enum.AutomaticSize.Y sc.ZIndex=4
		local ly=Instance.new("UIListLayout",sc) ly.SortOrder=Enum.SortOrder.LayoutOrder ly.Padding=UDim.new(0,8)
		local pd=Instance.new("UIPadding",sc)
		pd.PaddingTop=UDim.new(0,8) pd.PaddingLeft=UDim.new(0,8)
		pd.PaddingRight=UDim.new(0,8) pd.PaddingBottom=UDim.new(0,8)
		local o={Button=b,Content=ct,Scroll=sc}
		local function sel()
			if cur then
				cur.Content.Visible=false
				T:Create(cur.Button,TweenInfo.new(.15),{BackgroundColor3=C.Ter}):Play()
				cur.Button.TextColor3=C.Sub
			end
			ct.Visible=true
			T:Create(b,TweenInfo.new(.15),{BackgroundColor3=C.Acc}):Play()
			b.TextColor3=Color3.fromRGB(20,40,35)
			cur=o
		end
		b.MouseButton1Click:Connect(sel)
		if not cur then sel() end
		function o:AddLeftGroupbox(t) return mkG(sc,t) end
		function o:AddRightGroupbox(t) return mkG(sc,t) end
		return o
	end

	-- ★ オープンアニメーション (フェード+拡大) ★
	m.Size=UDim2.new(0,500,0,360)
	m.Position=UDim2.new(.5,-250,.5,-180)
	T:Create(m,TweenInfo.new(.45,Enum.EasingStyle.Back,Enum.EasingDirection.Out),
		{Size=UDim2.new(0,550,0,400),Position=UDim2.new(.5,-275,.5,-200)}):Play()
	T:Create(bg,TweenInfo.new(.35),{BackgroundTransparency=0}):Play()
	T:Create(ov,TweenInfo.new(.35),{BackgroundTransparency=.4}):Play()
	T:Create(ms,TweenInfo.new(.35),{Transparency=.2}):Play()
	T:Create(tb,TweenInfo.new(.35),{BackgroundTransparency=.3}):Play()

	-- メニュー開閉キーバインド (RightShift)
	UIS.InputBegan:Connect(function(input,processed)
		if processed then return end
		if input.KeyCode==Enum.KeyCode.RightShift then
			if m.Visible then doClose() else doOpen() end
		end
	end)

	return win
end

-- ==============================
-- ★ 自動チャット送信 (2連投防止デバウンス付き) ★
-- ==============================
local ChatDebounce={lastSend=0, sending=false, cooldown=3, lastMessage=nil}

local function Say(msg)
	if ChatDebounce.sending then return end
	if ChatDebounce.lastMessage==msg and (tick()-ChatDebounce.lastSend)<ChatDebounce.cooldown then return end
	ChatDebounce.sending=true

	local ok=false
	pcall(function()
		if TCS.ChatVersion==Enum.ChatVersion.TextChatService then
			local c=TCS:FindFirstChild("TextChannels")
			if c and c:FindFirstChild("RBXGeneral")then
				c.RBXGeneral:SendAsync(msg);ok=true;return
			end
		end
	end)
	if not ok then
		pcall(function()
			local e=RS:FindFirstChild("DefaultChatSystemChatEvents")
			if e and e:FindFirstChild("SayMessageRequest")then
				e.SayMessageRequest:FireServer(msg,"All")
				ok=true
			end
		end)
	end
	if ok then
		ChatDebounce.lastSend=tick()
		ChatDebounce.lastMessage=msg
	end
	ChatDebounce.sending=false
end

-- ==============================
-- ゲーム全UIをオレンジ→緑グラデに変更
-- ==============================
local GameUI={enabled=false, originals={}, addedGradients={}, DescConn=nil}
local ORANGE=Color3.fromRGB(255,140,0)
local GREEN=Color3.fromRGB(20,200,92)

local function IsOrange(c)
	if not c then return false end
	local r,g,b=c.R,c.G,c.B
	return r>0.55 and g>=0.15 and g<0.85 and b<0.5
end

local function OrangeToGreenGradient(c)
	local lum=c.R*0.299+c.G*0.587+c.B*0.114
	local t=math.clamp(lum,0,1)
	return ORANGE:Lerp(GREEN,t)
end

local function ApplyUIGradient(obj)
	if obj:FindFirstChild("GreenGradient") then return end
	local grad=Instance.new("UIGradient")
	grad.Name="GreenGradient"
	grad.Color=ColorSequence.new({
		ColorSequenceKeypoint.new(0.0,ORANGE),
		ColorSequenceKeypoint.new(0.5,Color3.fromRGB(180,200,60)),
		ColorSequenceKeypoint.new(1.0,GREEN),
	})
	grad.Rotation=90
	grad.Parent=obj
	table.insert(GameUI.addedGradients,grad)
end

local function ProcessGuiObject(obj)
	pcall(function()
		if obj:IsA("GuiObject") then
			if IsOrange(obj.BackgroundColor3) then
				if GameUI.originals[obj]==nil then GameUI.originals[obj]={bg=obj.BackgroundColor3} end
				obj.BackgroundColor3=OrangeToGreenGradient(obj.BackgroundColor3)
				ApplyUIGradient(obj)
			end
		end
		if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
			if IsOrange(obj.TextColor3) then
				if GameUI.originals[obj]==nil then GameUI.originals[obj]={} end
				GameUI.originals[obj].text=obj.TextColor3
				obj.TextColor3=OrangeToGreenGradient(obj.TextColor3)
			end
			if obj.TextStrokeColor3 and IsOrange(obj.TextStrokeColor3) then
				if GameUI.originals[obj]==nil then GameUI.originals[obj]={} end
				GameUI.originals[obj].stroke=obj.TextStrokeColor3
				obj.TextStrokeColor3=OrangeToGreenGradient(obj.TextStrokeColor3)
			end
		end
		if obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
			if IsOrange(obj.ImageColor3) then
				if GameUI.originals[obj]==nil then GameUI.originals[obj]={} end
				GameUI.originals[obj].image=obj.ImageColor3
				obj.ImageColor3=OrangeToGreenGradient(obj.ImageColor3)
			end
		end
		if obj:IsA("GuiObject") and obj.BorderSizePixel>0 then
			if IsOrange(obj.BorderColor3) then
				if GameUI.originals[obj]==nil then GameUI.originals[obj]={} end
				GameUI.originals[obj].border=obj.BorderColor3
				obj.BorderColor3=OrangeToGreenGradient(obj.BorderColor3)
			end
		end
	end)
end

local function GameUI_Scan()
	local pg=LP:FindFirstChild("PlayerGui")
	if not pg then return end
	for _,obj in ipairs(pg:GetDescendants()) do ProcessGuiObject(obj) end
end

local function GameUI_Start()
	if GameUI.enabled then return end
	GameUI.enabled=true
	GameUI_Scan()
	local pg=LP:FindFirstChild("PlayerGui")
	if pg then
		if GameUI.DescConn then GameUI.DescConn:Disconnect() end
		GameUI.DescConn=pg.DescendantAdded:Connect(function(obj)
			if not GameUI.enabled then return end
			task.wait(0.05)
			ProcessGuiObject(obj)
		end)
	end
end

local function GameUI_Stop()
	GameUI.enabled=false
	if GameUI.DescConn then GameUI.DescConn:Disconnect(); GameUI.DescConn=nil end
	for _,g in ipairs(GameUI.addedGradients) do pcall(function() g:Destroy() end) end
	GameUI.addedGradients={}
	for obj,data in pairs(GameUI.originals) do
		pcall(function()
			if obj and obj.Parent then
				if data.bg then obj.BackgroundColor3=data.bg end
				if data.text then obj.TextColor3=data.text end
				if data.stroke then obj.TextStrokeColor3=data.stroke end
				if data.image then obj.ImageColor3=data.image end
				if data.border then obj.BorderColor3=data.border end
			end
		end)
	end
	GameUI.originals={}
end

-- ==============================
-- 自動チャット (Sky連動, 2連投防止デバウンス適用済みSayを使用)
-- ==============================
local Chat={enabled=false,conn=nil,sunDone=false,moonDone=false}

local function Chat_Check()
	local ct=LT.ClockTime
	local sunPeak=math.abs(ct-12)<0.2
	local moonPeak=(ct<0.2) or (ct>23.8)
	if sunPeak and not Chat.sunDone then Chat.sunDone=true; Say("もう朝か…学校ダルいな")
	elseif not sunPeak and ct>13 then Chat.sunDone=false end
	if moonPeak and not Chat.moonDone then Chat.moonDone=true; Say("眠…")
	elseif not moonPeak and ct>1 then Chat.moonDone=false end
end

local function Chat_Start()
	if Chat.conn then return end
	Chat.enabled=true
	local ct=LT.ClockTime
	Chat.sunDone=math.abs(ct-12)<0.2
	Chat.moonDone=(ct<0.2) or (ct>23.8)
	Chat.conn=RUN.Heartbeat:Connect(function()
		if not Chat.enabled then return end
		Chat_Check()
	end)
end

local function Chat_Stop()
	Chat.enabled=false
	if Chat.conn then Chat.conn:Disconnect(); Chat.conn=nil end
end

-- ==============================
-- Sky Cycler
-- ==============================
local S={running=false,conn=nil,startT=0,cycleTime=120,speed=1,orig={},obj={}}
local function SaveO() S.orig={ClockTime=LT.ClockTime,Brightness=LT.Brightness,Ambient=LT.Ambient,
	OutdoorAmbient=LT.OutdoorAmbient,FogColor=LT.FogColor,FogStart=LT.FogStart,FogEnd=LT.FogEnd,GlobalShadows=LT.GlobalShadows} end
local function RestO() if not S.orig.ClockTime then return end
	for k,v in pairs(S.orig) do pcall(function() LT[k]=v end) end end
local function GSky()
	local s=LT:FindFirstChild("CycledSky")
	if not s then s=Instance.new("Sky");s.Name="CycledSky"
		s.SkyboxBk="rbxassetid://159273536";s.SkyboxDn="rbxassetid://159273537"
		s.SkyboxFt="rbxassetid://159273538";s.SkyboxLf="rbxassetid://159273539"
		s.SkyboxRt="rbxassetid://159273540";s.SkyboxUp="rbxassetid://159273541"
		s.SunAngularSize=21;s.MoonAngularSize=12;s.StarCount=3000
		s.Parent=LT;table.insert(S.obj,s) end;return s end
local function GAtm()
	local a=LT:FindFirstChild("CycledAtmosphere")
	if not a then a=Instance.new("Atmosphere");a.Name="CycledAtmosphere";a.Density=.3
		a.Parent=LT;table.insert(S.obj,a) end;return a end
local function GCC()
	local c=LT:FindFirstChild("CycledCC")
	if not c then c=Instance.new("ColorCorrectionEffect");c.Name="CycledCC"
		c.Parent=LT;table.insert(S.obj,c) end;return c end
local function GSR()
	local s=LT:FindFirstChild("CycledSunRays")
	if not s then s=Instance.new("SunRaysEffect");s.Name="CycledSunRays"
		s.Intensity=.1;s.Spread=1;s.Parent=LT;table.insert(S.obj,s) end;return s end
local function ApplySun()
	local ct=LT.ClockTime
	local sh=math.sin((ct-6)/12*math.pi)
	local dF=math.clamp((sh+.3)/1.3,0,1)
	local sF=math.clamp(1-math.abs(sh)*3,0,1)
	local dA,dO,dFg=Color3.fromRGB(140,160,180),Color3.fromRGB(150,170,190),Color3.fromRGB(170,190,210)
	local sA,sO,sFg=Color3.fromRGB(180,110,70),Color3.fromRGB(240,140,80),Color3.fromRGB(240,170,110)
	local nA,nO,nFg=Color3.fromRGB(60,60,100),Color3.fromRGB(70,70,120),Color3.fromRGB(50,50,90)
	local a,o,f
	if sh>0 then a=dA:Lerp(sA,sF*.8);o=dO:Lerp(sO,sF*.8);f=dFg:Lerp(sFg,sF*.8)
	else local t=math.clamp(-sh,0,1);a=sA:Lerp(nA,t);o=sO:Lerp(nO,t);f=sFg:Lerp(nFg,t) end
	local b=.6+dF*1.4
	LT.Ambient=a;LT.OutdoorAmbient=o;LT.FogColor=f;LT.Brightness=b
	LT.FogStart=30+dF*70;LT.FogEnd=300+dF*1700
	local at=GAtm();at.Color=o:Lerp(Color3.fromRGB(255,255,255),.3);at.Decay=o*.5;at.Haze=1.5-dF
	local cc=GCC();cc.TintColor=Color3.fromRGB(255,255,255):Lerp(o,.2);cc.Saturation=sF*.2-(1-dF)*.1
	local sr=GSR();sr.Intensity=sF*.15+dF*.05
end
local function ElapsedToClock(elapsed)
	local t=(elapsed/S.cycleTime)%1
	return (6+t*24)%24
end
local function SkyStart()
	if S.conn then return end
	S.running=true;SaveO();GSky();GAtm();GCC();GSR()
	S.startT=tick()
	S.conn=RUN.RenderStepped:Connect(function()
		if not S.running then return end
		local elapsed=(tick()-S.startT)*S.speed
		LT.ClockTime=ElapsedToClock(elapsed)
		ApplySun()
	end)
	Chat_Start()
end
local function SkyStop()
	S.running=false
	if S.conn then S.conn:Disconnect();S.conn=nil end
	RestO()
	for _,o in ipairs(S.obj) do pcall(function() o:Destroy() end) end
	S.obj={}
	Chat_Stop()
end

-- ==============================
-- ★ リアルグラフィック強化 (スムーズな影 / Bloom / 被写界深度 / 雲) ★
-- ==============================
local GFX={
	enabled=false, bloom=nil, dof=nil, clouds=nil,
	origTech=nil, origDiffuse=nil, origSpecular=nil, origShadows=nil,
	technology="Future", diffuseScale=1, specularScale=1,
	bloomIntensity=0.4, bloomSize=24, bloomThreshold=2,
	dofFarIntensity=0.3, dofFocusDistance=50, dofInFocusRadius=30,
	cloudCover=0.5, cloudDensity=0.5,
}

local function GFX_ApplyTechnology(mode)
	pcall(function()
		if mode=="Future" then LT.Technology=Enum.Technology.Future
		elseif mode=="ShadowMap" then LT.Technology=Enum.Technology.ShadowMap
		elseif mode=="Voxel" then LT.Technology=Enum.Technology.Voxel end
	end)
end

local function GFX_RefreshSettings()
	pcall(function() LT.EnvironmentDiffuseScale=GFX.diffuseScale end)
	pcall(function() LT.EnvironmentSpecularScale=GFX.specularScale end)
	if GFX.bloom then
		GFX.bloom.Intensity=GFX.bloomIntensity
		GFX.bloom.Size=GFX.bloomSize
		GFX.bloom.Threshold=GFX.bloomThreshold
	end
	if GFX.dof then
		GFX.dof.FarIntensity=GFX.dofFarIntensity
		GFX.dof.FocusDistance=GFX.dofFocusDistance
		GFX.dof.InFocusRadius=GFX.dofInFocusRadius
	end
	if GFX.clouds then
		GFX.clouds.Cover=GFX.cloudCover
		GFX.clouds.Density=GFX.cloudDensity
	end
end

local function GFX_Start()
	if GFX.enabled then return end
	GFX.enabled=true
	GFX.origTech=LT.Technology
	pcall(function() GFX.origDiffuse=LT.EnvironmentDiffuseScale end)
	pcall(function() GFX.origSpecular=LT.EnvironmentSpecularScale end)
	GFX.origShadows=LT.GlobalShadows
	LT.GlobalShadows=true
	GFX_ApplyTechnology(GFX.technology)
	if not GFX.bloom then
		local b=Instance.new("BloomEffect")
		b.Name="GFXBloom" b.Parent=LT
		GFX.bloom=b
	end
	if not GFX.dof then
		local d=Instance.new("DepthOfFieldEffect")
		d.Name="GFXDepthOfField" d.NearIntensity=0 d.Parent=LT
		GFX.dof=d
	end
	if not GFX.clouds then
		local c=WS.Terrain:FindFirstChildOfClass("Clouds")
		if not c then c=Instance.new("Clouds"); c.Parent=WS.Terrain end
		GFX.clouds=c
	end
	GFX.clouds.Enabled=true
	GFX_RefreshSettings()
end

local function GFX_Stop()
	GFX.enabled=false
	pcall(function() if GFX.origTech then LT.Technology=GFX.origTech end end)
	pcall(function() if GFX.origDiffuse then LT.EnvironmentDiffuseScale=GFX.origDiffuse end end)
	pcall(function() if GFX.origSpecular then LT.EnvironmentSpecularScale=GFX.origSpecular end end)
	pcall(function() if GFX.origShadows~=nil then LT.GlobalShadows=GFX.origShadows end end)
	if GFX.bloom then pcall(function() GFX.bloom:Destroy() end); GFX.bloom=nil end
	if GFX.dof then pcall(function() GFX.dof:Destroy() end); GFX.dof=nil end
	if GFX.clouds then pcall(function() GFX.clouds.Enabled=false end) end
end

-- ==============================
-- ★ プレイヤー操作 (自分のキャラクターのみに影響) ★
-- ==============================
local function GetChar() return LP.Character end
local function GetHRP() local c=GetChar(); return c and c:FindFirstChild("HumanoidRootPart") end
local function GetHum() local c=GetChar(); return c and c:FindFirstChildOfClass("Humanoid") end

local PM={
	walkSpeed=16, jumpPower=50,
	infJump=false, infJumpConn=nil,
	fly=false, flyConn=nil, flySpeed=50, flyBV=nil, flyBG=nil,
	noclip=false, noclipConn=nil,
}

local function PM_ApplyWalkSpeed(v)
	PM.walkSpeed=v
	local h=GetHum()
	if h then pcall(function() h.WalkSpeed=v end) end
end

local function PM_ApplyJumpPower(v)
	PM.jumpPower=v
	local h=GetHum()
	if h then pcall(function() h.JumpPower=v end) end
end

local function PM_InfJump_Start()
	if PM.infJumpConn then return end
	PM.infJump=true
	PM.infJumpConn=UIS.JumpRequest:Connect(function()
		local h=GetHum()
		if h then pcall(function() h:ChangeState(Enum.HumanoidStateType.Jumping) end) end
	end)
end

local function PM_InfJump_Stop()
	PM.infJump=false
	if PM.infJumpConn then PM.infJumpConn:Disconnect(); PM.infJumpConn=nil end
end

local function PM_Fly_Start()
	if PM.flyConn then return end
	local hrp=GetHRP()
	if not hrp then return end
	PM.fly=true

	local bv=Instance.new("BodyVelocity")
	bv.Name="PMFlyBV" bv.MaxForce=Vector3.new(1e9,1e9,1e9) bv.Velocity=Vector3.zero bv.Parent=hrp
	local bg=Instance.new("BodyGyro")
	bg.Name="PMFlyBG" bg.MaxTorque=Vector3.new(1e9,1e9,1e9) bg.P=5000 bg.CFrame=hrp.CFrame bg.Parent=hrp
	PM.flyBV=bv
	PM.flyBG=bg

	PM.flyConn=RUN.RenderStepped:Connect(function()
		if not PM.fly then return end
		local cam=WS.CurrentCamera
		local hrp2=GetHRP()
		if not cam or not hrp2 or not PM.flyBV then return end
		local move=Vector3.zero
		if UIS:IsKeyDown(Enum.KeyCode.W) then move=move+cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.S) then move=move-cam.CFrame.LookVector end
		if UIS:IsKeyDown(Enum.KeyCode.A) then move=move-cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.D) then move=move+cam.CFrame.RightVector end
		if UIS:IsKeyDown(Enum.KeyCode.Space) then move=move+Vector3.new(0,1,0) end
		if UIS:IsKeyDown(Enum.KeyCode.LeftControl) then move=move-Vector3.new(0,1,0) end
		if move.Magnitude>0 then move=move.Unit end
		pcall(function()
			PM.flyBV.Velocity=move*PM.flySpeed
			PM.flyBG.CFrame=cam.CFrame
		end)
	end)
end

local function PM_Fly_Stop()
	PM.fly=false
	if PM.flyConn then PM.flyConn:Disconnect(); PM.flyConn=nil end
	if PM.flyBV then pcall(function() PM.flyBV:Destroy() end); PM.flyBV=nil end
	if PM.flyBG then pcall(function() PM.flyBG:Destroy() end); PM.flyBG=nil end
end

local function PM_Noclip_Start()
	if PM.noclipConn then return end
	PM.noclip=true
	PM.noclipConn=RUN.Stepped:Connect(function()
		if not PM.noclip then return end
		local c=LP.Character
		if not c then return end
		for _,part in ipairs(c:GetDescendants()) do
			if part:IsA("BasePart") and part.CanCollide then
				pcall(function() part.CanCollide=false end)
			end
		end
	end)
end

local function PM_Noclip_Stop()
	PM.noclip=false
	if PM.noclipConn then PM.noclipConn:Disconnect(); PM.noclipConn=nil end
	local c=LP.Character
	if c then
		for _,part in ipairs(c:GetDescendants()) do
			if part:IsA("BasePart") then pcall(function() part.CanCollide=true end) end
		end
	end
end

LP.CharacterAdded:Connect(function(char)
	task.wait(0.5)
	local h=char:FindFirstChildOfClass("Humanoid")
	if h then
		pcall(function()
			h.WalkSpeed=PM.walkSpeed
			h.JumpPower=PM.jumpPower
		end)
	end
end)

-- ==============================
-- ★ ビジュアル (ESP / フルブライト / カメラFOV) ★
-- ==============================
local ESP={enabled=false, objects={}, conn=nil, addedConn=nil, removingConn=nil}

local function ESP_CreateForPlayer(plr)
	if ESP.objects[plr] then return end
	local data={}
	local function Build(char)
		local hrp=char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local hl=Instance.new("Highlight")
		hl.Name="ESPHighlight" hl.FillColor=Color3.fromRGB(20,200,92) hl.FillTransparency=0.5
		hl.OutlineColor=Color3.fromRGB(255,255,255) hl.Parent=char
		local bb=Instance.new("BillboardGui")
		bb.Name="ESPBillboard" bb.Adornee=hrp bb.Size=UDim2.new(0,160,0,36)
		bb.StudsOffset=Vector3.new(0,3,0) bb.AlwaysOnTop=true
		local lbl=Instance.new("TextLabel",bb)
		lbl.Size=UDim2.new(1,0,1,0) lbl.BackgroundTransparency=1
		lbl.TextColor3=Color3.fromRGB(255,255,255) lbl.TextStrokeTransparency=0
		lbl.Font=Enum.Font.GothamBold lbl.TextScaled=true lbl.Text=plr.Name
		bb.Parent=hrp
		data.highlight=hl data.billboard=bb data.label=lbl data.hrp=hrp
	end
	if plr.Character then Build(plr.Character) end
	data.addedConn=plr.CharacterAdded:Connect(function(c) task.wait(0.2); Build(c) end)
	ESP.objects[plr]=data
end

local function ESP_RemoveForPlayer(plr)
	local data=ESP.objects[plr]
	if not data then return end
	if data.addedConn then data.addedConn:Disconnect() end
	if data.highlight then pcall(function() data.highlight:Destroy() end) end
	if data.billboard then pcall(function() data.billboard:Destroy() end) end
	ESP.objects[plr]=nil
end

local function ESP_UpdateDistances()
	local myHrp=GetHRP()
	for plr,data in pairs(ESP.objects) do
		if data.label and data.hrp and myHrp then
			local d=(myHrp.Position-data.hrp.Position).Magnitude
			pcall(function() data.label.Text=string.format("%s [%dm]",plr.Name,math.floor(d)) end)
		end
	end
end

local function ESP_Start()
	if ESP.enabled then return end
	ESP.enabled=true
	for _,plr in ipairs(Players:GetPlayers()) do
		if plr~=LP then ESP_CreateForPlayer(plr) end
	end
	if not ESP.addedConn then
		ESP.addedConn=Players.PlayerAdded:Connect(function(plr)
			if ESP.enabled and plr~=LP then ESP_CreateForPlayer(plr) end
		end)
	end
	if not ESP.removingConn then
		ESP.removingConn=Players.PlayerRemoving:Connect(function(plr) ESP_RemoveForPlayer(plr) end)
	end
	if not ESP.conn then
		ESP.conn=RUN.Heartbeat:Connect(function()
			if ESP.enabled then ESP_UpdateDistances() end
		end)
	end
end

local function ESP_Stop()
	ESP.enabled=false
	if ESP.conn then ESP.conn:Disconnect(); ESP.conn=nil end
	for plr,_ in pairs(ESP.objects) do ESP_RemoveForPlayer(plr) end
end

local FB={enabled=false, origBrightness=nil, origAmbient=nil, origOutdoorAmbient=nil}
local function FB_Start()
	if FB.enabled then return end
	FB.enabled=true
	FB.origBrightness=LT.Brightness
	FB.origAmbient=LT.Ambient
	FB.origOutdoorAmbient=LT.OutdoorAmbient
	LT.Brightness=2
	LT.Ambient=Color3.fromRGB(150,150,150)
	LT.OutdoorAmbient=Color3.fromRGB(150,150,150)
end
local function FB_Stop()
	FB.enabled=false
	pcall(function()
		if FB.origBrightness then LT.Brightness=FB.origBrightness end
		if FB.origAmbient then LT.Ambient=FB.origAmbient end
		if FB.origOutdoorAmbient then LT.OutdoorAmbient=FB.origOutdoorAmbient end
	end)
end

local function Cam_SetFOV(v)
	pcall(function()
		local cam=WS.CurrentCamera
		if cam then cam.FieldOfView=v end
	end)
end

-- ==============================
-- ★ ユーティリティ (コピー / サーバー) ★
-- ==============================
local function Util_CopyJobId()
	local ok=pcall(function() setclipboard(game.JobId) end)
	if ok then H:Notify("Job IDをコピーしました",3) end
end

local function Util_CopyGameId()
	local ok=pcall(function() setclipboard(tostring(game.PlaceId)) end)
	if ok then H:Notify("Game IDをコピーしました",3) end
end

local function Util_CopyExecutorInfo()
	local name,ver="不明","不明"
	pcall(function() name,ver=identifyexecutor() end)
	local ok=pcall(function() setclipboard(tostring(name).." "..tostring(ver)) end)
	if ok then H:Notify("エグゼキューター情報: "..tostring(name).." "..tostring(ver),4) end
end

local function Util_Rejoin()
	pcall(function() TPS:TeleportToPlaceInstance(game.PlaceId, game.JobId, LP) end)
end

local function Util_ServerHop()
	pcall(function() TPS:Teleport(game.PlaceId, LP) end)
end

-- ==============================
-- ★ UI構築 (起動スプラッシュ完了後に実行) ★
-- ==============================
local function BuildMainUI()
	local W=H:CreateWindow({Title="NekoHub - Sky Cycler", Footer="Happy DayUI Edition"})

	local TSky=W:AddTab("Sky Cycler")
	local SGp=TSky:AddLeftGroupbox("Sky Cycler")
	SGp:AddToggle("空を回転 ON (自動チャットも連動)",{Default=false,
		Callback=function(v) if v then SkyStart() else SkyStop() end end})
	SGp:AddSlider("1周の時間 (秒)",{Min=30,Max=600,Default=120,
		Callback=function(v) S.cycleTime=v end})
	SGp:AddSlider("速度倍率",{Min=.1,Max=5,Default=1,
		Callback=function(v) S.speed=v end})
	SGp:AddButton({Text="🛑 空停止",Func=function() SkyStop() end})

	local CGp=TSky:AddLeftGroupbox("自動チャット (連動・2連投防止)")
	CGp:AddLabel("・空サイクルON → 自動でチャットON")
	CGp:AddLabel("・空サイクルOFF → 自動でチャットOFF")
	CGp:AddLabel("・太陽が真上 → 「もう朝か…学校ダルいな」")
	CGp:AddLabel("・月が真上 → 「眠…」")
	CGp:AddLabel("・同じメッセージの連続送信は3秒間ブロック")

	local TGameUI=W:AddTab("Game UI")
	local GGp=TGameUI:AddLeftGroupbox("ゲーム全UI色変更")
	GGp:AddToggle("全UIをオレンジ→緑グラデに",{Default=false,
		Callback=function(v) if v then GameUI_Start() else GameUI_Stop() end end})
	GGp:AddButton({Text="🎨 今すぐ適用",Func=function() GameUI_Scan() end})
	GGp:AddLabel("・ゲーム内の全UIをスキャン")
	GGp:AddLabel("・新規追加UIも自動処理 / OFFで元の色に戻る")

	local TGfx=W:AddTab("リアルグラフィック")
	local FGp=TGfx:AddLeftGroupbox("リアルグラフィック強化")
	FGp:AddToggle("リアルグラフィック ON/OFF",{Default=false,
		Callback=function(v) if v then GFX_Start() else GFX_Stop() end end})
	FGp:AddDropdown("影の描写方式",{Values={"Future","ShadowMap","Voxel"},Default="Future",
		Callback=function(v) GFX.technology=v; if GFX.enabled then GFX_ApplyTechnology(v) end end})
	FGp:AddLabel("・Future: 最もなめらかな影とライティング(推奨)")
	FGp:AddLabel("・ShadowMap: 標準的な影 / Voxel: 軽量だが影は粗い")
	FGp:AddSlider("環境光の拡散反射",{Min=0,Max=2,Default=1,
		Callback=function(v) GFX.diffuseScale=v; GFX_RefreshSettings() end})
	FGp:AddSlider("環境光の鏡面反射",{Min=0,Max=2,Default=1,
		Callback=function(v) GFX.specularScale=v; GFX_RefreshSettings() end})

	local FGp2=TGfx:AddLeftGroupbox("ブルーム / 被写界深度 / 雲")
	FGp2:AddSlider("ブルーム強度",{Min=0,Max=2,Default=0.4,
		Callback=function(v) GFX.bloomIntensity=v; GFX_RefreshSettings() end})
	FGp2:AddSlider("ブルームサイズ",{Min=0,Max=56,Default=24,
		Callback=function(v) GFX.bloomSize=v; GFX_RefreshSettings() end})
	FGp2:AddSlider("ブルームしきい値",{Min=0,Max=4,Default=2,
		Callback=function(v) GFX.bloomThreshold=v; GFX_RefreshSettings() end})
	FGp2:AddSlider("被写界深度:焦点距離",{Min=5,Max=300,Default=50,
		Callback=function(v) GFX.dofFocusDistance=v; GFX_RefreshSettings() end})
	FGp2:AddSlider("被写界深度:ピント範囲",{Min=1,Max=200,Default=30,
		Callback=function(v) GFX.dofInFocusRadius=v; GFX_RefreshSettings() end})
	FGp2:AddSlider("被写界深度:ぼかし強度",{Min=0,Max=1,Default=0.3,
		Callback=function(v) GFX.dofFarIntensity=v; GFX_RefreshSettings() end})
	FGp2:AddSlider("雲の量",{Min=0,Max=1,Default=0.5,
		Callback=function(v) GFX.cloudCover=v; GFX_RefreshSettings() end})
	FGp2:AddSlider("雲の密度",{Min=0,Max=1,Default=0.5,
		Callback=function(v) GFX.cloudDensity=v; GFX_RefreshSettings() end})

	local TPlayer=W:AddTab("プレイヤー")
	local PGp=TPlayer:AddLeftGroupbox("移動ステータス")
	PGp:AddSlider("WalkSpeed",{Min=16,Max=200,Default=16,
		Callback=function(v) PM_ApplyWalkSpeed(v) end})
	PGp:AddSlider("JumpPower",{Min=50,Max=300,Default=50,
		Callback=function(v) PM_ApplyJumpPower(v) end})
	PGp:AddToggle("インフィニットジャンプ",{Default=false,
		Callback=function(v) if v then PM_InfJump_Start() else PM_InfJump_Stop() end end})

	local PGp2=TPlayer:AddLeftGroupbox("Fly / Noclip")
	PGp2:AddToggle("Fly (WASD + Space/Ctrl)",{Default=false,
		Callback=function(v) if v then PM_Fly_Start() else PM_Fly_Stop() end end})
	PGp2:AddSlider("Fly速度",{Min=10,Max=300,Default=50,
		Callback=function(v) PM.flySpeed=v end})
	PGp2:AddToggle("Noclip (壁すり抜け)",{Default=false,
		Callback=function(v) if v then PM_Noclip_Start() else PM_Noclip_Stop() end end})

	local TVisual=W:AddTab("ビジュアル")
	local VGp=TVisual:AddLeftGroupbox("ESP")
	VGp:AddToggle("プレイヤーESP",{Default=false,
		Callback=function(v) if v then ESP_Start() else ESP_Stop() end end})
	VGp:AddLabel("・他プレイヤーをハイライト表示")
	VGp:AddLabel("・名前と距離をビルボード表示")

	local VGp2=TVisual:AddLeftGroupbox("ライティング / カメラ")
	VGp2:AddToggle("フルブライト",{Default=false,
		Callback=function(v) if v then FB_Start() else FB_Stop() end end})
	VGp2:AddSlider("カメラFOV",{Min=30,Max=120,Default=70,
		Callback=function(v) Cam_SetFOV(v) end})

	local TUtil=W:AddTab("ユーティリティ")
	local UGp=TUtil:AddLeftGroupbox("コピー")
	UGp:AddButton({Text="📋 Job IDをコピー",Func=function() Util_CopyJobId() end})
	UGp:AddButton({Text="📋 Game IDをコピー",Func=function() Util_CopyGameId() end})
	UGp:AddButton({Text="📋 エグゼキューター情報をコピー",Func=function() Util_CopyExecutorInfo() end})

	local UGp2=TUtil:AddLeftGroupbox("サーバー")
	UGp2:AddButton({Text="🔄 リジョイン",Func=function() Util_Rejoin() end})
	UGp2:AddButton({Text="🌐 サーバーホップ",Func=function() Util_ServerHop() end})

	local TInfo=W:AddTab("Info")
	local IGp=TInfo:AddLeftGroupbox("情報")
	IGp:AddLabel("UI: Happy DayUI (アップロードされたImoHub UIベース)")
	IGp:AddLabel("Sky Cycler / Game UI色変更 / リアルグラフィック")
	IGp:AddLabel("プレイヤー操作 / ビジュアル(ESP) / ユーティリティ")
	IGp:AddLabel("メニュー開閉: RightShift")
	IGp:AddButton({Text="通知テスト",Func=function() H:Notify("Hello from NekoHub!",2) end})

	-- ウィンドウが閉じられた(Xボタン)ときに全機能を確実に停止
	W.Gui.Destroying:Connect(function()
		Chat_Stop();SkyStop();GameUI_Stop();GFX_Stop()
		PM_InfJump_Stop();PM_Fly_Stop();PM_Noclip_Stop()
		ESP_Stop();FB_Stop()
	end)
end

-- ★ 起動シーケンス: スプラッシュ → メインUI構築 ★
ShowBootSplash(function()
	BuildMainUI()
end)
