const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('ERC721', function () {
  let ExampleNFT;
  let exampleNFTContract;
  let ExampleNFTFactory;
  let exampleNFTFactoryContract;
  let alice;
  let bob;
  let cara;
  let aliceProxyContract;

  beforeEach(async () => {
    [alice, bob, cara] = await ethers.getSigners();

    ExampleNFT = await ethers.getContractFactory('ExampleNFT');
    exampleNFTContract = await ExampleNFT.deploy();
    await exampleNFTContract.deployed();

    ExampleNFTFactory = await ethers.getContractFactory('ExampleNFTFactory');
    exampleNFTFactoryContract = await ExampleNFTFactory.deploy(exampleNFTContract.address);
    await exampleNFTFactoryContract.deployed();

    // create a string array
    const globalPropKeys = ['Collection', 'Author'];
    const globalProps = ['Example Collection', 'Example Author'];
    const stringProperties = [{
      propertyName: 'Title',
      editable: false
    }, {
      propertyName: 'Description',
      editable: true
    }];
    // array of (string, bool) tuples
    var uintProperties = [{
      propertyName: 'Year',
      editable: false
    }];
    await exampleNFTFactoryContract.connect(alice).createInstance("ALICE", "ALC", globalPropKeys, globalProps, uintProperties, stringProperties);
    aliceProxyContract = await ExampleNFT.attach(await exampleNFTFactoryContract.getProxy(alice.address));
  });

  it('Master Contract should match exampleNFTContract', async function () {
    expect(await exampleNFTFactoryContract.masterContract()).to.equal(exampleNFTContract.address);
  });

  it("Should match alice's initial token data", async function () {
    expect(await aliceProxyContract.name()).to.equal('ALICE');
    expect(await aliceProxyContract.symbol()).to.equal('ALC');
  });

  it("Should have the same number of dynamic properties", async function() {
    expect(await aliceProxyContract.numberIndex()).to.equal(1);
    expect(await aliceProxyContract.stringIndex()).to.equal(2);
  });
});
