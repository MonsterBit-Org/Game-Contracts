# Stuck monster withdrawal
Recently the MonsterBit contracts were upgraded to apply a fix to a bug introduced by the Ethereum hardfork. However, some monsters might have become stuck in previous version of either Auctions or Battles contract. Right now these monsters are unavailable for most actions. 

## Withdrawal from Auctions
If the monster is stuck in either Sale or Breeding auction, the monster's owner can free it with the following steps:
1. Get the `monster_id` of the particular monster, which is the monster's number in the system: 
    * go to the MonsterBit [site](monsterbit.org)
    * open the monster's page and check the link, it should be like `monsterbit.org/monster/1719`
    * `1719` is the monster's number.
2. Create a transaction to Ethereum to withdraw the monster:
    * open the browser and unlock Metamask
    * select `mainnet` and the address which owns the monster
    * open old Auction's page on Etherscan: [Sale](https://etherscan.io/address/0x29b3Dcbf02aA6156009A1bA374fAFcc6819cc540#writeContract) or [Breeding](https://etherscan.io/address/0x68b73C05Bd78Aa11A383CF34acDeFa4FBe190799#writeContract)
    * find the text `Write Contract Connect to Web3` and press `Connect to Web3`
    * approve and connect Etherscan to Metamask
    * scroll down to the block `10. cancelAuction`, put there montster's number (`1719` in this example)
    * press `Write` and approve the transaction with Metamask
    * after the transaction is mined monster will become fully functional

## Withdrawal from Battles
Extra help from the project is required.