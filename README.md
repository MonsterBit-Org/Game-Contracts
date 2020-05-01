# MonsterBit
Some info about project

## Contracts
Important contracts and their inheritance structure

### MonsterCore
* AccessControl
* MonsterBase is AccessControl
* ERC721Metadata
* MonsterOwnership is MonsterBase, ERC721
* MonsterAuction(SaleClockAuction address) is MonsterOwnership
* MonsterMinting is MonsterAuction
* MonsterCore is MonsterMinting


### MonsterBitSaleAuction
* ClockAuctionBase
* ClockAuction is Pausable, ClockAuctionBase
* SaleClockAuction is ClockAuction

## Test
To test contracts
* install dependencies `npm i`
* run ganache `./node_modules/.bin/ganache-cli`
* run tests `./node_modules/.bin/truffle test` 

## Deploy
To deploy contracts 
* install dependencies `npm i`
* edit `.env` file - provide keys and addresses
* run `./node_modules/.bin/truffle deploy --network <networkName>`

It will deploy and correctly initialize all the contracts.

## Verify 
To verify source code of contracts on [Etherescan](https://etherscan.io/) run `./node_modules/.bin/truffle run verify <SomeContract> <AnotherCOntract> --network <networkName>`. It requires valid Etherescan API key in `.env` file. It allows to verify several contracts at once.
