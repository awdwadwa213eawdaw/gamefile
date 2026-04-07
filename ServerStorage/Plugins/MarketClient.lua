return function(_p)
local marketplaceService = game:GetService('MarketplaceService')
local market = {}


function market:promptProductPurchase(devProductId)
	marketplaceService:PromptProductPurchase(_p.player, devProductId.Value)
	print(devProductId.Value)
end

function market:promptPurchase(assetId)
	marketplaceService:PromptGamePassPurchase(_p.player, assetId)
end


return market end