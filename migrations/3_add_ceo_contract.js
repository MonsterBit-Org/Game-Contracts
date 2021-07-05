require('dotenv').config();

var Core = artifacts.require('MonsterCore');
var Ceo = artifacts.require('CEO');

async function doDeploy(deployer, network, accounts) {
    var ceo1;
    var ceo2;
    switch (network) {
        case "development":
        case "coverage":
        case "test": // this one is used for Truffle Teams (build)
        case "deploy": // this one is used for Truffle Teams (deploy)
            ceo1 = accounts[0];
            ceo2 = accounts[1];
            break;
        case "rinkeby":
            ceo1 = process.env.CEO;
            ceo2 = process.env.CEO2;
            break;
        default:
            const err = "Unknown network: '" + network + "'. Deployment aborted";
            console.log(err);
            throw err;
    }

    var core = await Core.deployed();
    var CEO = await deployer.deploy(Ceo, core.address, ceo1, ceo2);
    await core.setCEO(CEO.address);
}


module.exports = (deployer, network, accounts) => {
    deployer.then(async () => {
        await doDeploy(deployer, network, accounts);
    });
};