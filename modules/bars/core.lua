local _, ns = ...
local E, C, M, L = ns.E, ns.C, ns.M, ns.L
local B = E:AddModule("Bars")

function B:IsEnabled()
	return B.isRunning
end

function B:Initialize()
	if C.bars.enabled then
		B:ActionBarController_Initialize()
		B:HandleActionBars()
		B:HandlePetBattleBar()
		B:HandleExtraActionButton()
		B:HandleVehicleExitButton()
		B:HandleMicroMenu()
		B:HandleBag()

		B.isRunning = true
	end
end
