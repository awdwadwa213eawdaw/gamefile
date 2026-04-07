local assets = {}

local Audios = require(game.ReplicatedStorage.AudioManager)

assets.musicId = {
	ContinueScreen = Audios.ContinueScreen,
}

local AssetsInitModule = require(game.ReplicatedStorage:WaitForChild("AssetsInit"))
local IDs = script:WaitForChild("IDs")

repeat task.wait() until AssetsInitModule.INITIALIZED

assets.placeId = {
	Main = AssetsInitModule.RTD.Main,
	Battle = AssetsInitModule.RTD.Battle,
	Trade = AssetsInitModule.RTD.Trade,
}

assets.animationId = {
	IntroSleep = 118249879692036,
	IntroSit = 88061236115166,
	NPCSwim = 126221643310945,
	NPCIdleSwim = 124390062124994,
	NPCIdle = 83037249272233,
	NPCWalk = 133222395453468,
	NPCWave = 80349774103233,
	NPCDance1 = 107404849817741,
	NPCDance2 = 112483377882106,
	NPCDance3 = 126543027417459,
	NPCBreakDance = 96225692985102,
	NPCPoint = 92686140864354,
	NurseBow = 77787489564230,
	Run = 90735642590909,
	RodIdle = 88383920227218,
	RodCast = 136513825428696,
	RodReel = 96175372372752,
	ThrowBall = 91603300958271,
	FlipSign = 122838403824611,
	EatSushi = 104976407454056,
	Sit = 85018603208895,
	Carry = 136296911231320,
	Surf = 107706254120068,
	ZPower = 109912319915559,

	absolIdle = 70614763101586,
	absolRun = 119739555919750,
	absolSniff = 131670062651515,
	palkiaIdle = 103055886729834,
	palkiaHover = 81834839887831,
	palkiaRoarAir = 76600110777002,
	palkiaRoarGround = 71112792606822,
	dialgaIdle = 138283454362853,
	dialgaHover = 107013297074722,
	dialgaRoarAir = 94621280698195,
	dialgaRoarGround = 133686591025078,
	heatranIdle = 126281282460839,
	heatranRoar = 78223166008084,
	raikouRun = 105429301355304,
	enteiRun = 99517859036989,
	suicuneRun = 86897757425702,
	LaprasIdle = 121636264508294,
	ArticunoIdle = 127403051401492,
	ZapdosIdle = 94207305088092,
	MoltresIdle = 79856032336182,
	CobalionIdle = 71958161051636,
	TerrakionIdle = 112110240548369,
	VirizionIdle = 83655741521592,
	KeldeoIdle = 78740899940332,
	hoopaAttack = 105991876253803,
	hoopaIdle = 127079410438587,
	hoopaIdle2 = 128958879715888,
	hoopaIdleSlow = 95125253874331,
	HoOhAttack = 122472936901194,

	cmJump = 78972204099109,
	cmHats = 104688599313380,
	profChange = 97365180571133,
	profTurn = 89854457684741,
	jhatIdle = 140468767026301,
	jhatAction = 125959658829582,
	JakeDive = 104221108971594,
	TessFall = 74468007937708,
	jakeLift = 92195766074228,
	jakeHold = 127599837095896,
	jakeThrow = 137004701248526,
	cypressWeee = 91763631431147,
	JakePortal = 126639032690928,

	h_idle = 86724237249321,
	h_mount = 98158956259350,
	h_forward = 107478819524569,
	h_backward = 91939484043809,
	h_left = 96336832796407,
	h_right = 99803205216190,
	h_trick1 = 121782319498825,
	h_trick2 = 136733576472256,
	h_trick3 = 88795803972056,

	R15_IntroSleep = 113279193539917,
	R15_IntroWake = 78348170457336,
	R15_IntroTossClock = 138399580120321,
	R15_Idle = 128472246480953,
	R15_Run = 132955416784153,
	R15_ThrowBall = 97120651243590,
	R15_Sit = 83889502601875,
	R15_Sushi = 112825361083382,
	R15_Carry = 102150754873400,
	R15_RodIdle = 70784518958465,
	R15_RodCast = 120383347175023,
	R15_RodReel = 126676397851115,
	R15_h_idle = 128547776703796,
	R15_h_mount = 140232914567533,
	R15_h_forward = 127340654015806,
	R15_h_backward = 80539652030063,
	R15_h_left = 110191936896611,
	R15_h_right = 110520954159390,
	R15_h_trick1 = 111091032623204,
	R15_h_trick2 = 82116772316238,
	R15_h_trick3 = 107876030952475,
	R15_Surf = 81866999801906,
	R15_ZPower = 126360813194623,
}

for animationName, animationId in pairs(AssetsInitModule.Animations) do
	assets.animationId[animationName] = animationId
end

-- just for the sake of simplicity
function get(i, j)
	local config = IDs.RoPowers:FindFirstChild(tostring(i))
	if not config then return nil end

	local numobject = config:FindFirstChild(tostring(j))
	if not numobject then return nil end

	return numobject
end

assets.productId = {
	Starter = IDs.Starter,
	TenBP = IDs.TenBP,
	FiftyBP = IDs.FiftyBP,
	TwoHundredBP = IDs.TwoHundredBP,
	FiveHundredBP = IDs.FiveHundredBP,
	UMV1 = IDs.UMV1,
	UMV3 = IDs.UMV3,
	UMV6 = IDs.UMV6,
	_10kP = IDs._10kP,
	_50kP = IDs._50kP,
	_100kP = IDs._100kP,
	_200kP = IDs._200kP,
	PBSpins1 = IDs.PBSpins1,
	PBSpins5 = IDs.PBSpins5,
	PBSpins10 = IDs.PBSpins10,
	AshGreninja = IDs.AshGreninja,
	Hoverboard = IDs.Hoverboard,
	MasterBall = IDs.MasterBall,
	LottoTicket = IDs.LottoTicket,
	TixPurchase = IDs.TixPurchase,

	RouletteSpinBasic = IDs.RouletteSpinBasic,
	RouletteSpinBronze = IDs.RouletteSpinBronze,
	RouletteSpinSilver = IDs.RouletteSpinSilver,
	RouletteSpinGold = IDs.RouletteSpinGold,
	RouletteSpinDiamond = IDs.RouletteSpinDiamond,

	RoPowers = {
		{get(1,1), get(1,2)},
		{get(2,1), get(2,2)},
		{get(3,1), get(3,2)},
		{get(4,1), get(4,2)},
		{get(5,1)},
		{},
		{get(7,1)}
	}
}



assets.passId = {
	ExpShare = 1,
	MoreBoxes = 1,
	ShinyCharm = 1,
	AbilityCharm = 1,
	OvalCharm = 1,
	StatViewer = 1,
	RoamingCharm = 1,
	ThreeStamps = 1,
	PondPass = 1,
}

assets.badgeId = {
	Gym1 = 313617167,
	Gym2 = 317830251,
	Gym3 = 338423949,
	Gym4 = 512924091,
	Gym5 = 620490478,
	Gym6 = 668968355,
	DexCompletion = {
		{100, 687781576},
		{250, 687782030},
		{400, 687782269},
		{550, 688159425},
	}
}

assets.badgeImageId = {
	6607886258,
	6607887174,
	6607888513,
	6607889606,
	6607890607,
	6607891487,
	2566476879,
	6255334285,
}

if game.CreatorId == 1 then
	assets.placeId = {
		Main = 146778246,
		Battle = 313771763,
		Trade = 314437797,
	}
end

return assets