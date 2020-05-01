const Core = artifacts.require('MonsterCore');

contract("Testing MonsterCore", accounts => {

  it("should have CEO, CFO and COO roles", async () => {
    let instance = await Core.deployed();
    let ceo = await instance.cfoAddress.call();
    assert.notEqual(ceo, '0x0000000000000000000000000000000000000000', "CEO address should be set");
    let cfo = await instance.ceoAddress.call();
    assert.notEqual(cfo, '0x0000000000000000000000000000000000000000', "CFO address should be set");
    let coo = await instance.cfoAddress.call();
    assert.notEqual(coo, '0x0000000000000000000000000000000000000000', "COO address should be set");
  });

  it("should be unpaused", async () => {
    let instance = await Core.deployed();
    let paused = await instance.paused.call();
    assert.isFalse(paused);
  });

  it("should be able to initate withdraw", async () => {
    let instance = await Core.deployed();
    // should work because we are using account[0] during deployment. should work with account[1] and account[2] as well
    await instance.withdrawDependentBalances({ from: accounts[0] });
    // await instance.withdrawDependentBalances({ from: accounts[1] });
    // await instance.withdrawDependentBalances({ from: accounts[2] });
  });
  
  it("should be able to withdraw", async () => {
    let instance = await Core.deployed();
    // only works with CFO who is accounts[1]
    await instance.withdrawBalance({ from: accounts[1] });
  });
});
