# **ScubaLoot - Scuba Cops Approved Loot Council Addon**<br/>

![alt text](https://i.imgur.com/qCzm91p.png)

**IMPORTANT - if your guild wants to use this addon read below**<br/>
First each attending raid member of officer rank or above will need to download this addon<br/>

The name of the officer ranks and the number of people who need to click the <br/>
Finished button before rewarding the item have to be hard coded. In order to use<br/>
this addon officers will have to open ScubaLoot.lua and edit **lines 7 through 10**<br/>

**Base Commands:**
* /sl toggle - toggles the interface display
* /sl showqueue - shows the queue and current item being voted on
* /sl showofficers - shows the current list of voters
* /sl showvotes - shows who is currently voting for who

**Usage:<br/>**
A loot session will open when an item is raidwarning'd. Multiple items can be raidwarning'd
and will be added to a queue. Members will link their items in raid chat, they can include a
small note (about 10 characters) and up to two item links. Officers can then vote and when done click the Finished
checkbox. When the amount of officers is equal or greater than the voting
threshold(specified in ScubaLoot.lua) the item winner(s) will be displayed in officer chat. Then it will
move on to the next item in the queue or if the queue is empty the interface will close.

**Notes:**
* This addon also works as a clean display of the items being linked for non officers
* Only the raid leader can skip the current item
* Only items raidwarning'd with "link" in the message will get added to the que
* This addon **WILL NOT** automatically masterloot the item, only announce the winner
* This addon keeps your votes private from non officers by using officer chat

This addon was made by Kaymon(Alliance) for the Northdale private server. If you find 
bugs or other issues message him in game.