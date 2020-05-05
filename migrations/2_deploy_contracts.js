require('dotenv').config();

var MonsterCore = artifacts.require('MonsterCore');
var MonsterLib = artifacts.require('MonsterLib');
var SaleClockAuction = artifacts.require('SaleClockAuction');
var SiringClockAuction = artifacts.require('SiringClockAuction');
var MonsterFood = artifacts.require('MonsterFood');
var MonsterBattles = artifacts.require('MonsterBattles');
var MonsterStorage = artifacts.require('MonsterStorage');
var MonsterConstants = artifacts.require('MonsterConstants');
var MonsterGenetics = artifacts.require('MonsterGenetics');



const comission = 350; //3.5%
var CEO;
var CFO;
var COO;


function initAddresses(network, accounts) {
    switch (network) {
        case "development":
        case "coverage":
            CEO = accounts[0];
            CFO = accounts[1];
            COO = accounts[2];
            break;
        case "rinkeby":
            CEO = process.env.CEO;
            CFO = process.env.CFO;
            COO = process.env.COO;
            break;
        default:
            const err = "Unknown network: '" + network + "'. Deployment aborted";
            console.log(err);
            throw err;
    }    
}

async function doDeploy(deployer, network) {
    // 0) Деплоим библиотеку MonsterLib, связываем ее с контрактами
    await deployer.deploy(MonsterLib, {overwrite: false});
    await deployer.link(MonsterLib, [MonsterCore, MonsterBattles, MonsterGenetics]);
    // 1) Деплоим контракт MonsterCore
    var Core = await deployer.deploy(MonsterCore, CEO);
    // 2) Деплоим SaleClockAuction, у него в конструкторе два параметра.
    await deployer.deploy(SaleClockAuction, Core.address, comission);
    // 3) Деплоим SiringClockAuction, его параметры аналогичны предыдущему пункту.
    await deployer.deploy(SiringClockAuction, Core.address, comission);
    // 4) Деплоим MonsterFood. Его единственный параметр в конструкторе - это адрес MonsterCore.  
    await deployer.deploy(MonsterFood, Core.address);
    // 5) Деплоим MonsterBattles. Его единственный параметр в конструкторе - это адрес MonsterCore.  
    await deployer.deploy(MonsterBattles, Core.address);
    // 6) Деплоим MonsterStorage. Его единственный параметр в конструкторе - это адрес MonsterCore.  
    await deployer.deploy(MonsterStorage, Core.address);
    // 7) Деплоим MonsterConstants. Параметров нету. Если в него не вносились изменения, его можно оставить от предыдущих итераций. Т.е. не обязательно его передеплоивать, можно оставить старый. 
    await deployer.deploy(MonsterConstants, {overwrite: false});
    // 8) Компилируем и деплоим MonsterGenetics. Аналогично, если изменения не вносились, то его можно не деплоить заново и оставить предыдущий вариант. 
    await deployer.deploy(MonsterGenetics, {overwrite: false});


    // После того, как все контракты опубликованы, нужно вызвать несколько функций контракта MonsterCore:
    // 1) setBattlesAddress (передать адрес контракта MonsterBattles)
    await Core.setBattlesAddress(MonsterBattles.address);
    // 2) setGeneScienceAddress (передать адрес контракта MonsterGenetics)
    await Core.setGeneScienceAddress(MonsterGenetics.address);
    // 3) setMonsterConstantsAddress (передать адрес контракта MonsterConstants)
    await Core.setMonsterConstantsAddress(MonsterConstants.address);    
    // 4) setMonsterFoodAddress (передать адрес контракта MonsterFood)
    await Core.setMonsterFoodAddress(MonsterFood.address);    
    // 5) setMonsterStorageAddress (передать адрес контракта MonsterStorage)
    await Core.setMonsterStorageAddress(MonsterStorage.address);   
    // 6) setSaleAuctionAddress (передать адрес контракта SaleClockAuction)
    await Core.setSaleAuctionAddress(SaleClockAuction.address);    
    // 7) setSiringAuctionAddress (передать адрес контракта SiringClockAuction)
    await Core.setSiringAuctionAddress(SiringClockAuction.address);    
    // 8) unpause() - без параметров, запуск контракта
    await Core.unpause();

    // Для того, чтобы бэкэнд мог публиковать монстров, нужно вызвать функцию setCOO, передав ей адрес кошелька бэкэнда. 
    await Core.setCOO(COO);
    // Устанавливаем CFO
    await Core.setCFO(CFO);
}


module.exports = (deployer, network, accounts) => {
    deployer.then(async () => {
        initAddresses(network, accounts);
        await doDeploy(deployer, network);
    });
};