# sody_clubs
Player Clubs resource for FiveM > ESX

SodyFX presents: sody_clubs

A resource for FiveM and ESX. This resources adds an additional layer of society living, clubs! Clubs have a similar structure as ESX jobs. There is an owner who has access to the same basic Boss menu from society and can perform similar actions of the Boss menu. Clubs have multiple features as well and allow players to have day-jobs to go along with their club perks.

### Requirements
* ESX (the big one)
* skinchanger (club changing room)
* esx_skin (club changing room)
* esx_property (club changing room)
* esx_addonaccount (club bank)
* esx_datastore (club storage)
* esx_addoninventory (club storage)
* eden_garage / esx_drp_garage (vehicle garage)
* pNotify

### Clubs Features:
- Clubhouse storage (dirty money, items and weapons)
- Clubhouse changing room (accesses esx_property saved outfits)
- Private storage for definable ranks and above
- Clubhouse garage for vehicle spawning
- Automatic club payouts to members either out of club bank balance or generic payouts (similar to ESX Paychecks)

### Club Owner Functions:
- Add money to a "club bank" balance
- Add/promote/remove members
- Adjust member pay rates
    
### Club Treasurer Functions:
- Adding a rank named `treasurer` allows the person to deposit/withdraw club money as well as show current balance

## How to add people to club:

Use `/setclub PlayerId ClubName ClubRank` command as jobmaster/admin/superadmin or as club owner, recruit members via the Owner menu

## Installation:
 
- Import sody_clubs.sql into your database to add club and club ranks tables (includes LMC club example)
- Add additional clubs, club ranks, addon_account, addon_inventory and datastore (latter 3 need club_clubname, club_clubname_pub and club_clubname_priv names, see example) to database as needed. Adjust config.lua and add club position data as needed
- If using an IPL/instance, you can utilize the Teleporter and GarageTeleporter options in the config.lua for teleport circles
- Alter config.lua as needed for global options
- Add this in your server.cfg :

```
start sody_clubs
```
    
# The Thanks Yous:
- All developers of esx/fivem scripts for their knowledge and time!
- Special thanks to the developers of ESX, skinchanger, esx_skin, esx_society, esx_property, esx_addonaccount, esx_addoninventory, esx_datastore and eden_garage for allowing me to dip into your goodness and make something out of it
- Members of the Slick Top Gaming RP Community for their testing and tips (http://discord.slicktopgaming.com)

# ----- Working with esx_doorlocks -----
In order to use sody_clubs with esx_doorlocks, esx_doorlocks needs to be adjusted to receive club data. To do this, edit the following files or if you're using an unmodified esx_doorlocks, you can grab my fork here: https://github.com/SodyFX/esx_doorlock

# esx_doorlocks/server/main.lua:
Comment out Lines 25-28:
```
--if not IsAuthorized(xPlayer.job.name, Config.DoorList[doorID]) then
--	print(('esx_doorlock: %s was not authorized to open a locked door!'):format(xPlayer.identifier))
--	return
--end
```

This is done to avoid having to send club data to the server for every player. You can leave it in if you wish, but when club members try to open a door, it'll show in your server console, up to you.

# esx_doorlocks/client/main.lua:
Insert Line 2 - Add (after ESX = nil):
```
local PlayerClub, PlayerRankNum = nil, 0
```

Insert after line 21 (after esx_doorlock:getDoorInfo callback):
```
ESX.TriggerServerCallback('sody_clubs:getPlayerClub', function(playerdata)
	PlayerClub = playerdata.club
	PlayerRankNum = playerdata.club_rank
end)
```

Insert after Line 29 (after esx:setJob event)
```
RegisterNetEvent('sody_clubs:clubAdded')
AddEventHandler('sody_clubs:clubAdded', function(club)
	ESX.TriggerServerCallback('sody_clubs:getPlayerClub', function(playerdata)
		PlayerClub = playerdata.club
		PlayerRankNum = playerdata.club_rank
	end)
end)

RegisterNetEvent('sody_clubs:clubRemoved')
AddEventHandler('sody_clubs:clubRemoved', function()
	PlayerClub, PlayerRankNum = nil, 0
end)
```

Insert after Line 151 (inside IsAuthorized function, below job check but above return false
```
if doorID.authorizedClubs ~= nil then
	if PlayerClub ~= nil and PlayerRankNum ~= nil then
		for _,club in pairs(doorID.authorizedClubs) do
			if club == PlayerClub and doorID.authorizedClubRank[1] <= PlayerRankNum then
				return true
			end
		end
	end
end
```

# esx_doorlocks/config.lua:
Add a new door like any other for esx_doorlocks except add authorizedClubs and authorizedClubRank as well. authorizedClubs is the club name from sody_clubs config and authorizedClubRank is the minimum rank in the club required to use the door. Here's the LMC club example:
```
{
	objName = 'v_ilev_lostdoor',
	objCoords  = vector3(981.61, -102.57, 74.85),
	textCoords = vector3(981.72, -102.82, 75.85),
	authorizedJobs = {  },
	authorizedClubs = { 'lmc' },
	authorizedClubRank = { 0 },
	locked = true,
	distance = 12,
	size = 2
},
```
