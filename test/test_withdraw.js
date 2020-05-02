const Core = artifacts.require('MonsterCore');
const Food = artifacts.require('MonsterFood');
const Storage = artifacts.require('MonsterStorage');

contract("Testing MonsterCore", accounts => {

  
  it("should have CEO, CFO and COO roles", async () => {
    const core = await Core.deployed();
    let ceo = await core.cfoAddress.call();
    assert.notEqual(ceo, '0x0000000000000000000000000000000000000000', "CEO address should be set");
    let cfo = await core.ceoAddress.call();
    assert.notEqual(cfo, '0x0000000000000000000000000000000000000000', "CFO address should be set");
    let coo = await core.cfoAddress.call();
    assert.notEqual(coo, '0x0000000000000000000000000000000000000000', "COO address should be set");
  });

  it("should have MonsterFood address set", async () => {
    const core = await Core.deployed();
    const food = await Food.deployed();
    let foodAddr = await core.monsterFood.call();
    assert.notEqual(foodAddr, '0x0000000000000000000000000000000000000000', "MonsterFood address should be set");
    assert.equal(foodAddr, food.address, "MonsterFood address should be set correctly");
  });

  it("should be unpaused", async () => {
    const core = await Core.deployed();
    let paused = await core.paused.call();
    assert.isFalse(paused);
  });

  it("should have 0 monsters", async () => {
    const core = await Core.deployed();
    let amount = await core.totalSupply.call();
    assert.equal(amount, 0, "fresh MonsterCore should have no monsters");
  });
  
  it("should have 0 ether", async () => {
    const core = await Core.deployed();
    let balance = await web3.eth.getBalance(core.address);
    assert.equal(balance, 0, "fresh MonsterCore should have no Ether");
  });

  it("COO should be able to create a promo monster", async () => {
    const core = await Core.deployed();
    let index = await core.tokensOfOwner(accounts[0]);
    assert.equal(index.length, 0, "User should have no monsters yet");
    await core.createPromoMonster(1234, 8765, 0, accounts[0], {from: accounts[2]});
    let amount = await core.totalSupply.call();
    assert.equal(amount, 1, "MonsterCore should have one monster");
    index = await core.tokensOfOwner(accounts[0]);
    assert.equal(index.length, 1, "User should have one monster now");
    assert.equal(index[0], 1, "User should own monster #1");
  });


  it("should be able to feed a monster", async () => {
    const core = await Core.deployed();
    const food = await Food.deployed();
    let foodAddr = await core.monsterFood.call();
    // assert.notEqual(foodAddr, '0x0000000000000000000000000000000000000000', "MonsterFood address should be set");
    let balance = await web3.eth.getBalance(food.address);
    assert.equal(balance, 0, "MonsterFood should have no Ether before feeding a monster");
    await core.feedMonster(1, 1, {value: 1000000000000000000});
    balance = await web3.eth.getBalance(food.address);
    assert.ok(balance > 0, "MonsterFood should have some Ether after feeding a monster");
  });

  it("should be able to initate withdraw", async () => {
    const core = await Core.deployed();
    const food = await Food.deployed();
    let balance = await web3.eth.getBalance(core.address);
    assert.equal(balance, 0, "MonsterCore should have no Ether before collecting fees");
    let etherToWithdraw = await web3.eth.getBalance(food.address);
    assert.ok(etherToWithdraw > 0, "MonsterFood should have some Ether after feeding a monster");
    assert.ok(Math.abs(etherToWithdraw - 15000000000000000) < 10000000000000, "MonsterFood should have some Ether after feeding a monster");

    // should work because we are using account[0] during deployment. should work with account[1] and account[2] as well
    await core.withdrawDependentBalances({ from: accounts[0] });

    balance = await web3.eth.getBalance(core.address);
    assert.equal(balance, etherToWithdraw, "MonsterCore should get Ether from MonsterFood");
    balance = await web3.eth.getBalance(food.address);
    assert.equal(balance, 0, "MonsterFood should have no Ether after collecting fees");
  });
  
  it("should be able to withdraw", async () => {
    const core = await Core.deployed();
    const storage = await Storage.deployed();
    let balance = await web3.eth.getBalance(core.address);
    assert.ok(balance > 0, "MonsterCore should have some Ether before withdrawal");
    // only works with CFO who is accounts[1]
    const pregnant = await storage.pregnantMonsters.call();
    assert.equal(pregnant, 0, "There should be no pregnant monsters yet");
    await core.withdrawBalance({ from: accounts[1] });
    balance = await web3.eth.getBalance(core.address);
    assert.equal(balance, 2000000000000000, "MonsterCore should have minimal amount of Ether after withdrawal (at least one autoBirthFee)");
  });
}); 
