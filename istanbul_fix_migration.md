# MonsterBit smart contracts upgrade
The goal of the proposed upgrade is to fix Istanbul-related bug. The procedure includes redeployment of four contracts and multiple transactions to reinitialize the system. `CEO` participation is required.


## The bug
Istanbul hard fork broke the contracts' logic. Because of [EIP-1884](https://eips.ethereum.org/EIPS/eip-1884) `MonsterCore.withdrawDependentBalances()` function reverts, as `MonsterCore.fallback()` requires more than 2300 gas provided with standard `addr.transfer` call.
To address the issue we change the way `SaleClockAuction`, `SiringClockAuction`, `MonsterBattles`, and `MonsterFood` contracts send ether to `MonsterCore`, now we use `.call` 
```js
require(<MonsterCore address>.call.value(<ether to send>)());
```
`.call` provides enough gas so fallback function doesn't revert with `OutOfGas`, which allows the whole `MonsterCore.withdrawDependentBalances()` transaction to succeed.

## Upgrade procedure
How to perform manual upgrade of the contracts

Preparations:
* locate `MonsterCore` address
* locate `MonsterLib` address or deploy a new copy
* open Remix
* set Remix environment to `Injected Web3` provider
* open the code in Remix, so you can interact with already deployed `MonsterCore`
* open the code updated in Remix, so you can deploy `SaleClockAuction`, `SiringClockAuction`, `MonsterBattles`, and `MonsterFood`
* locate old auctions with `MonsterCore.saleAuction()` and `MonsterCore.siringAuction()`, use `*ClockAuction.ownerCut()` to get current fee value
* deploy `SaleClockAuction`, `SiringClockAuction`, `MonsterBattles`, and `MonsterFood`
    * they require `MonsterCore` address
    * two auctions require `comission` argument  
    * `MonsterBattles` requires `MonsterLib` address
* initialize contracts
    * `MonsterFood.setFeedingFee()` (default value is `5 finney == 5000000000000000 wei`)
    * `MonsterBattles`: setBackendAddress, setOneOnOneBet, setTeamfightBet
    * `*ClockAuction`: setBumpFee, 
* transfer ownership to the actual `CEO`
    * `MonsterBattles.transferOwnership()`
    * `*ClockAuction.transferOwnership()`
    * `MonsterFood.setOwner()`

Optionally, check that `CFO` is set and `MonsterCore.withdrawDependentBalances()` fails.

Some actions require `CEO` privileges:
* make sure you have unlocked Metamask with the address listed as `CEO` for `MonsterCore`
* `MonsterCore.pause()`, check it with `MonsterCore.paused()` call
* use `MonsterCore` functions `setSaleAuctionAddress`, `setSiringAuctionAddress`, `setBattlesAddress()`, and `setMonsterFoodAddress` to bind new versions of contracts
* check correctness with `saleAuction()`, `siringAuction()`, `battlesContract()`, and `monsterFood()`
* `MonsterCore.unpause()`, check it with `MonsterCore.paused()` call
* (optional) set new `CFO` address 

To make sure upgrade is successful, use `CFO` to call `MonsterCore.withdrawDependentBalances()`. 
It should succeed.