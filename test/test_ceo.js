const Core = artifacts.require('MonsterCore');
const CEO = artifacts.require('CEO');

contract("Testing CEO contract", accounts => {

  let core;
  let ceo;

  beforeEach(async () => {
    core = await Core.deployed();
    ceo = await CEO.deployed();
  })

  it("CEO contract should have 'Ceo' role at Core", async () => {
    let addr = await core.ceoAddress.call();
    assert.equal(ceo.address, addr, "CEO address should be set to the CEO contract");
  });
  
  it("both CEO should be able to pause/unpause the MonsterCore", async () => {
    var tx = {};
    tx.data = web3.eth.abi.encodeFunctionSignature("pause()");
    await ceo.sendTransaction(tx);
    let status = await core.paused.call();
    assert.ok(status, "Core should be paused now");

    tx.data = web3.eth.abi.encodeFunctionSignature("unpause()");
    tx.from = accounts[1];
    await ceo.sendTransaction(tx);
    status = await core.paused.call();
    assert.isFalse(status, "Core should be unpaused now");
  });
  
  it("non CEO should be unable to pause the MonsterCore", async () => {
    var tx = {};
    tx.data = web3.eth.abi.encodeFunctionSignature("pause()");
    tx.from = accounts[2];

    var reverted = false;
    try {
      await ceo.sendTransaction(tx);
    } catch (error) {
      assert.equal(error.reason, "not a ceo address", "incorrect error message");
      reverted = true;
    }
    assert.ok(reverted, "tx should have failed");
  });
  
  it("CEO should be able to call withdraw fees to the MonsterCore", async () => {
    var tx = {};
    tx.data = web3.eth.abi.encodeFunctionSignature("withdrawDependentBalances()");
    await ceo.sendTransaction(tx);
  });  

  it("CEO should be unable to call non-ceo functions, e.g. withdraw ether from the system", async () => {
    var tx = {};
    tx.data = web3.eth.abi.encodeFunctionSignature("withdrawBalance()");
    var reverted = false;
    try {
      await ceo.sendTransaction(tx);
    } catch (error) {
      assert.equal(error.reason, "call to Core failed", "incorrect error message");
      reverted = true;
    }
    assert.ok(reverted, "tx should have failed");
  });
  
  it("CEO should be able to update CFO", async () => {
    var tx = {};
    tx.from = accounts[1];
    tx.data = web3.eth.abi.encodeFunctionCall({name: 'setCFO', type: 'function', inputs: [{name:"_newCFO",type: "address"}]}
        , [accounts[2]]);
    await ceo.sendTransaction(tx);
  });
  
  it("new CFO should be able to withdraw ether from the system", async () => {
    await core.withdrawBalance({from: accounts[2]});
  });

  it("CEO should reject calls without any data", async () => {
    var reverted = false;
    try {
      await ceo.send(0);
    } catch (error) {
      assert.equal(error.reason, "msg.data.length == 0", "incorrect error message");
      reverted = true;
    }
    assert.ok(reverted, "tx should have failed");
  });

  
}); 
