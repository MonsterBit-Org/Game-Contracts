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
* run ganache `npx ganache-cli`
* run tests `npx truffle test` 

## Coverage
To check test coverage 
* install dependencies `npm i`
* run coverage `npx truffle run coverage --network development`
* enjoy report at `./coverage/index.html`

## Deploy
To deploy contracts 
* install dependencies `npm i`
* edit `.env` file - provide keys and addresses
* run `npx truffle deploy --network <networkName>`

It will deploy and correctly initialize all the contracts.

## Verify 
To verify source code of contracts on [Etherescan](https://etherscan.io/) run `npx truffle run verify <SomeContract> <AnotherContract> --network <networkName>`. 
It requires valid Etherescan API key in `.env` file. 
It allows to verify several contracts at once.
