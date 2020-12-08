--[[
AdiBags - Shadowlands item filter
by PsyKzz
version: v1.0
Adds a new filter for Anima and Conduit items
]]

local addonName, addon = ...
local AdiBags = LibStub("AceAddon-3.0"):GetAddon("AdiBags")
local LCG = LibStub('LibCustomGlow-1.0')

local mod = AdiBags:RegisterFilter("Shadowlands - Covenant Items", 100, "ABEvent-1.0")
mod.uiName = "Shadowlands - Covenant Items"
mod.uiDesc = "Separate out different Shadowlands items, like Anima and Conduits."

function mod:OnInitialize()
    self.db = AdiBags.db:RegisterNamespace("Covenant Items", {
        profile = {
            anima = true,
			conduits = true,
			covenantCrafting = true,
			highlight = "pixel",
			glowColor = { 1, 1, 0.0, 0.7 },
		}
	})
end

function mod:Update()
	self:SendMessage("AdiBags_FiltersChanged")
end

function mod:UpdateButton(event, button)
	local enabled = self.db.profile.conduits and self.db.profile.highlight ~= "none"
	local isBankButton = AdiBags.BAG_IDS.BANK[button.bag]
	local soulbindFrameShown = SoulbindViewer and SoulbindViewer:IsShown() and SoulbindViewer:IsVisible()
	if (not enabled) or (isBankButton) or (not soulbindFrameShown) then return end

	local itemLoc = ItemLocation:CreateFromBagAndSlot(button.bag, button.slot)
	if (not itemLoc:IsValid()) then return end
	
	local isConduit = C_Item.IsItemConduit(itemLoc)

	-- only pixel / particle supported
	self:ShowPixelGlow(button, isConduit and self.db.profile.highlight == "pixel")
	self:ShowParticleGlow(button, isConduit and self.db.profile.highlight == "particle")
end

function mod:OnEnable()
	AdiBags:UpdateFilters()
	self:RegisterMessage('AdiBags_UpdateButton', 'UpdateButton')
end

function mod:OnDisable()
	AdiBags:UpdateFilters()
end

function mod:Filter(slotData)
    local itemLoc = ItemLocation:CreateFromBagAndSlot(slotData.bag, slotData.slot)
    if self.db.profile.conduits and C_Item.IsItemConduit(itemLoc) then 
        return "Conduit"
    end

    local item = GetContainerItemLink(slotData.bag, slotData.slot)
    if self.db.profile.anima and C_Item.IsAnimaItemByID(item) then
        return "Anima"
    end


    local KyrianCraftingItems = {
        [180477] = true, -- feathers
        [180595] = true, -- steel
        [180594] = true, -- bone
        [180478] = true, -- pelt
        [178995] = true, -- soul shard
        [179378] = true, -- soul mirror
    }

    local NecrolordCraftingItems = {
        [178061] = true, -- mallable flesh
        [183744] = true, -- superior parts
    }

    local NightFaeCraftingItems = {
        [178879] = true, -- divine dutiful spirit
        [178880] = true, -- greater dutiful spirit
        [178881] = true, -- dutiful spirit

        [178874] = true, -- martial spirit
        [178877] = true, -- greater martial spirit
        [178878] = true, -- divine martial spirit

        [177698] = true, -- untamed spirit
        [177699] = true, -- greater untamed spirit
        [177700] = true, -- divine untamed spirit

        [178882] = true, -- prideful spirit
        [178883] = true, -- greater prideful spirit
        [178884] = true, -- divine prideful spirit

        [176832] = true, -- wildseed root grain
        [176922] = true, -- temporal leaves
        [176922] = true, -- wild nightbloom
    }

    local item = GetContainerItemLink(slotData.bag, slotData.slot)
    if self.db.profile.covenantCrafting and (KyrianCraftingItems[slotData.itemId] or NecrolordCraftingItems[slotData.itemId] or NightFaeCraftingItems[slotData.itemId]) then
        return "Covenant Crafting"
    end
end

function mod:GetOptions()
	return {
		anima = {
			name = "Anima",
			desc = "Items redeemmed at the sanctum upgrade for Reserved Anima",
			type = "toggle",
			order = 10
		},
		conduits = {
			name = "Conduits",
			desc = "Items used at the Soul Forge.",
			type = "toggle",
			order = 20
		},
		covenantCrafting = {
			name = "Covenant Crafting items",
			desc = "Items used at for specific convenant.",
			type = "toggle",
			order = 30
		},
		highlight = {
			name = "Highlight style",
			type = 'select',
			order = 40,
			width = 'double',
			values = {
				none = "None",
				pixel = "Pixel",
				particle = "Particle"
			}
		},
		glowColor = {
			name = "Highlight color",
			type = 'color',
			order = 50,
			hasAlpha = true,
			disabled = function()
				return mod.db.profile.highlight == "none"
			end,
		},
	},
	AdiBags:GetOptionHandler(self, false, function ()
		return self:Update()
	end)
end


-- Glows
--------------------------------------------------------------------------------
-- Pixel glow
--------------------------------------------------------------------------------
function mod:ShowPixelGlow(button, enable)
	if enable then
		LCG.PixelGlow_Start(button, mod.db.profile.glowColor, nil, -0.25, nil, 2, 1, 0)
	else
		LCG.PixelGlow_Stop(button)
	end
end

--------------------------------------------------------------------------------
-- Particle glow
--------------------------------------------------------------------------------
function mod:ShowParticleGlow(button, enable)
	if enable then
		LCG.AutoCastGlow_Start(button, mod.db.profile.glowColor, 6, -0.25, 1.5)
	else
		LCG.AutoCastGlow_Stop(button)
	end
end
