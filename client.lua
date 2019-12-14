--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Sody Clubs
-- v1.0.1 - 12/13/2019
-- By SodyFX with Love
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

local PlayerClub, PlayerRank, PlayerRankNum, ClubBlip = nil, nil, nil, nil
local zones, garage, ClubList, ClubListFull = {}, {}, {}, {}
local hasClub, menuIsShowed, hintIsShowed, hasAlreadyEnteredMarker, isInMarker, isInMarker2, CurrentGarage = false, false, false, false, false, false, false
local hintToDisplay = ""

ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
--AddEventHandler('onResourceStart', function(resourceName) -- For debugging to start/stop resources without server restart
	Citizen.Wait(1000)
	zones = {}
	garage = {}
	hasClub = false
	TriggerServerEvent('sody_clubs:getClubList')
	Citizen.Wait(5000)
	ESX.TriggerServerCallback('sody_clubs:getPlayerClub', function(playerdata)
		PlayerClub = playerdata.club
		PlayerRank = playerdata.club_rank_name
		PlayerRankNum = playerdata.club_rank
		if PlayerClub ~= nil and has_value(ClubList, PlayerClub) then
			zones = Config.Clubs[PlayerClub].Zones
			garage = Config.Clubs[PlayerClub].Garage
			hasClub = true
			Citizen.Wait(500)
			displayClubMarkers(PlayerClub)
			playerZones()
			ClubGarages()
			addClubBlips(PlayerClub)
		else
			zones = {}
			garage = {}
			hasClub = false
		end
	end)
end)

RegisterNetEvent('sody_clubs:forceSync')
AddEventHandler('sody_clubs:forceSync', function(xPlayer)
	Citizen.Wait(1000)
	zones = {}
	garage = {}
	hasClub = false
	TriggerServerEvent('sody_clubs:getClubList')
	Citizen.Wait(5000)
	ESX.TriggerServerCallback('sody_clubs:getPlayerClub', function(playerdata)
		PlayerClub = playerdata.club
		PlayerRank = playerdata.club_rank_name
		PlayerRankNum = playerdata.club_rank
		if PlayerClub ~= nil and has_value(ClubList, PlayerClub) then
			zones = Config.Clubs[PlayerClub].Zones
			garage = Config.Clubs[PlayerClub].Garage
			hasClub = true
			Citizen.Wait(500)
			displayClubMarkers(PlayerClub)
			playerZones()
			ClubGarages()
			addClubBlips(PlayerClub)
		else
			zones = {}
			garage = {}
			hasClub = false
		end
	end)
end)

function addClubBlips(club)
	Citizen.CreateThread(function()
		RemoveBlip(ClubBlip)
		if has_value_index(Config.ClubBlips, club) then
			ClubBlip = AddBlipForCoord(Config.ClubBlips[club].BlipPos.x, Config.ClubBlips[club].BlipPos.y, Config.ClubBlips[club].BlipPos.z)

			SetBlipSprite(ClubBlip, Config.ClubBlips[club].BlipSprite)
			SetBlipColour(ClubBlip, Config.ClubBlips[club].BlipColor)
			SetBlipDisplay(ClubBlip, 4)
			SetBlipScale(ClubBlip, 1.0)
			SetBlipAsShortRange(ClubBlip, true)


			BeginTextCommandSetBlipName("STRING")
			AddTextComponentString(Config.ClubBlipPre .. ClubListFull[club])
			EndTextCommandSetBlipName(ClubBlip)
		end
	end)
end

RegisterNetEvent('sody_clubs:clubAdded')
AddEventHandler('sody_clubs:clubAdded', function(club)
	zones = {}
	garage = {}
	hasClub = false
	Citizen.Wait(1000)
	ESX.TriggerServerCallback('sody_clubs:getPlayerClub', function(playerdata)
		PlayerClub = playerdata.club
		PlayerRank = playerdata.club_rank_name
		PlayerRankNum = playerdata.club_rank
		if PlayerClub ~= nil and has_value(ClubList, PlayerClub) then
			zones = Config.Clubs[PlayerClub].Zones
			garage = Config.Clubs[PlayerClub].Garage
			hasClub = true
			Citizen.Wait(500)
			displayClubMarkers(PlayerClub)
			playerZones()
			ClubGarages()
			addClubBlips(PlayerClub)
		else
			zones = {}
			garage = {}
			hasClub = false
		end
	end)
end)

RegisterNetEvent('sody_clubs:clubPromoted')
AddEventHandler('sody_clubs:clubPromoted', function(newrank, newrankname)
	PlayerRank = newrankname
	PlayerRankNum = newrank
end)

RegisterNetEvent('sody_clubs:clubRemoved')
AddEventHandler('sody_clubs:clubRemoved', function()
	PlayerClub, PlayerRank, PlayerRankNum = nil, nil, nil
	zones = {}
	garage = {}
	hasClub = false
end)

AddEventHandler('sody_clubs:hasExitedMarker', function()
	ESX.UI.Menu.CloseAll()
	hintToDisplay = ""
	menuIsShowed = false
	hintIsShowed = false
	isInMarker = false
end)

AddEventHandler('sody_clubs:action', function(zone)
	menuIsShowed = true
	if zone.Type == "storage" then
		local menutitle = PlayerClub .. "menu"
		local elements = {}

		if PlayerRankNum >= Config.Clubs[PlayerClub].Perms.StorageRankMin then
			elements = {
				{label = _U('deposit_stock'),  value = 'put_stock'},
				{label = _U('withdraw_stock'), value = 'get_stock'}
			}
		else
			elements = {
				{label = 'Access Denied',  value = 'blank'}
			}
		end

		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'job_actions', {
			title    = _U(menutitle),
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			if data.current.value == 'put_stock' then
				OpenPutStocksMenu()
			elseif data.current.value == 'get_stock' then
				OpenGetStocksMenu()
			end
		end, function(data, menu)
			menu.close()
		end)
	elseif zone.Type == "storagepriv" then
		local menutitle = PlayerClub .. "menu"
		local elements = {}

		if PlayerRankNum >= Config.Clubs[PlayerClub].Perms.StorageRankMinPriv then
			elements = {
				{label = _U('deposit_stock'),  value = 'put_stock'},
				{label = _U('withdraw_stock'), value = 'get_stock'}
			}
		else
			elements = {
				{label = 'Access Denied',  value = 'blank'}
			}
		end

		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'job_actions', {
			title    = _U(menutitle),
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			if data.current.value == 'put_stock' then
				OpenPutStocksMenuPriv()
			elseif data.current.value == 'get_stock' then
				OpenGetStocksMenuPriv()
			end
		end, function(data, menu)
			menu.close()
		end)
	elseif zone.Type == "storagepub" then
		local menutitle = PlayerClub .. "menu"
		local elements = {}

		local elements = {
			{label = _U('deposit_stock'),  value = 'put_stock'},
			{label = _U('withdraw_stock'), value = 'get_stock'}
		}

		ESX.UI.Menu.CloseAll()

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'job_actions', {
			title    = _U(menutitle),
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			if data.current.value == 'put_stock' then
				OpenPutStocksMenuPub()
			elseif data.current.value == 'get_stock' then
				OpenGetStocksMenuPub()
			end
		end, function(data, menu)
			menu.close()
		end)
	elseif zone.Type == "changingroom" then
		OpenChangingRoomMenu()
	elseif zone.Type == "owner" then
		if (PlayerRank == 'owner' or PlayerRank == 'treasurer') and PlayerClub ~= nil then
			OpenClubOwnerMenu(PlayerClub, PlayerRank)
		end
	elseif zone.Type == "teleport" then
		DoScreenFadeOut(750)
		Citizen.Wait(1000)
		SetEntityCoords(PlayerPedId(), zone.PosDest.x, zone.PosDest.y, zone.PosDest.z)
		SetEntityHeading(PlayerPedId(), zone.PosDestH)
		DoScreenFadeIn(750)
	elseif zone.Type == "gteleport" then
		local vehicle = GetVehiclePedIsIn(GetPlayerPed(-1), false)
		if vehicle and GetPedInVehicleSeat(vehicle, -1) == GetPlayerPed(-1) then
			DoScreenFadeOut(750)
			Citizen.Wait(1000)
			SetEntityCoords(vehicle, zone.PosDest.x, zone.PosDest.y, zone.PosDest.z)
			SetEntityHeading(vehicle, zone.PosDestH)
			DoScreenFadeIn(750)
		elseif not vehicle then
			ESX.ShowNotification("Must be driving a vehicle to exit through garage")
		elseif vehicle and GetPedInVehicleSeat(vehicle, -1) ~= GetPlayerPed(-1) then
			ESX.ShowNotification("Must be driving the vehicle to exit garage")
		end
	elseif zone == "spawn" then
		menuIsShowed = false
		while CurrentGarage do
			Citizen.Wait(10)
			if IsControlJustReleased(0, 38) and isInMarker2 then
				OpenMenuGarage('spawn', CurrentGarage)
				Citizen.Wait(2000)
				isInMarker2 = false
				CurrentGarage = false
				TriggerEvent('sody_clubs:hasExitedMarker')
			end
		end
	elseif zone == "delete" then
		menuIsShowed = false
		while CurrentGarage do
			Citizen.Wait(10)
			if IsControlJustReleased(0, 38) and isInMarker2 then
				OpenMenuGarage('delete', CurrentGarage)
				Citizen.Wait(2000)
				isInMarker2 = false
				CurrentGarage = false
				TriggerEvent('sody_clubs:hasExitedMarker')
			end
		end
	end
end)

-- Show top left hint
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)

		if hintIsShowed and not menuIsShowed then
			ESX.ShowHelpNotification(hintToDisplay)
		else
			Citizen.Wait(500)
		end
	end
end)

RegisterNetEvent('sody_clubs:setClubList')
AddEventHandler('sody_clubs:setClubList', function(clublist, clublistfull)
	ClubList = clublist
	ClubListFull = clublistfull
end)

function OpenClubOwnerMenu(club, rank)
	local isOwner, isTreasurer = nil, nil
	local options  = options or {}
	local elements = {}

	ESX.TriggerServerCallback('sody_clubs:getOwner', function(result)
		isOwner = tonumber(result)
	end, club)

	ESX.TriggerServerCallback('sody_clubs:getTreasurer', function(result)
		isTreasurer = tonumber(result)
	end, club)

	while isOwner == nil do
		Citizen.Wait(50)
	end

	while isTreasurer == nil do
		Citizen.Wait(50)
	end

	if PlayerRankNum ~= isOwner and PlayerRankNum ~= isTreasurer then
		--print("Not owner or treasurer")
		return
	end

	local defaultOptions = {
		withdraw  = true,
		deposit   = true,
		members = true,
		pay = true
	}

	for k,v in pairs(defaultOptions) do
		if options[k] == nil then
			options[k] = v
		end
	end

	if isTreasurer == PlayerRankNum then
		options.withdraw = true
		options.deposit = true
		options.members = false
		options.pay = false
	end

	if options.withdraw then
		table.insert(elements, {label = 'Check club bank balance', value = 'balance_bank_money'})
		table.insert(elements, {label = _U('withdraw_bank_money'), value = 'withdraw_bank_money'})
	end

	if options.deposit then
		table.insert(elements, {label = _U('deposit_bank_money'), value = 'deposit_bank_money'})
	end

	if options.members then
		table.insert(elements, {label = _U('member_management'), value = 'manage_members'})
	end

	if options.pay then
		table.insert(elements, {label = _U('pay_management'), value = 'manage_pay'})
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'owner_actions_' .. club, {
		title    = _U('owner_menu'),
		align    = 'top-right',
		elements = elements
	}, function(data, menu)

		if data.current.value == 'balance_bank_money' then

			TriggerServerEvent('sody_clubs:bankBalance', club)
			menu.close()

		elseif data.current.value == 'withdraw_bank_money' then

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'withdraw_club_money_amount_' .. club, {
				title = _U('withdraw_amount')
			}, function(data, menu)

				local amount = tonumber(data.value)

				if amount == nil then
					ESX.ShowNotification(_U('invalid_amount'))
				else
					menu.close()
					TriggerServerEvent('sody_clubs:withdrawBank', club, amount)
				end

			end, function(data, menu)
				menu.close()
			end)

		elseif data.current.value == 'deposit_bank_money' then

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'deposit_bank_money_amount_' .. club, {
				title = _U('deposit_amount')
			}, function(data, menu)

				local amount = tonumber(data.value)

				if amount == nil then
					ESX.ShowNotification(_U('invalid_amount'))
				else
					menu.close()
					TriggerServerEvent('sody_clubs:depositBank', club, amount)
				end

			end, function(data, menu)
				menu.close()
			end)

		elseif data.current.value == 'manage_members' then
			OpenManageMembersMenu(club)
		elseif data.current.value == 'manage_pay' then
			OpenManagePayMenu(club)
		end

	end, function(data, menu)
		menu.close()
	end)

end

function OpenManageMembersMenu(club)
	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_members_' .. club, {
		title    = _U('member_management'),
		align    = 'top-right',
		elements = {
			{label = _U('member_list'), value = 'member_list'},
			{label = _U('recruit'),       value = 'recruit'}
		}
	}, function(data, menu)

		if data.current.value == 'member_list' then
			OpenMemberList(club)
		end

		if data.current.value == 'recruit' then
			OpenRecruitMenu(club)
		end

	end, function(data, menu)
		menu.close()
	end)
end

function OpenMemberList(club)
	ESX.TriggerServerCallback('sody_clubs:getMembers', function(members, club)
		local elements = {}

		elements = {
			head = {_U('member'), _U('rank'), _U('actions')},
			rows = {}
		}

		for i=1, #members, 1 do
			local rankLabel = (members[i].club.rank_label == '' and members[i].club.label or members[i].club.rank_label)

			table.insert(elements.rows, {
				data = members[i],
				cols = {
					members[i].name,
					rankLabel,
					'{{' .. _U('promote') .. '|promote}} {{' .. _U('remove') .. '|remove}}'
				}
			})
		end

		ESX.UI.Menu.Open('list', GetCurrentResourceName(), 'member_list_' .. club, elements, function(data, menu)
			local member = data.data

			if data.value == 'promote' then
				menu.close()
				OpenPromoteMenu(club, member)
			elseif data.value == 'remove' then
				ESX.ShowNotification(_U('you_have_fired', member.name))

				ESX.TriggerServerCallback('sody_clubs:setClub', function()
					OpenMemberList(club)
				end, member.identifier, nil, nil, 'remove')
			end
		end, function(data, menu)
			menu.close()
			OpenManageMembersMenu(club)
		end)

	end, club)

end

function OpenRecruitMenu(club)
	ESX.TriggerServerCallback('sody_clubs:getOnlinePlayers', function(players)

		local elements = {}

		for i=1, #players, 1 do
			if players[i].job.name ~= club then
				table.insert(elements, {
					label = players[i].name,
					value = players[i].source,
					name = players[i].name,
					identifier = players[i].identifier
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'recruit_' .. club, {
			title    = _U('recruiting'),
			align    = 'top-right',
			elements = elements
		}, function(data, menu)

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'recruit_confirm_' .. club, {
				title    = _U('do_you_want_to_recruit', data.current.name),
				align    = 'top-right',
				elements = {
					{label = _U('no'),  value = 'no'},
					{label = _U('yes'), value = 'yes'}
				}
			}, function(data2, menu2)
				menu2.close()

				if data2.current.value == 'yes' then
					ESX.ShowNotification(_U('you_have_hired', data.current.name))

					ESX.TriggerServerCallback('sody_clubs:setClub', function()
						OpenRecruitMenu(club)
					end, data.current.identifier, club, 0, 'hire')
				end
			end, function(data2, menu2)
				menu2.close()
			end)

		end, function(data, menu)
			menu.close()
		end)

	end)

end

function OpenPromoteMenu(clubname, member)
	ESX.TriggerServerCallback('sody_clubs:getClub', function(club)

		local elements = {}

		for i=1, #club.ranks, 1 do
			local rankLabel = (club.ranks[i].club_rank_label == '' and club.club_rank_label or club.ranks[i].club_rank_label)

			table.insert(elements, {
				label = rankLabel,
				value = club.ranks[i].club_rank,
				selected = (member.club.club_rank == club.ranks[i].club_rank)
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'promote_member_' .. clubname, {
			title    = _U('promote_member', member.name),
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			menu.close()
			ESX.ShowNotification(_U('you_have_promoted', member.name, data.current.label))

			ESX.TriggerServerCallback('sody_clubs:setClub', function()
				OpenMemberList(clubname)
			end, member.identifier, clubname, data.current.value, 'promote')
		end, function(data, menu)
			menu.close()
			OpenMemberList(clubname)
		end)

	end, clubname)

end

function OpenManagePayMenu(clubname)
	ESX.TriggerServerCallback('sody_clubs:getClub', function(club)

		local elements = {}

		for i=1, #club.ranks, 1 do
			local rankLabel = (club.ranks[i].club_rank_label == '' and club.label or club.ranks[i].club_rank_label)

			table.insert(elements, {
				label = ('%s - <span style="color:green;">%s</span>'):format(rankLabel, _U('money_generic', ESX.Math.GroupDigits(club.ranks[i].pay))),
				value = club.ranks[i].club_rank
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'manage_pay_' .. clubname, {
			title    = _U('pay_management'),
			align    = 'top-right',
			elements = elements
		}, function(data, menu)

			ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'manage_pay_amount_' .. clubname, {
				title = _U('pay_amount')
			}, function(data2, menu2)

				local amount = tonumber(data2.value)

				if amount == nil then
					ESX.ShowNotification(_U('invalid_amount'))
				else
					menu2.close()

					ESX.TriggerServerCallback('sody_clubs:setClubPay', function()
						OpenManageGradesMenu(clubname)
					end, clubname, data.current.value, amount)
				end

			end, function(data2, menu2)
				menu2.close()
			end)

		end, function(data, menu)
			menu.close()
		end)

	end, clubname)

end

function playerZones()
	Citizen.CreateThread(function()
		while hasClub do
			local letSleep = true
			Citizen.Wait(1)

			if ESX.Table.SizeOf(zones) > 0 then
				local coords = GetEntityCoords(PlayerPedId())
				local currentZone = nil
				local zone        = nil
				local lastZone    = nil

				for k,v in pairs(zones) do
					if GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < v.Size.x+0.5 then
						if k == 'Owner' and (PlayerRank == 'owner' or PlayerRank == 'treasurer') then
							isInMarker  = true
							currentZone = k
							zone        = v
							letSleep = false
							break
						elseif k ~= 'Owner' then
							isInMarker  = true
							currentZone = k
							zone        = v
							letSleep = false
							break
						end
					else
						isInMarker  = false
					end
				end

				if IsControlJustReleased(0, 38) and isInMarker then
					TriggerEvent('sody_clubs:action', zone)
					menuIsShowed = true
					Citizen.Wait(2000)
				end

				if isInMarker and not menuIsShowed then
					hintIsShowed = true
					hintToDisplay = zone.Hint
				end

				if isInMarker and not hasAlreadyEnteredMarker then
					hasAlreadyEnteredMarker = true
				end

				if not isInMarker and hasAlreadyEnteredMarker then
					hasAlreadyEnteredMarker = false
					TriggerEvent('sody_clubs:hasExitedMarker')
				end

				if letSleep then
					Citizen.Wait(250)
				end
			end
		end
	end)
end

function displayClubMarkers(club)
	Citizen.CreateThread(function()
		while hasClub do
			Citizen.Wait(1)
			local coords = GetEntityCoords(PlayerPedId())
			local letSleep = true

			if ESX.Table.SizeOf(zones) > 0 then
				for k,v in pairs(zones) do
					if k ~= "Owner" then
						if(v.Marker ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
							DrawMarker(v.Marker, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
							letSleep = false
						end
					end

					if k == "Owner" and (PlayerRank == 'owner' or PlayerRank == 'treasurer') then
						if(v.Marker ~= -1 and GetDistanceBetweenCoords(coords, v.Pos.x, v.Pos.y, v.Pos.z, true) < Config.DrawDistance) then
							DrawMarker(v.Marker, v.Pos.x, v.Pos.y, v.Pos.z, 0.0, 0.0, 0.0, 0, 0.0, 0.0, v.Size.x, v.Size.y, v.Size.z, v.Color.r, v.Color.g, v.Color.b, 100, false, true, 2, false, false, false, false)
							letSleep = false
						end
					end
				end
			end

			if letSleep then
				Citizen.Wait(1000)
			end
		end
	end)
end

function OpenGetStocksMenu()
	ESX.TriggerServerCallback('sody_clubs:getStockItems', function(inventory)
		local elements = {}
		local menutitle = PlayerClub .. "menu"

		if inventory.blackMoney > 0 then
			table.insert(elements, {
				label = _U('dirty_money', ESX.Math.GroupDigits(inventory.blackMoney)),
				type = 'item_account',
				value = 'black_money'
			})
		end

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type = 'item_standard',
					value = item.name
				})
			end
		end

		for i=1, #inventory.weapons, 1 do
			local weapon = inventory.weapons[i]

			table.insert(elements, {
				label = ESX.GetWeaponLabel(weapon.name) .. ' [' .. weapon.ammo .. ']',
				type  = 'item_weapon',
				value = weapon.name,
				ammo  = weapon.ammo
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title    = _U(menutitle),
			align    = 'top-right',
			elements = elements
		}, function(data, menu)

			if data.current.type == 'item_weapon' then
				menu.close()

				TriggerServerEvent('sody_clubs:getStockItem', data.current.type, data.current.value, data.current.ammo, PlayerClub)
				ESX.SetTimeout(300, function()
					OpenGetStocksMenu()
				end)
			else

				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
					title = _U('quantity')
				}, function(data2, menu2)
					local count = tonumber(data2.value)

					if count == nil then
						ESX.ShowNotification(_U('invalid_quantity'))
					else
						menu2.close()
						menu.close()
						TriggerServerEvent('sody_clubs:getStockItem', data.current.type, data.current.value, count, PlayerClub)

						Citizen.Wait(500)
						OpenGetStocksMenu()
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			end
		end, function(data, menu)
			menu.close()
		end)
	end, PlayerClub)
end

function OpenGetStocksMenuPub()
	ESX.TriggerServerCallback('sody_clubs:getStockItemsPub', function(inventory)
		local elements = {}
		local menutitle = PlayerClub .. "menu"

		if inventory.blackMoney > 0 then
			table.insert(elements, {
				label = _U('dirty_money', ESX.Math.GroupDigits(inventory.blackMoney)),
				type = 'item_account',
				value = 'black_money'
			})
		end

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type = 'item_standard',
					value = item.name
				})
			end
		end

		for i=1, #inventory.weapons, 1 do
			local weapon = inventory.weapons[i]

			table.insert(elements, {
				label = ESX.GetWeaponLabel(weapon.name) .. ' [' .. weapon.ammo .. ']',
				type  = 'item_weapon',
				value = weapon.name,
				ammo  = weapon.ammo
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title    = _U(menutitle),
			align    = 'top-right',
			elements = elements
		}, function(data, menu)

			if data.current.type == 'item_weapon' then
				menu.close()

				TriggerServerEvent('sody_clubs:getStockItemPub', data.current.type, data.current.value, data.current.ammo, PlayerClub)
				ESX.SetTimeout(300, function()
					OpenGetStocksMenuPub()
				end)
			else

				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
					title = _U('quantity')
				}, function(data2, menu2)
					local count = tonumber(data2.value)

					if count == nil then
						ESX.ShowNotification(_U('invalid_quantity'))
					else
						menu2.close()
						menu.close()
						TriggerServerEvent('sody_clubs:getStockItemPub', data.current.type, data.current.value, count, PlayerClub)

						Citizen.Wait(500)
						OpenGetStocksMenuPub()
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			end
		end, function(data, menu)
			menu.close()
		end)
	end, PlayerClub)
end

function OpenGetStocksMenuPriv()
	ESX.TriggerServerCallback('sody_clubs:getStockItemsPriv', function(inventory)
		local elements = {}
		local menutitle = PlayerClub .. "menu"

		if inventory.blackMoney > 0 then
			table.insert(elements, {
				label = _U('dirty_money', ESX.Math.GroupDigits(inventory.blackMoney)),
				type = 'item_account',
				value = 'black_money'
			})
		end

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type = 'item_standard',
					value = item.name
				})
			end
		end

		for i=1, #inventory.weapons, 1 do
			local weapon = inventory.weapons[i]

			table.insert(elements, {
				label = ESX.GetWeaponLabel(weapon.name) .. ' [' .. weapon.ammo .. ']',
				type  = 'item_weapon',
				value = weapon.name,
				ammo  = weapon.ammo
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title    = _U(menutitle),
			align    = 'top-right',
			elements = elements
		}, function(data, menu)

			if data.current.type == 'item_weapon' then
				menu.close()

				TriggerServerEvent('sody_clubs:getStockItemPriv', data.current.type, data.current.value, data.current.ammo, PlayerClub)
				ESX.SetTimeout(300, function()
					OpenGetStocksMenuPriv()
				end)
			else

				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_get_item_count', {
					title = _U('quantity')
				}, function(data2, menu2)
					local count = tonumber(data2.value)

					if count == nil then
						ESX.ShowNotification(_U('invalid_quantity'))
					else
						menu2.close()
						menu.close()
						TriggerServerEvent('sody_clubs:getStockItemPriv', data.current.type, data.current.value, count, PlayerClub)

						Citizen.Wait(500)
						OpenGetStocksMenuPriv()
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			end
		end, function(data, menu)
			menu.close()
		end)
	end, PlayerClub)
end

function OpenPutStocksMenu()
	ESX.TriggerServerCallback('sody_clubs:getPlayerInventory', function(inventory)
		local elements = {}

		if inventory.blackMoney > 0 then
			table.insert(elements, {
				label = _U('dirty_money', ESX.Math.GroupDigits(inventory.blackMoney)),
				type  = 'item_account',
				value = 'black_money'
			})
		end

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type  = 'item_standard',
					value = item.name
				})
			end
		end

		for i=1, #inventory.weapons, 1 do
			local weapon = inventory.weapons[i]

			table.insert(elements, {
				label = weapon.label .. ' [' .. weapon.ammo .. ']',
				type  = 'item_weapon',
				value = weapon.name,
				ammo  = weapon.ammo
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title    = _U('inventory'),
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			if data.current.type == 'item_weapon' then
				menu.close()
				TriggerServerEvent('sody_clubs:putStockItems', data.current.type, data.current.value, data.current.ammo, PlayerClub)

				ESX.SetTimeout(300, function()
					OpenPutStocksMenu()
				end)
			else

				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
					title = _U('quantity')
				}, function(data2, menu2)
					local count = tonumber(data2.value)

					if count == nil then
						ESX.ShowNotification(_U('invalid_quantity'))
					else
						menu2.close()
						menu.close()
						TriggerServerEvent('sody_clubs:putStockItems', data.current.type, data.current.value, count, PlayerClub)

						Citizen.Wait(500)
						OpenPutStocksMenu()
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			end
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenPutStocksMenuPub()
	ESX.TriggerServerCallback('sody_clubs:getPlayerInventory', function(inventory)
		local elements = {}

		if inventory.blackMoney > 0 then
			table.insert(elements, {
				label = _U('dirty_money', ESX.Math.GroupDigits(inventory.blackMoney)),
				type  = 'item_account',
				value = 'black_money'
			})
		end

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type  = 'item_standard',
					value = item.name
				})
			end
		end

		for i=1, #inventory.weapons, 1 do
			local weapon = inventory.weapons[i]

			table.insert(elements, {
				label = weapon.label .. ' [' .. weapon.ammo .. ']',
				type  = 'item_weapon',
				value = weapon.name,
				ammo  = weapon.ammo
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title    = _U('inventory'),
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			if data.current.type == 'item_weapon' then
				menu.close()
				TriggerServerEvent('sody_clubs:putStockItemsPub', data.current.type, data.current.value, data.current.ammo, PlayerClub)

				ESX.SetTimeout(300, function()
					OpenPutStocksMenuPub()
				end)
			else

				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
					title = _U('quantity')
				}, function(data2, menu2)
					local count = tonumber(data2.value)

					if count == nil then
						ESX.ShowNotification(_U('invalid_quantity'))
					else
						menu2.close()
						menu.close()
						TriggerServerEvent('sody_clubs:putStockItemsPub', data.current.type, data.current.value, count, PlayerClub)

						Citizen.Wait(500)
						OpenPutStocksMenuPub()
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			end
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function OpenPutStocksMenuPriv()
	ESX.TriggerServerCallback('sody_clubs:getPlayerInventory', function(inventory)
		local elements = {}

		if inventory.blackMoney > 0 then
			table.insert(elements, {
				label = _U('dirty_money', ESX.Math.GroupDigits(inventory.blackMoney)),
				type  = 'item_account',
				value = 'black_money'
			})
		end

		for i=1, #inventory.items, 1 do
			local item = inventory.items[i]

			if item.count > 0 then
				table.insert(elements, {
					label = item.label .. ' x' .. item.count,
					type  = 'item_standard',
					value = item.name
				})
			end
		end

		for i=1, #inventory.weapons, 1 do
			local weapon = inventory.weapons[i]

			table.insert(elements, {
				label = weapon.label .. ' [' .. weapon.ammo .. ']',
				type  = 'item_weapon',
				value = weapon.name,
				ammo  = weapon.ammo
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'stocks_menu', {
			title    = _U('inventory'),
			align    = 'top-right',
			elements = elements
		}, function(data, menu)
			if data.current.type == 'item_weapon' then
				menu.close()
				TriggerServerEvent('sody_clubs:putStockItemsPriv', data.current.type, data.current.value, data.current.ammo, PlayerClub)

				ESX.SetTimeout(300, function()
					OpenPutStocksMenuPriv()
				end)
			else

				ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'stocks_menu_put_item_count', {
					title = _U('quantity')
				}, function(data2, menu2)
					local count = tonumber(data2.value)

					if count == nil then
						ESX.ShowNotification(_U('invalid_quantity'))
					else
						menu2.close()
						menu.close()
						TriggerServerEvent('sody_clubs:putStockItemsPriv', data.current.type, data.current.value, count, PlayerClub)

						Citizen.Wait(500)
						OpenPutStocksMenuPriv()
					end
				end, function(data2, menu2)
					menu2.close()
				end)
			end
		end, function(data, menu)
			menu.close()
		end)
	end)
end

function ClubGarages()
	Citizen.CreateThread(function()
		while hasClub do
			Citizen.Wait(0)

			local letSleep = true
			local coords = GetEntityCoords(PlayerPedId())
			local distance = GetDistanceBetweenCoords(coords, garage.x, garage.y, garage.z, true)

			if distance < Config.DrawDistance then
				DrawMarker(1, garage.x, garage.y, garage.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 1.0, 0, 171, 255, 100, false, true, 2, false, nil, nil, false)
				letSleep = false
			end

			if not isInMarker2 and distance < 2.0 then
				CurrentGarage = garage
				if IsPedInAnyVehicle(GetPlayerPed(-1), false) and GetPedInVehicleSeat(GetVehiclePedIsIn(GetPlayerPed(-1), false), -1) == GetPlayerPed(-1) then
					hintToDisplay = _U('delete')
					hintIsShowed = true
					TriggerEvent('sody_clubs:action', 'delete')
				else
					hintToDisplay = _U('spawn')
					hintIsShowed = true
					TriggerEvent('sody_clubs:action', 'spawn')
				end
				isInMarker2 = true
			end

			if isInMarker2 and distance > 2.0 then
				TriggerEvent('sody_clubs:hasExitedMarker')
				isInMarker2 = false
				CurrentGarage = false
			end

			if letSleep then
				Citizen.Wait(1000)
			end
		end
	end)
end

function OpenChangingRoomMenu()
	ESX.TriggerServerCallback('esx_property:getPlayerDressing', function(dressing)
		local elements = {}

		for i=1, #dressing, 1 do
			table.insert(elements, {
				label = dressing[i],
				value = i
			})
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_dressing',
		{
			title    = 'Changing Room',
			align    = 'top-right',
			elements = elements
		}, function(data2, menu2)

			TriggerEvent('skinchanger:getSkin', function(skin)
				ESX.TriggerServerCallback('esx_property:getPlayerOutfit', function(clothes)
					TriggerEvent('skinchanger:loadClothes', skin, clothes)
					TriggerEvent('esx_skin:setLastSkin', skin)

					TriggerEvent('skinchanger:getSkin', function(skin)
						TriggerServerEvent('esx_skin:save', skin)
					end)
				end, data2.current.value)
			end)

			end, function(data2, menu2)
				menu2.close()
		end)
	end)
end

function OpenMenuGarage(PointType)

	ESX.UI.Menu.CloseAll()

	local elements = {}

	if PointType == 'spawn' then
		table.insert(elements,{label = _U('list_vehicles'), value = 'list_vehicles'})
	end

	if PointType == 'delete' then
		table.insert(elements,{label = _U('stock_vehicle'), value = 'stock_vehicle'})
	end

	ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'garage_menu',
		{
			title    = "Club Garage",
			align    = 'top-right',
			elements = elements,
		},
		function(data, menu)

			menu.close()
			if(data.current.value == 'list_vehicles') then
				ListVehiclesMenu()
			end
			if(data.current.value == 'stock_vehicle') then
				StockVehicleMenu()
			end

		end,
		function(data, menu)
			menu.close()
			
		end
	)	
end

function ListVehiclesMenu()
	local elements = {}

	ESX.TriggerServerCallback('eden_garage:getVehicles', function(vehicles)

	Citizen.Wait(10)

 	for _,v in pairs(vehicles) do

        	local hashVehicule = GetDisplayNameFromVehicleModel(v.vehicle.model)
        	local vehicleName = nil
        	local teststring = tostring(ESX.Math.Trim(GetLabelText(hashVehicule)))
        	if string.find(teststring, "NULL") then
	        	vehicleName = hashVehicule
	        else
	        	vehicleName = GetLabelText(hashVehicule)
	        end
        	local labelvehicle

        	if v.state == "0" and v.job == "nojob" and v.impounded == 0 then
        		labelvehicle = _U('status_out_garage', v.plate, vehicleName)
        		table.insert(elements, {label = labelvehicle , value = v})
        	elseif v.state == "1" and v.job == "nojob" and v.impounded == 0 then
        		labelvehicle = _U('status_in_garage', v.plate, vehicleName)
        		table.insert(elements, {label = labelvehicle , value = v})
        	elseif v.job == "nojob" and v.impounded == 1 then
        		labelvehicle = _U('status_impounded', v.plate, vehicleName)
        		table.insert(elements, {label = labelvehicle , value = v})
        	end
        
   	 end

		ESX.UI.Menu.Open(
		'default', GetCurrentResourceName(), 'spawn_vehicle',
		{
			title    = "Club Garage",
			align    = 'top-right',
			elements = elements,
		},
		function(data, menu)
			if data.current.value.state == "1" and data.current.value.impounded == 0 then
				menu.close()
				SpawnVehicleClub(data.current.value.vehicle)
			elseif data.current.value.state == "0" and data.current.value.impounded == 0 then
				exports.pNotify:SendNotification({ text = _U('notif_car_outofgarage'), queue = "right", timeout = 3000, layout = "centerLeft" })
			elseif data.current.value.impounded == 1 then
				exports.pNotify:SendNotification({ text = _U('notif_car_impounded'), queue = "right", timeout = 3000, layout = "centerLeft" })
			end
		end,
		function(data, menu)
			menu.close()
		end
	)	
	end)
end

function StockVehicleMenu()
	local playerPed = GetPlayerPed(-1)

	if IsPedInAnyVehicle(playerPed,  false) then

		local playerPed = GetPlayerPed(-1)
    	local coords = GetEntityCoords(playerPed)
    	local vehicle = GetVehiclePedIsIn(playerPed,false)     
		local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
		local current = GetPlayersLastVehicle(GetPlayerPed(-1), true)
		local engineHealth = GetVehicleEngineHealth(current)

		ESX.TriggerServerCallback('eden_garage:stockv',function(valid)

			if (valid) then
				ESX.TriggerServerCallback('eden_garage:getVehicles', function(vehicules)
					local plate = vehicleProps.plate:gsub("^%s*(.-)%s*$", "%1")
					local owned = false
					for _,v in pairs(vehicules) do
						if plate == v.plate then
							owned = true
                            TriggerServerEvent('eden_garage:deletevehicle_sv', vehicleProps.plate)
						    TriggerServerEvent('eden_garage:modifystate', vehicleProps, true)

						    exports.pNotify:SendNotification({
						        text = _U('ranger'),
						        queue = 'right',
						        timeout = 400,
						        layout = 'centerLeft'
						    })
						end
					end
					if owned == false then
						exports.pNotify:SendNotification({ text = _U('stockv_not_owned'), queue = "right", timeout = 3000, layout = "centerLeft" })
					end
				end)
			else
				exports.pNotify:SendNotification({ text = _U('stockv_not_owned'), queue = "right", timeout = 3000, layout = "centerLeft" })
			end
		end,vehicleProps)
	else		
		exports.pNotify:SendNotification({ text = _U('stockv_not_in_veh'), queue = "right", timeout = 3000, layout = "centerLeft" })
	end

end

function SpawnVehicleClub(vehicle)
	ESX.Game.SpawnVehicle(vehicle.model,{
		x=CurrentGarage.x ,
		y=CurrentGarage.y,
		z=CurrentGarage.z + 1											
		},CurrentGarage.h, function(callback_vehicle)
		ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
			SetVehRadioStation(callback_vehicle, "OFF")
			SetVehicleHasBeenOwnedByPlayer(callback_vehicle, true)
			TaskWarpPedIntoVehicle(GetPlayerPed(-1), callback_vehicle, -1)
			SetVehicleEngineOn(callback_vehicle, true, true, true)
			Citizen.Wait(200)
		end)

	TriggerServerEvent('eden_garage:modifystate', vehicle, false, false)
end

function has_value (tab, val)
    for index, value in pairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function has_value_index (tab, val)
    for index, value in pairs(tab) do
        if index == val then
            return true
        end
    end

    return false
end