local fTileSize = 32;
local iTilesX = math.ceil( SCREEN_WIDTH/fTileSize );
local iTilesY = math.ceil( SCREEN_HEIGHT/fTileSize );
--[[ local function Actor:PositionTile(self,iX,iY)
	self:x( scale(iX,1,iTilesX,-SCREEN_CENTER_X,SCREEN_CENTER_X) );
	self:y( scale(iY,1,iTilesY,-SCREEN_CENTER_Y,SCREEN_CENTER_Y) );
end --]]
local t = Def.ActorFrame {
	InitCommand=function(self)
		self:x(SCREEN_CENTER_X):y(SCREEN_CENTER_Y)
	end;
};
--[[ for indx=1,iTilesX do
	for indy=1,iTilesY do
		t[#t+1] = Def.Quad {
				x,math.floor( scale(indx,1,iTilesX,(iTilesX/2)*fTileSize*-1,(iTilesX/2)*fTileSize*1) );
				y,math.floor( scale(indy,1,iTilesY,(iTilesY/2)*fTileSize*-1,(iTilesY/2)*fTileSize*1) );
			);
			OnCommand=function(self)
				self:diffuse(Color("Black")):diffusealpha(0):zoom(fTileSize*1.25):linear(0.0325 + ( indx / 60 )):diffusealpha(1):zoom(fTileSize-2)
			end;
		};
	end
end --]]
t[#t+1] = Def.Quad {
	InitCommand=function(self)
		self:zoomto(SCREEN_WIDTH+1,SCREEN_HEIGHT)
	end;
	OnCommand=function(self)
		self:diffuse(color("0,0,0,0")):sleep(0.0325 + ( ( iTilesX/2 ) / 60 )):linear(0.15):diffusealpha(1)
	end;
};
--[[ return Def.ActorFrame {
	Def.Quad {
		InitCommand=function(self)
			self:Center():zoomto(SCREEN_WIDTH+1,SCREEN_HEIGHT)
		end;
		OnCommand=function(self)
			self:diffuse(color("0,0,0,1")):linear(0.15):diffusealpha(0)
		end;
	};
}; --]]

return t