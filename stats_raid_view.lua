--big thanks to Michael for letting me copy a good chunk of the below. 
raidStatsWnd = api.Interface:CreateEmptyWindow("raidStatsWnd", "UIParent")
raidStatsWnd:SetExtent(280, 280)
raidStatsWnd:AddAnchor("RIGHT", "UIParent", 0, -100)
raidStatsWnd.child = {}

local selectedPage = 1
local offsetX = 30
local offsetY = 70
local labelHeight = 20
for k = 1, 10 do
		-- Overall child widget and ranking # text
		local id = tostring(k) .. ""
		raidStatsWnd.child[k] = api.Interface:CreateWidget("label", id, raidStatsWnd)
		local child = raidStatsWnd.child[k]
		child:AddAnchor("TOPLEFT", 12, offsetY)
		child:SetExtent(255, labelHeight)
		child:SetText(id)
		child.style:SetColor(1, 1, 1, 1)
		child.style:SetAlign(ALIGN.LEFT)

		-- Status bar and background
		local statusBar = api.Interface:CreateStatusBar("bgStatusBar", child, "item_evolving_material")
		child.bgStatusBar = statusBar
		child.bgStatusBar:AddAnchor("TOPLEFT", child, 25, 1)
		child.bgStatusBar:AddAnchor("BOTTOMRIGHT", child, -1, -1)
		child.bgStatusBar:SetMinMaxValues(0, 100)
		child.bgStatusBar:SetBarColor({
			ConvertColor(222),
			ConvertColor(177),
			ConvertColor(102),
			1
		})
		child.bgStatusBar.bg:SetColor(ConvertColor(76), ConvertColor(45), ConvertColor(8), 0.4)
  
		-- Display text for name and # of selected stat 
		local statLabel = child.bgStatusBar:CreateChildWidget("label", "statLabel", 0, true)
		statLabel.style:SetShadow(true)
		statLabel.style:SetAlign(ALIGN.LEFT)
		ApplyTextColor(statLabel, FONT_COLOR.WHITE)
		statLabel:AddAnchor("LEFT", 5, 0)
		local statAmtLabel = child.bgStatusBar:CreateChildWidget("label", "statAmtLabel", 0, true)
		statAmtLabel.style:SetShadow(true)
		statAmtLabel.style:SetAlign(ALIGN.RIGHT)
		ApplyTextColor(statAmtLabel, FONT_COLOR.WHITE)
		statAmtLabel:AddAnchor("RIGHT", -5, 0)
  
		offsetY = offsetY + labelHeight
end

--- Add dragable bar across top
local moveWnd = raidStatsWnd:CreateChildWidget("label", "moveWnd", 0, true)
moveWnd:AddAnchor("TOPLEFT", raidStatsWnd, 12, 0)
moveWnd:AddAnchor("TOPRIGHT", raidStatsWnd, 0, 0)
moveWnd:SetHeight(80)
moveWnd.style:SetFontSize(FONT_SIZE.XLARGE)
moveWnd.style:SetAlign(ALIGN.LEFT)
moveWnd:SetText("")
ApplyTextColor(moveWnd, FONT_COLOR.WHITE)
-- Drag handlers for dragable bar
function moveWnd:OnDragStart(arg)
	if arg == nil or (arg == "LeftButton" and api.Input:IsShiftKeyDown()) then
	raidStatsWnd:StartMoving()
	api.Cursor:ClearCursor()
	api.Cursor:SetCursorImage(CURSOR_PATH.MOVE, 0, 0)
	end
end
moveWnd:SetHandler("OnDragStart", moveWnd.OnDragStart)
function moveWnd:OnDragStop()
	raidStatsWnd:StopMovingOrSizing()
	api.Cursor:ClearCursor()
end
moveWnd:SetHandler("OnDragStop", moveWnd.OnDragStop)
if moveWnd.RegisterForDrag ~= nil then
	moveWnd:RegisterForDrag("LeftButton")
end
if moveWnd.EnableDrag ~= nil then
    moveWnd:EnableDrag(true)
end


-- Add stats category selection
local filtersDisplay = {
	"Melee Attack",
	"Ranged Attack",
	"Magic Attack",
	"Healing Power",
	"Melee Health",
	"Ranged Health",
	"Magic Health"
}
local typeDisplay = {
	"Current",
	"Normalized"
}



-- Main Filter Dropdown Menu (Also used as title)
local filterButton = api.Interface:CreateComboBox(moveWnd)
filterButton:AddAnchor("TOPLEFT", moveWnd, 0, 3)
filterButton:SetExtent(150, 30)
filterButton.dropdownItem = filtersDisplay
filterButton:Select(1)
filterButton.style:SetFontSize(FONT_SIZE.XLARGE)
filterButton:SetHighlightTextColor(1, 1, 1, 1)
filterButton:SetPushedTextColor(1, 1, 1, 1)
filterButton:SetDisabledTextColor(1, 1, 1, 1)
filterButton:SetTextColor(1, 1, 1, 1)
ApplyTextColor(filterButton, FONT_COLOR.WHITE)
filterButton.bg:SetColor(0,0,0,0)
moveWnd.filterButton = filterButton

-- type button

local typeButton = api.Interface:CreateComboBox(moveWnd)
typeButton:AddAnchor("TOPLEFT", moveWnd, 10, 28)
typeButton:SetExtent(150, 30)
typeButton.dropdownItem = typeDisplay
typeButton:Select(1)
typeButton.style:SetFontSize(FONT_SIZE.XLARGE)
typeButton:SetHighlightTextColor(1, 1, 1, 1)
typeButton:SetPushedTextColor(1, 1, 1, 1)
typeButton:SetDisabledTextColor(1, 1, 1, 1)
typeButton:SetTextColor(1, 1, 1, 1)
ApplyTextColor(typeButton, FONT_COLOR.WHITE)
typeButton.bg:SetColor(0,0,0,0)
moveWnd.typeButton = typeButton

-- Minimize button
local minimizeButton = raidStatsWnd:CreateChildWidget("button", "minimizeButton", 0, true)
minimizeButton:SetExtent(26, 28)
minimizeButton:AddAnchor("TOPRIGHT", raidStatsWnd, -12, 5)
local minimizeButtonTexture = minimizeButton:CreateImageDrawable(TEXTURE_PATH.HUD, "background")
minimizeButtonTexture:SetTexture(TEXTURE_PATH.HUD)
minimizeButtonTexture:SetCoords(754, 121, 26, 28)
minimizeButtonTexture:AddAnchor("TOPLEFT", minimizeButton, 0, 0)
minimizeButtonTexture:SetExtent(26, 28)

-- Refresh button for timer
local refreshButton = raidStatsWnd:CreateChildWidget("button", "refreshButton", 0, true)
refreshButton:SetExtent(55, 26)
refreshButton:AddAnchor("RIGHT", minimizeButton, "RIGHT", -50, 0)
refreshButton:Show(true)
api.Interface:ApplyButtonSkin(refreshButton, BUTTON_BASIC.RESET)


--- Minimized view & maximize button
local minimizedWnd = api.Interface:CreateEmptyWindow("minimizedWnd", "UIParent")
minimizedWnd:SetExtent(280, 40)
minimizedWnd:AddAnchor("TOPRIGHT", raidStatsWnd, 0, 0)
local minimizedLabel = minimizedWnd:CreateChildWidget("label", "minimizedLabel", 0, true)
minimizedLabel:SetText("Raid Stats (Hidden)")
minimizedLabel.style:SetFontSize(FONT_SIZE.XLARGE)
minimizedLabel.style:SetAlign(ALIGN.RIGHT)
minimizedLabel:AddAnchor("TOPRIGHT", minimizedWnd, -100, FONT_SIZE.XLARGE)
-- Dragable bar for minimized window too
local minimizedMoveWnd = minimizedWnd:CreateChildWidget("label", "minimizedMoveWnd", 0, true)
minimizedMoveWnd:AddAnchor("TOPLEFT", minimizedWnd, 12, 0)
minimizedMoveWnd:AddAnchor("TOPRIGHT", minimizedWnd, 0, 0)
minimizedMoveWnd:SetHeight(40)
-- Drag handlers for dragable bar
function minimizedMoveWnd:OnDragStart(arg)
	if arg == nil or (arg == "LeftButton" and api.Input:IsShiftKeyDown()) then
		minimizedWnd:StartMoving()
		api.Cursor:ClearCursor()
		api.Cursor:SetCursorImage(CURSOR_PATH.MOVE, 0, 0)
	end
end
minimizedMoveWnd:SetHandler("OnDragStart", minimizedMoveWnd.OnDragStart)
function minimizedMoveWnd:OnDragStop()
	minimizedWnd:StopMovingOrSizing()
	api.Cursor:ClearCursor()
end
minimizedMoveWnd:SetHandler("OnDragStop", minimizedMoveWnd.OnDragStop)
if minimizedMoveWnd.RegisterForDrag ~= nil then
	minimizedMoveWnd:RegisterForDrag("LeftButton")
end
if minimizedMoveWnd.EnableDrag ~= nil then
    minimizedMoveWnd:EnableDrag(true)
end
-- Toggle back to maximized view with this button
local maximizeButton = minimizedWnd:CreateChildWidget("button", "maximizeButton", 0, true)
maximizeButton:SetExtent(26, 28)
maximizeButton:AddAnchor("TOPRIGHT", minimizedWnd, -12, 5)
local maximizeButtonTexture = maximizeButton:CreateImageDrawable(TEXTURE_PATH.HUD, "background")
maximizeButtonTexture:SetTexture(TEXTURE_PATH.HUD)
maximizeButtonTexture:SetCoords(754, 94, 26, 28)
maximizeButtonTexture:AddAnchor("TOPLEFT", maximizeButton, 0, 0)
maximizeButtonTexture:SetExtent(26, 28)
-- Minimized Window Background Styling
minimizedWnd.bg = minimizedWnd:CreateNinePartDrawable(TEXTURE_PATH.HUD, "background")
minimizedWnd.bg:SetTextureInfo("bg_quest")
minimizedWnd.bg:SetColor(0, 0, 0, 0.5)
minimizedWnd.bg:AddAnchor("TOPLEFT", minimizedWnd, 0, 0)
minimizedWnd.bg:AddAnchor("BOTTOMRIGHT", minimizedWnd, 0, 0)

minimizedWnd:Show(false) --> default to being hidden

-- Main Window Background Styling
raidStatsWnd.bg = raidStatsWnd:CreateNinePartDrawable(TEXTURE_PATH.HUD, "background")
raidStatsWnd.bg:SetTextureInfo("bg_quest")
raidStatsWnd.bg:SetColor(0, 0, 0, 0.5)
raidStatsWnd.bg:AddAnchor("TOPLEFT", raidStatsWnd, 0, 0)
raidStatsWnd.bg:AddAnchor("BOTTOMRIGHT", raidStatsWnd, 0, 0)



raidStatsWnd.fetchData = nil
--- Dropdown Handlers
-- Main Filter Dropdown

--Michael function
local function getKeysSortedByValue(tbl, sortFunction)
  local keys = {}
  for key in pairs(tbl) do
    table.insert(keys, key)
  end
  table.sort(keys, function(a, b)
    return sortFunction(tbl[a], tbl[b])
  end)
  return keys
end

local function Update()
	if raidStatsWnd.fetchData == nil then
		return
	end
	--ApplyTextColor(raidStatsWnd.moveWnd.filterButton, FONT_COLOR.WHITE)
	local selectedindex = raidStatsWnd.moveWnd.filterButton:GetSelectedIndex() + ((raidStatsWnd.moveWnd.typeButton:GetSelectedIndex() - 1 ) * 7)
	 

	result = raidStatsWnd.fetchData(selectedindex)


	local sortedPlayers = getKeysSortedByValue(result, function(a, b) return a > b end)


	local i = 1
	local maxvalue = result[sortedPlayers[1]]
	while sortedPlayers[i] ~= nil and i < 11 do
		raidStatsWnd.child[i].bgStatusBar.statLabel:SetText(tostring(sortedPlayers[i]))
        raidStatsWnd.child[i].bgStatusBar.statAmtLabel:SetText(tostring(result[sortedPlayers[i]]))
		
		local relativePercent = (result[sortedPlayers[i]] / maxvalue) * 100
        raidStatsWnd.child[i].bgStatusBar:SetValue(math.floor(relativePercent))

		i = i + 1
	end
	while i < 11 do
		raidStatsWnd.child[i].bgStatusBar.statLabel:SetText("")
		raidStatsWnd.child[i].bgStatusBar.statAmtLabel:SetText("")

		raidStatsWnd.child[i].bgStatusBar:SetValue(0)
	--reset any unused row
		i = i + 1
	end

end
raidStatsWnd.minimizeButton:SetHandler("OnClick", function()
  local statsMeterX, statsMeterY = raidStatsWnd:GetOffset()
  minimizedWnd:RemoveAllAnchors()
  minimizedWnd:AddAnchor("TOPRIGHT", raidStatsWnd, 0, 0)
  raidStatsWnd:Show(false)
  minimizedWnd:Show(true)
end)

minimizedWnd.maximizeButton:SetHandler("OnClick", function()
  raidStatsWnd:RemoveAllAnchors()
  raidStatsWnd:AddAnchor("TOPLEFT", minimizedWnd, 0, 0)
  minimizedWnd:Show(false)
  raidStatsWnd:Show(true)
  Update()
end)


function raidStatsWnd:SetGetDataDelegate(delegate)
	raidStatsWnd.fetchData = delegate
end

raidStatsWnd.refreshButton:SetHandler("OnClick", function()
  Update()
end)

function raidStatsWnd.moveWnd.filterButton:SelectedProc()
  --api.Log:Info("selected new item")
  Update()
end

function raidStatsWnd.moveWnd.typeButton:SelectedProc()
  --api.Log:Info("selected new item")
  Update()
end

-- Show the damn thing.
--raidStatsWnd:Show(true)

  --local statsMeterX, statsMeterY = raidStatsWnd:GetOffset()
  minimizedWnd:RemoveAllAnchors()
  minimizedWnd:AddAnchor("TOPRIGHT", raidStatsWnd, 0, 0)
  raidStatsWnd:Show(false)
  minimizedWnd:Show(true)

function raidStatsWnd:Close()

	raidStatsWnd:Show(false)
	minimizedWnd:Show(false)
end


return raidStatsWnd