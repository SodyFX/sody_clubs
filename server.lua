--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
-- Sody Clubs
-- v1.0.1 - 12/13/2019
-- By SodyFX with Love
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

nextReset = 0
local Clubs, ClubList, ClubListFull = {}, {}, {}

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

MySQL.ready(function()
--AddEventHandler('onResourceStart', function(resourceName) -- For debugging to start/stop resources without server restart
	Wait(5000) -- For debugging to start/stop resources without server restart
	local result = MySQL.Sync.fetchAll('SELECT * FROM sody_clubs', {})

	for i=1, #result, 1 do
		Clubs[result[i].name] = result[i]
		Clubs[result[i].name].ranks = {}
		table.insert(ClubList, result[i].name)
		ClubListFull[result[i].name] = result[i].label
	end

	local result2 = MySQL.Sync.fetchAll('SELECT * FROM sody_clubs_ranks', {})

	for i=1, #result2, 1 do
		Clubs[result2[i].club_name].ranks[tostring(result2[i].club_rank)] = result2[i]
	end

	TriggerClientEvent('sody_clubs:forceSync', -1)

	nextReset = GetGameTimer() + Config.PayInterval
	startClubPayCycle()
end)

function startClubPayCycle()
	while true do
		Wait(10000)

		if GetGameTimer() > nextReset then
			--print("Running Club Payouts")
			clubPay()
			nextReset = GetGameTimer() + Config.PayInterval
		end
	end
end

TriggerEvent('es:addGroupCommand', 'setclub', 'jobmaster', function(source, args, user)
	if tonumber(args[1]) and args[2] and tonumber(args[3]) then
		local _source, incclub, incrank = args[1], args[2], args[3]
		local xPlayer = ESX.GetPlayerFromId(args[1])

		if xPlayer then
			if has_value(ClubListFull, incclub) and incclub ~= "none" then
				if has_value(Clubs[incclub].ranks, incrank) then
					setClub(_source, xPlayer.identifier, incclub, incrank, 'hire')
				else
					TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'That club rank does not exist.' } })
				end
			elseif incclub == "none" then
				setClub(_source, xPlayer.identifier, incclub, 0, 'none')
			else
				TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'That club does not exist.' } })
			end

		else
			TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Player not online.' } })
		end
	else
		TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Invalid usage.' } })
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
end, {help = _U('setclub'), params = {{name = 'id', help = _U('id_param')}, {name = 'club', help = _U('setclub_param2')}, {name = 'rank_id', help = _U('setclub_param3')}}})


ESX.RegisterServerCallback('sody_clubs:getPlayerClub', function(source, cb)
	local _source = source
	local xPlayer = nil
	while xPlayer == nil do
		xPlayer = ESX.GetPlayerFromId(_source)
		Wait(10)
	end

	MySQL.Async.fetchAll('SELECT club, club_rank FROM users WHERE identifier=@identifier', {['@identifier'] = xPlayer.identifier}, function(result)
		if result[1].club then
			local playerrank = tostring(result[1].club_rank)
			local returntable = {
				club = result[1].club,
				club_rank = result[1].club_rank,
				club_rank_name = Clubs[result[1].club].ranks[playerrank].club_rank_name
			}
			cb(returntable)
		end
	end)
end)

ESX.RegisterServerCallback('sody_clubs:getStockItems', function(source, cb, clubname)
	local clubfullname =  "club_" .. clubname
	local blackMoney = 0
	local items      = {}
	local weapons    = {}

	TriggerEvent('esx_addonaccount:getSharedAccount', clubfullname .. '_black', function(account)
		blackMoney = account.money
	end)

	TriggerEvent('esx_datastore:getSharedDataStore', clubfullname, function(store)
		weapons = store.get('weapons')

		if weapons == nil then
			weapons = {}
		end
	end)

	TriggerEvent('esx_addoninventory:getSharedInventory', clubfullname, function(inventory)
		for i=1, #inventory.items, 1 do
			if inventory.items[i].count > 0 then
				table.insert(items, inventory.items[i])
			end
		end	
	end)

	cb({
		blackMoney = blackMoney,
		items      = items,
		weapons    = weapons
	})
end)

ESX.RegisterServerCallback('sody_clubs:getStockItemsPub', function(source, cb, clubname)
	local clubfullname =  "club_" .. clubname .. "_pub"
	local blackMoney = 0
	local items      = {}
	local weapons    = {}

	TriggerEvent('esx_addonaccount:getSharedAccount', clubfullname, function(account)
		blackMoney = account.money
	end)

	TriggerEvent('esx_datastore:getSharedDataStore', clubfullname, function(store)
		weapons = store.get('weapons')

		if weapons == nil then
			weapons = {}
		end
	end)

	TriggerEvent('esx_addoninventory:getSharedInventory', clubfullname, function(inventory)
		for i=1, #inventory.items, 1 do
			if inventory.items[i].count > 0 then
				table.insert(items, inventory.items[i])
			end
		end	
	end)

	cb({
		blackMoney = blackMoney,
		items      = items,
		weapons    = weapons
	})
end)

ESX.RegisterServerCallback('sody_clubs:getStockItemsPriv', function(source, cb, clubname)
	local clubfullname =  "club_" .. clubname .. "_priv"
	local blackMoney = 0
	local items      = {}
	local weapons    = {}

	TriggerEvent('esx_addonaccount:getSharedAccount', clubfullname, function(account)
		blackMoney = account.money
	end)

	TriggerEvent('esx_datastore:getSharedDataStore', clubfullname, function(store)
		weapons = store.get('weapons')

		if weapons == nil then
			weapons = {}
		end
	end)

	TriggerEvent('esx_addoninventory:getSharedInventory', clubfullname, function(inventory)
		for i=1, #inventory.items, 1 do
			if inventory.items[i].count > 0 then
				table.insert(items, inventory.items[i])
			end
		end	
	end)

	cb({
		blackMoney = blackMoney,
		items      = items,
		weapons    = weapons
	})
end)

RegisterServerEvent('sody_clubs:getClubList')
AddEventHandler('sody_clubs:getClubList', function()
	TriggerClientEvent('sody_clubs:setClubList', source, ClubList, ClubListFull)
end)

RegisterServerEvent('sody_clubs:getStockItem')
AddEventHandler('sody_clubs:getStockItem', function(type, itemName, count, clubname)
	local _source = source
	local xPlayer = nil
	while xPlayer == nil do
		xPlayer = ESX.GetPlayerFromId(_source)
		Wait(10)
	end
	local clubfullname =  "club_" .. clubname

	if type == 'item_standard' then

		local sourceItem = xPlayer.getInventoryItem(item)

		TriggerEvent('esx_addoninventory:getSharedInventory', clubfullname, function(inventory)
			local item = inventory.getItem(itemName)
			local sourceItem = xPlayer.getInventoryItem(itemName)

			if count > 0 and item.count >= count then

				if sourceItem.limit ~= -1 and (sourceItem.count + count) > sourceItem.limit then
					TriggerClientEvent('esx:showNotification', xPlayer.source, _U('player_cannot_hold'))
				else
					inventory.removeItem(itemName, count)
					xPlayer.addInventoryItem(itemName, count)
					TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_withdrawn', count, item.label))
				end
			else
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_quantity'))
			end
		end)

	elseif type == 'item_account' then

		TriggerEvent('esx_addonaccount:getSharedAccount', clubfullname .. "_black", function(account)
			local AccountMoney = account.money

			if AccountMoney >= count then
				account.removeMoney(count)
				xPlayer.addAccountMoney(itemName, count)
			else
				TriggerClientEvent('esx:showNotification', _source, _U('amount_invalid'))
			end
		end)

	elseif type == 'item_weapon' then

		TriggerEvent('esx_datastore:getSharedDataStore', clubfullname, function(store)
			local storeWeapons = store.get('weapons') or {}
			local weaponName   = nil
			local ammo         = nil

			for i=1, #storeWeapons, 1 do
				if storeWeapons[i].name == itemName then
					weaponName = storeWeapons[i].name
					ammo       = storeWeapons[i].ammo

					table.remove(storeWeapons, i)
					break
				end
			end

			store.set('weapons', storeWeapons)
			xPlayer.addWeapon(weaponName, ammo)
		end)

	end
end)

RegisterServerEvent('sody_clubs:getStockItemPub')
AddEventHandler('sody_clubs:getStockItemPub', function(type, itemName, count, clubname)
	local _source = source
	local xPlayer = nil
	while xPlayer == nil do
		xPlayer = ESX.GetPlayerFromId(_source)
		Wait(10)
	end
	local clubfullname =  "club_" .. clubname .. "_pub"

	if type == 'item_standard' then

		local sourceItem = xPlayer.getInventoryItem(item)

		TriggerEvent('esx_addoninventory:getSharedInventory', clubfullname, function(inventory)
			local item = inventory.getItem(itemName)
			local sourceItem = xPlayer.getInventoryItem(itemName)

			if count > 0 and item.count >= count then

				if sourceItem.limit ~= -1 and (sourceItem.count + count) > sourceItem.limit then
					TriggerClientEvent('esx:showNotification', xPlayer.source, _U('player_cannot_hold'))
				else
					inventory.removeItem(itemName, count)
					xPlayer.addInventoryItem(itemName, count)
					TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_withdrawn', count, item.label))
				end
			else
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_quantity'))
			end
		end)

	elseif type == 'item_account' then

		TriggerEvent('esx_addonaccount:getSharedAccount', clubfullname, function(account)
			local AccountMoney = account.money

			if AccountMoney >= count then
				account.removeMoney(count)
				xPlayer.addAccountMoney(itemName, count)
			else
				TriggerClientEvent('esx:showNotification', _source, _U('amount_invalid'))
			end
		end)

	elseif type == 'item_weapon' then

		TriggerEvent('esx_datastore:getSharedDataStore', clubfullname, function(store)
			local storeWeapons = store.get('weapons') or {}
			local weaponName   = nil
			local ammo         = nil

			for i=1, #storeWeapons, 1 do
				if storeWeapons[i].name == itemName then
					weaponName = storeWeapons[i].name
					ammo       = storeWeapons[i].ammo

					table.remove(storeWeapons, i)
					break
				end
			end

			store.set('weapons', storeWeapons)
			xPlayer.addWeapon(weaponName, ammo)
		end)

	end
end)

RegisterServerEvent('sody_clubs:getStockItemPriv')
AddEventHandler('sody_clubs:getStockItemPriv', function(type, itemName, count, clubname)
	local _source = source
	local xPlayer = nil
	while xPlayer == nil do
		xPlayer = ESX.GetPlayerFromId(_source)
		Wait(10)
	end
	local clubfullname =  "club_" .. clubname .. "_priv"

	if type == 'item_standard' then

		local sourceItem = xPlayer.getInventoryItem(item)

		TriggerEvent('esx_addoninventory:getSharedInventory', clubfullname, function(inventory)
			local item = inventory.getItem(itemName)
			local sourceItem = xPlayer.getInventoryItem(itemName)

			if count > 0 and item.count >= count then

				if sourceItem.limit ~= -1 and (sourceItem.count + count) > sourceItem.limit then
					TriggerClientEvent('esx:showNotification', xPlayer.source, _U('player_cannot_hold'))
				else
					inventory.removeItem(itemName, count)
					xPlayer.addInventoryItem(itemName, count)
					TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_withdrawn', count, item.label))
				end
			else
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_quantity'))
			end
		end)

	elseif type == 'item_account' then

		TriggerEvent('esx_addonaccount:getSharedAccount', clubfullname, function(account)
			local AccountMoney = account.money

			if AccountMoney >= count then
				account.removeMoney(count)
				xPlayer.addAccountMoney(itemName, count)
			else
				TriggerClientEvent('esx:showNotification', _source, _U('amount_invalid'))
			end
		end)

	elseif type == 'item_weapon' then

		TriggerEvent('esx_datastore:getSharedDataStore', clubfullname, function(store)
			local storeWeapons = store.get('weapons') or {}
			local weaponName   = nil
			local ammo         = nil

			for i=1, #storeWeapons, 1 do
				if storeWeapons[i].name == itemName then
					weaponName = storeWeapons[i].name
					ammo       = storeWeapons[i].ammo

					table.remove(storeWeapons, i)
					break
				end
			end

			store.set('weapons', storeWeapons)
			xPlayer.addWeapon(weaponName, ammo)
		end)

	end
end)

RegisterServerEvent('sody_clubs:putStockItems')
AddEventHandler('sody_clubs:putStockItems', function(type, itemName, count, clubname)
	local xPlayer = nil
	while xPlayer == nil do
		xPlayer = ESX.GetPlayerFromId(source)
		Wait(10)
	end
	local clubfullname =  "club_" .. clubname

	if type == 'item_standard' then

		local playerItemCount = xPlayer.getInventoryItem(itemName).count

		TriggerEvent('esx_addoninventory:getSharedInventory', clubfullname, function(inventory)
			local item = inventory.getItem(itemName)
			local playerItemCount = xPlayer.getInventoryItem(itemName).count

			if item.count >= 0 and count <= playerItemCount then
				xPlayer.removeInventoryItem(itemName, count)
				inventory.addItem(itemName, count)
			else
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_quantity'))
			end

			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_deposited', count, item.label))
		end)

	elseif type == 'item_account' then

		local playerAccountMoney = xPlayer.getAccount(itemName).money

		if playerAccountMoney >= count and count > 0 then
			xPlayer.removeAccountMoney(itemName, count)

			TriggerEvent('esx_addonaccount:getSharedAccount', clubfullname .. "_black", function(account)
				account.addMoney(count)
			end)
		else
			TriggerClientEvent('esx:showNotification', _source, _U('amount_invalid'))
		end

	elseif type == 'item_weapon' then

		TriggerEvent('esx_datastore:getSharedDataStore', clubfullname, function(store)
			local storeWeapons = store.get('weapons') or {}

			table.insert(storeWeapons, {
				name = itemName,
				ammo = count
			})

			store.set('weapons', storeWeapons)
			xPlayer.removeWeapon(itemName)
		end)

	end
end)

RegisterServerEvent('sody_clubs:putStockItemsPub')
AddEventHandler('sody_clubs:putStockItemsPub', function(type, itemName, count, clubname)
	local xPlayer = nil
	while xPlayer == nil do
		xPlayer = ESX.GetPlayerFromId(source)
		Wait(10)
	end
	local clubfullname =  "club_" .. clubname .. "_pub"

	if type == 'item_standard' then

		local playerItemCount = xPlayer.getInventoryItem(itemName).count

		TriggerEvent('esx_addoninventory:getSharedInventory', clubfullname, function(inventory)
			local item = inventory.getItem(itemName)
			local playerItemCount = xPlayer.getInventoryItem(itemName).count

			if item.count >= 0 and count <= playerItemCount then
				xPlayer.removeInventoryItem(itemName, count)
				inventory.addItem(itemName, count)
			else
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_quantity'))
			end

			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_deposited', count, item.label))
		end)

	elseif type == 'item_account' then

		local playerAccountMoney = xPlayer.getAccount(itemName).money

		if playerAccountMoney >= count and count > 0 then
			xPlayer.removeAccountMoney(itemName, count)

			TriggerEvent('esx_addonaccount:getSharedAccount', clubfullname, function(account)
				account.addMoney(count)
			end)
		else
			TriggerClientEvent('esx:showNotification', _source, _U('amount_invalid'))
		end

	elseif type == 'item_weapon' then

		TriggerEvent('esx_datastore:getSharedDataStore', clubfullname, function(store)
			local storeWeapons = store.get('weapons') or {}

			table.insert(storeWeapons, {
				name = itemName,
				ammo = count
			})

			store.set('weapons', storeWeapons)
			xPlayer.removeWeapon(itemName)
		end)

	end
end)

RegisterServerEvent('sody_clubs:putStockItemsPriv')
AddEventHandler('sody_clubs:putStockItemsPriv', function(type, itemName, count, clubname)
	local xPlayer = nil
	while xPlayer == nil do
		xPlayer = ESX.GetPlayerFromId(source)
		Wait(10)
	end
	local clubfullname =  "club_" .. clubname .. "_priv"

	if type == 'item_standard' then

		local playerItemCount = xPlayer.getInventoryItem(itemName).count

		TriggerEvent('esx_addoninventory:getSharedInventory', clubfullname, function(inventory)
			local item = inventory.getItem(itemName)
			local playerItemCount = xPlayer.getInventoryItem(itemName).count

			if item.count >= 0 and count <= playerItemCount then
				xPlayer.removeInventoryItem(itemName, count)
				inventory.addItem(itemName, count)
			else
				TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_quantity'))
			end

			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_deposited', count, item.label))
		end)

	elseif type == 'item_account' then

		local playerAccountMoney = xPlayer.getAccount(itemName).money

		if playerAccountMoney >= count and count > 0 then
			xPlayer.removeAccountMoney(itemName, count)

			TriggerEvent('esx_addonaccount:getSharedAccount', clubfullname, function(account)
				account.addMoney(count)
			end)
		else
			TriggerClientEvent('esx:showNotification', _source, _U('amount_invalid'))
		end

	elseif type == 'item_weapon' then

		TriggerEvent('esx_datastore:getSharedDataStore', clubfullname, function(store)
			local storeWeapons = store.get('weapons') or {}

			table.insert(storeWeapons, {
				name = itemName,
				ammo = count
			})

			store.set('weapons', storeWeapons)
			xPlayer.removeWeapon(itemName)
		end)

	end
end)

ESX.RegisterServerCallback('sody_clubs:getPlayerInventory', function(source, cb)
	local xPlayer = nil
	while xPlayer == nil do
		xPlayer = ESX.GetPlayerFromId(source)
		Wait(10)
	end
	local blackMoney = xPlayer.getAccount('black_money').money
	local items      = xPlayer.inventory

	cb({
		blackMoney = blackMoney,
		items      = items,
		weapons    = xPlayer.getLoadout()
	})
end)

ESX.RegisterServerCallback('sody_clubs:getOwner', function(source, cb, club)
	local hasOwner = -1
	for v,k in pairs(Clubs[club].ranks) do
		if Clubs[club].ranks[v].club_rank_name == 'owner' then
			hasOwner = v
		end
	end

	cb(hasOwner)
end)

ESX.RegisterServerCallback('sody_clubs:getTreasurer', function(source, cb, club)
	local hasTreasurer = -1
	for v,k in pairs(Clubs[club].ranks) do
		if Clubs[club].ranks[v].club_rank_name == 'treasurer' then
			hasTreasurer = v
		end
	end

	cb(hasTreasurer)
end)

RegisterServerEvent('sody_clubs:bankBalance')
AddEventHandler('sody_clubs:bankBalance', function(club)
	local _source = source
	local bankname = "club_" .. club .. "_bank"
	TriggerEvent('esx_addonaccount:getSharedAccount', bankname, function(account)
		TriggerClientEvent('esx:showNotification', _source, 'Account balance: ~g~$' .. account.money)
	end)
end)

RegisterServerEvent('sody_clubs:withdrawBank')
AddEventHandler('sody_clubs:withdrawBank', function(club, amount)
	local xPlayer = nil
	while xPlayer == nil do
		xPlayer = ESX.GetPlayerFromId(source)
		Wait(10)
	end
	amount = ESX.Math.Round(tonumber(amount))

	local bankname = "club_" .. club .. "_bank"

	TriggerEvent('esx_addonaccount:getSharedAccount', bankname, function(account)
		if amount > 0 and account.money >= amount then
			account.removeMoney(amount)
			xPlayer.addMoney(amount)

			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_withdrawn', ESX.Math.GroupDigits(amount)))
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_amount'))
		end
	end)
end)

RegisterServerEvent('sody_clubs:depositBank')
AddEventHandler('sody_clubs:depositBank', function(club, amount)
	local xPlayer = nil
	while xPlayer == nil do
		xPlayer = ESX.GetPlayerFromId(source)
		Wait(10)
	end
	amount = ESX.Math.Round(tonumber(amount))

	local bankname = "club_" .. club .. "_bank"

	if amount > 0 and xPlayer.getMoney() >= amount then
		TriggerEvent('esx_addonaccount:getSharedAccount', bankname, function(account)
			xPlayer.removeMoney(amount)
			account.addMoney(amount)
		end)

		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('have_deposited', ESX.Math.GroupDigits(amount)))
	else
		TriggerClientEvent('esx:showNotification', xPlayer.source, _U('invalid_amount'))
	end
end)

ESX.RegisterServerCallback('sody_clubs:getClub', function(source, cb, clubname)
	local club = json.decode(json.encode(Clubs[clubname]))
	local ranks = {}

	for k,v in pairs(club.ranks) do
		table.insert(ranks, v)
	end

	table.sort(ranks, function(a, b)
		return a.club_rank < b.club_rank
	end)

	club.ranks = ranks

	cb(club)
end)

ESX.RegisterServerCallback('sody_clubs:setClub', function(source, cb, identifier, club, rank, type)
	cb(setClub(source, identifier, club, rank, type))
end)

function setClub(sourceplayer, identifier, club, rank, type)

	local club = club
	local rank = rank
	local identifier = identifier
	local xPlayer, xTarget = nil, nil
	while xPlayer == nil do
		xPlayer = ESX.GetPlayerFromId(sourceplayer)
		Wait(10)
	end

	xTarget = ESX.GetPlayerFromIdentifier(identifier)

	if club == "none" then
		club = nil
		rank = nil
	end

	MySQL.Async.execute('UPDATE users SET club = @club, club_rank = @club_rank WHERE identifier = @identifier', {
		['@club'] = club,
		['@club_rank'] = rank,
		['@identifier'] = identifier
	}, function(rowsChanged)

		if rowsChanged then
			if type == 'hire' then
				if xTarget then
					TriggerClientEvent('esx:showNotification', xTarget.source, _U('you_have_been_hired', ClubListFull[club]))
					TriggerClientEvent('sody_clubs:clubAdded', xTarget.source, club, rank, Clubs[club].ranks[tostring(rank)].club_rank_name)
				end
			elseif type == 'promote' then
				if xTarget then
					TriggerClientEvent('esx:showNotification', xTarget.source, _U('you_have_been_promoted'))
					TriggerClientEvent('sody_clubs:clubPromoted', xTarget.source, rank, Clubs[club].ranks[tostring(rank)].club_rank_name)
				end
			elseif type == 'remove' then
				if xTarget then
					TriggerClientEvent('esx:showNotification', xTarget.source, _U('you_have_been_fired', ClubListFull[club]))
					TriggerClientEvent('sody_clubs:clubRemoved', xTarget.source)
				end
			elseif type == 'none' then
				if xTarget then
					TriggerClientEvent('sody_clubs:clubRemoved', xTarget.source)
				end
			end
		else
			TriggerClientEvent('esx:showNotification', xPlayer.source, 'Club: System Error')
		end
		
	end)

end

ESX.RegisterServerCallback('sody_clubs:getMembers', function(source, cb, club)
	if Config.EnableESXIdentity then

		MySQL.Async.fetchAll('SELECT firstname, lastname, identifier, club, club_rank FROM users WHERE club = @club ORDER BY club_rank DESC', {
			['@club'] = club,
		}, function (results)
			local members = {}

			for i=1, #results, 1 do
				table.insert(members, {
					name       = results[i].firstname .. ' ' .. results[i].lastname,
					identifier = results[i].identifier,
					club = {
						name        = results[i].club,
						label       = Clubs[results[i].club].label,
						rank       = results[i].club_rank,
						rank_name  = Clubs[results[i].club].ranks[tostring(results[i].club_rank)].club_rank_name,
						rank_label = Clubs[results[i].club].ranks[tostring(results[i].club_rank)].club_rank_label
					}
				})
			end

			cb(members, club)
		end)
	else
		MySQL.Async.fetchAll('SELECT name, identifier, club, club_rank FROM users WHERE club = @club ORDER BY club_rank DESC', {
			['@club'] = club
		}, function (result)
			local members = {}

			for i=1, #result, 1 do
				table.insert(members, {
					name       = result[i].name,
					identifier = result[i].identifier,
					club = {
						name        = result[i].club,
						label       = Clubs[result[i].club].label,
						rank       = result[i].club_rank,
						rank_name  = Clubs[result[i].club].ranks[tostring(result[i].club_rank)].club_rank_name,
						rank_label = Clubs[result[i].club].ranks[tostring(result[i].club_rank)].club_rank_label
					}
				})
			end

			cb(members, club)
		end)
	end
end)

ESX.RegisterServerCallback('sody_clubs:setClubPay', function(source, cb, club, rank, pay)
	if pay == 1 then
		pay = 0
	end
	MySQL.Async.execute('UPDATE sody_clubs_ranks SET pay = @pay WHERE club_name = @club AND club_rank = @rank', {
		['@pay'] = pay,
		['@club'] = club,
		['@rank'] = rank
	}, function(rowsChanged)
		Clubs[club].ranks[tostring(rank)].pay = pay
		cb()
	end)
end)

ESX.RegisterServerCallback('sody_clubs:getOnlinePlayers', function(source, cb)
	local xPlayers = ESX.GetPlayers()
	local players  = {}

	for i=1, #xPlayers, 1 do
		local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
		table.insert(players, {
			source     = xPlayer.source,
			identifier = xPlayer.identifier,
			name       = xPlayer.name,
			job        = xPlayer.job
		})
	end

	cb(players)
end)

function has_value_index (tab, val)
    for index, value in pairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

function has_value (tab, val)
    for index, value in pairs(tab) do
        if index == val then
            return true
        end
    end

    return false
end

function clubPay()
	local clubMembers = {}

	MySQL.Async.fetchAll('SELECT firstname, lastname, identifier, club, club_rank FROM users WHERE club IS NOT NULL ORDER BY club_rank DESC', {}, function(results)
		local xPlayers = ESX.GetPlayers()
		local xPlayersChecks = {}
		for i=1, #xPlayers, 1 do
			local xPlayerCheck = ESX.GetPlayerFromId(xPlayers[i])
			table.insert(xPlayersChecks, xPlayerCheck.identifier)
		end

		if ESX.Table.SizeOf(results) > 0 then
			for v,k in pairs(results) do
				if has_value_index(xPlayersChecks, k.identifier) then
					table.insert(clubMembers, {
					name       = k.firstname .. ' ' .. k.lastname,
					identifier = k.identifier,
					club = {
						name        = k.club,
						label       = Clubs[k.club].label,
						rank       = k.club_rank,
						rank_name  = Clubs[k.club].ranks[tostring(k.club_rank)].club_rank_name,
						rank_label = Clubs[k.club].ranks[tostring(k.club_rank)].club_rank_label
					}
					})
				end
			end
		end

		for _,k in pairs(clubMembers) do
			local xPlayer = ESX.GetPlayerFromIdentifier(k.identifier)
			local club = k.club.name
			local rank = k.club.rank
			local pay = Clubs[club].ranks[tostring(rank)].pay
			if xPlayer then
				if pay > 0 then
					if Config.EnableClubBankPay then
						local bankname = "club_" .. club .. "_bank"
						TriggerEvent('esx_addonaccount:getSharedAccount', bankname, function (account)
							if account.money >= pay then
								xPlayer.addAccountMoney('bank', pay)
								account.removeMoney(pay)
								TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, ClubListFull[club], _U('received_paycheck'), _U('received_pay', pay), 'CHAR_MP_DETONATEPHONE', 9)
							else
								TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, ClubListFull[club], '', _U('company_nomoney'), 'CHAR_MP_DETONATEPHONE', 1)
								end
						end)
					else
						xPlayer.addAccountMoney('bank', pay)
						TriggerClientEvent('esx:showAdvancedNotification', xPlayer.source, ClubListFull[club], _U('received_paycheck'), _U('received_pay', pay), 'CHAR_MP_DETONATEPHONE', 9)
					end
				end
			end
		end
	end)
end
