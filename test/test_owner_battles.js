const Battles = artifacts.require('MonsterBattles');

contract("Testing MonsterBattles", accounts => {


  it("should have an owner", async () => {
    const battles = await Battles.deployed();
    let owner = await battles.owner.call();
    assert.notEqual(owner, '0x0000000000000000000000000000000000000000', "MonsterBattles.owner should be set");
    assert.equal(owner, accounts[0], "MonsterBattles.owner address should be set correctly");
  });

  it("should be able to transfer ownership", async () => {
    const battles = await Battles.deployed();
    let paused = await battles.transferOwnership(accounts[1]);
    let owner = await battles.owner.call();
    assert.equal(owner, accounts[1], "MonsterBattles.owner address should be set correctly");
  });

  it("owner should be able to initialize withdraw process", async () => {
    const battles = await Battles.deployed();
    await battles.withdrawBalance({from: accounts[1]});
  });

}); 
