# MonsterBit
[![Build Status](https://travis-ci.org/eMarchenko/Game-Contracts.svg?branch=master)](https://travis-ci.org/eMarchenko/Game-Contracts)
[![Coverage Status](https://coveralls.io/repos/github/eMarchenko/Game-Contracts/badge.svg?branch=master)](https://coveralls.io/github/eMarchenko/Game-Contracts?branch=master)

Contracts for the [MonsterBit](https://monsterbit.org/) collectible game.

## Contracts
Important contracts

### MonsterCore
Main contract, most interactions happen through its functions.

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
