--Local vars
local update = false
local steps
local song
local frameX = 3
local frameY = 100.5
local frameWidth = SCREEN_WIDTH * 0.56
local frameHeight = 322
local fontScale = 0.4
local distY = 15
local offsetX = 10
local offsetY = 20
local pn = GAMESTATE:GetEnabledPlayers()[1]
local greatest = 0
local steps
local meter = {}
meter[1] = 0.00

local cd -- chord density graph

--Actor Frame
local t =
	Def.ActorFrame {
	BeginCommand = function(self)
		cd = self:GetChild("ChordDensityGraph")
		cd:xy(frameX + offsetX, frameY + 140):visible(false)
		self:queuecommand("Set"):visible(false)
	end,
	OffCommand = function(self)
		self:bouncebegin(0.2):xy(-500, 0):diffusealpha(0)
	end,
	OnCommand = function(self)
		self:bouncebegin(0.2):xy(0, 0):diffusealpha(1)
	end,
	SetCommand = function(self)
		self:finishtweening()
		if getTabIndex() == 1 then
			self:queuecommand("On")
			self:visible(true)
			song = GAMESTATE:GetCurrentSong()
			steps = GAMESTATE:GetCurrentSteps(PLAYER_1)

			--Find max MSD value, store MSD values in meter[]
			-- I plan to have c++ store the highest msd value as a separate variable to aid in the filter process so this won't be needed afterwards - mina
			greatest = 0
			if song and steps then
				for i = 1, #ms.SkillSets do
					meter[i + 1] = steps:GetMSD(getCurRateValue(), i)
					if meter[i + 1] > meter[greatest + 1] then
						greatest = i
					end
				end
			end

			if song and steps then
				cd:visible(true)
				cd:queuecommand("GraphUpdate")
			else
				cd:visible(false)
			end	
			update = true
		else
			self:queuecommand("Off")
			cd:visible(false)
			update = false
		end
	end,
	CurrentRateChangedMessageCommand = function(self)
		self:queuecommand("Set")
	end,
	CurrentStepsP1ChangedMessageCommand = function(self)
		self:queuecommand("Set")
	end,
	TabChangedMessageCommand = function(self)
		self:queuecommand("Set")
	end
}

--BG sprite (cranberry) -ryan
t[#t + 1] =
	Def.Sprite {
		Texture=("_msd fg"),
	InitCommand = function(self)
		self:xy(frameX - 20, frameY - 10):zoomto(360,350):halign(0):valign(0)
	end
}

t[#t + 1] =
	Def.Sprite {
		Texture=("_msd bgmask"),
	InitCommand = function(self)
		self:xy(frameX - 20, frameY - 10):zoomto(360,350):halign(0):valign(0):diffusealpha(0.8)
	end
}


--Skillset label function
local function littlebits(i)
	local t =
		Def.ActorFrame {
		LoadFont("ZenithBold") ..
			{
				InitCommand = function(self)
					self:xy(frameX + offsetX, frameY + 120 + 22 * i + 6):halign(0):valign(0):zoom(0.65):maxwidth(160 / 0.6)
				end,
				SetCommand = function(self)
					--skillset name
					if song and steps then
						self:settext(ms.SkillSets[i] .. ":")
					else
						self:settext("")
					end
					--highlight
					if greatest == i then
						self:diffuse(Color.Red)
					else
						self:diffuse(color("#ff4242"))
					end
					--If negative BPM empty label
					if steps and steps:GetTimingData():HasWarps() then
						self:settext("")
					end
				end
			},
		LoadFont("Common Large") ..
			{
				InitCommand = function(self)
					self:xy(frameX + 225, frameY + 120 + 22 * i):halign(1):valign(0):zoom(0.5):maxwidth(110 / 0.6)
				end,
				SetCommand = function(self)
					if song and steps then
						self:settextf("%05.2f", meter[i + 1])
						self:diffuse(byMSD(meter[i + 1]))
					else
						self:settext("")
					end
					--If negative BPM empty label
					if steps and steps:GetTimingData():HasWarps() then
						self:settext("")
					end
				end
			}
	}
	return t
end

--dd'ized the title -ryan
t[#t + 1] =
	LoadFont("ZenithBold") .. {
		InitCommand = function(self)
			self:xy(frameX + 10, frameY + 21):zoom(0.6):halign(0):diffuse(Color.Red):settext(
				"MSD Breakdown"
			)
		end
	}
	
t[#t + 1] =
	LoadFont("ZenithBold") .. {
		InitCommand = function(self)
			self:xy(frameX + 10, frameY + 41):zoom(0.55):halign(0):diffuse(Color.Red):maxwidth(
				SCREEN_CENTER_X / 0.7
			)
		end,
		SetCommand = function(self)
			if song then
				self:settext(song:GetDisplayMainTitle())
			else
				self:settext("")
			end
		end
	}

-- Music Rate Display
t[#t + 1] =
	LoadFont("Common Large") ..
	{
		InitCommand = function(self)
			self:xy(frameX + offsetX, frameY + offsetY + 65):visible(true):halign(0):zoom(0.4):maxwidth(
				capWideScale(get43size(360), 360) / capWideScale(get43size(0.45), 0.45)
			)
		end,
		SetCommand = function(self)
			self:settext(getCurRateDisplayString())
		end
	}

--Difficulty
t[#t + 1] =
	LoadFont("Common Normal") .. {
		Name = "StepsAndMeter",
		InitCommand = function(self)
			self:xy(frameX + offsetX, frameY + offsetY + 50):zoom(0.5):halign(0)
		end,
		SetCommand = function(self)
			steps = GAMESTATE:GetCurrentSteps(pn)
			if steps ~= nil then
				local diff = getDifficulty(steps:GetDifficulty())
				local stype = ToEnumShortString(steps:GetStepsType()):gsub("%_", " ")
				local meter = steps:GetMeter()
				if update then
					self:settext(stype .. " " .. diff .. " " .. meter)
					self:diffuse(getDifficultyColor(GetCustomDifficulty(steps:GetStepsType(), steps:GetDifficulty())))
				end
			end
		end
	}

--NPS
t[#t + 1] =
	LoadFont("Common Normal") .. {
		Name = "NPS",
		InitCommand = function(self)
			self:xy(frameX + offsetX, frameY + 60):zoom(0.4):halign(0)
		end,
		SetCommand = function(self)
			steps = GAMESTATE:GetCurrentSteps(pn)
			--local song = GAMESTATE:GetCurrentSong()
			local notecount = 0
			local length = 1
			if steps ~= nil and song ~= nil and update then
				length = song:GetStepsSeconds()
				notecount = steps:GetRadarValues(pn):GetValue("RadarCategory_Notes")
				self:settext(string.format("%0.2f Average NPS", notecount / length * getCurRateValue()))
				self:diffuse(Saturation(getDifficultyColor(GetCustomDifficulty(steps:GetStepsType(), steps:GetDifficulty())), 0.3))
			else
				self:settext("0.00 Average NPS")
			end
		end
	}

--Negative BPMs label
t[#t + 1] =
	LoadFont("ZenithBold") .. {
		InitCommand = function(self)
			self:xy(frameX + 13, frameY + 155):zoom(0.8):halign(0):diffuse(getMainColor("negative")):settext("Negative Bpms")
		end,
		SetCommand = function(self)
			if steps and steps:GetTimingData():HasWarps() then
				self:settext("Negative BPMs, score will be 0.00")
			else
				self:settext("")
			end
		end
	}

--Skillset labels
for i = 1, #ms.SkillSets do
	t[#t + 1] = littlebits(i)
end

t[#t + 1] = LoadActor("../_chorddensitygraph.lua")

return t
