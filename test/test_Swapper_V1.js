const { expect, assert, use } = require("chai");
const { network, ethers, web3 } = require("hardhat");
const { Contract, BigNumber, providers } = require("ethers");
const { Web3Provider } = require("@ethersproject/providers");

  // PAYMENTS //
  const toWei = (num) => String(ethers.utils.parseEther(String(num)));
  const fromWei = (num) => Number(ethers.utils.formatEther(num));
  // GAS //
  const Gas = async (tx) => {
    const receipt = await tx.wait();
    console.log("Gas used", Number(receipt.gasUsed));
  }

describe("Swapper_V1", function () {

  // TOKENS ADDRESSES //
  const DAI = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
  const TOKEN_IN = DAI;
  const WBTC = "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599";
  const TOKEN_OUT = WBTC;
  const LINK = "0x514910771AF9Ca656af840dff83E8264EcF986CA";
  const linkToken = LINK;
  const WETH = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
  const weth = WETH;
  // USER ADDRESS //
  const DAI_WHALE = "0x1e3D6eAb4BCF24bcD04721caA11C478a2e59852D";
  const whale = DAI_WHALE;
  // INTERFACES //
  const UniswapV2Router02 = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
  const ROUTER = UniswapV2Router02;
  // CONTRACTS //
    let Swapper_V1;
    let swapper_V1;
  // FOR SWAPPING //
    const amountIn = BigNumber.from(10).pow(BigNumber.from(18)).mul(BigNumber.from(1000000)); //1.000.000 DAI
    const amountOutMin = 1;
  // SIGNERS //    
    let owner;
    let recipient;
    let user;    
    
// BEFORE EACH TEST //
  
beforeEach(async function () {
    // THE CONTRACT IS INITIALIZED //    
    Swapper_V1 = await ethers.getContractFactory("Swapper_V1");
    // THE ACCOUNTS AND SIGNERS ARE INITIALIZED //
    [owner, recipient, user] = await ethers.getSigners();
    // THE INTERFACES ARE INITIALIZED //
    router = await ethers.getContractAt("IUniswapV2Router02", ROUTER);
    tokenIn = await ethers.getContractAt("IERC20Upgradeable", TOKEN_IN);
    tokenOut = await ethers.getContractAt("IERC20Upgradeable", TOKEN_OUT);
    link = await ethers.getContractAt("IERC20Upgradeable", linkToken);    
  });
// START OF THE TESTS //
it("Should deploy the swapper_V1 contract, first version, upgradeable", async function (){
  swapper_V1 = await upgrades.deployProxy(Swapper_V1);
  await swapper_V1.deployed();     
});  

it("Should set the right owner of the swapper_V1", async function (){
  expect(await swapper_V1.owner()).to.equal(owner.address);
});

it("Should set the fee", async function (){
  const _fee = BigNumber.from(1);
  await swapper_V1.setFee(_fee);
});

it("Should set the  recipient of the fees", async function (){
  await swapper_V1.setRecipient(recipient.address);    
});

it("Should fail to perform a swap if the amount entered is 0", async function (){
  const tokensOut = [tokenOut.address, link.address];
  const percentage = [60, 40];
  await expect(swapper_V1.swapTokensForTokens(
    tokenIn.address, 0, amountOutMin, tokensOut, percentage, user.address)).
      to.be.revertedWith("You have to change something.");
});

it("Should fail to perform a swap if the amount of tokens are differen of the amount of percentages",
  async function (){
    const tokensOut = [tokenOut.address];
    const percentage = [60, 40];
    await expect(swapper_V1.swapTokensForTokens(
      tokenIn.address, amountIn, amountOutMin, tokensOut, percentage, user.address)).
        to.be.revertedWith("The number of tokens has to be equal to the percentages.");
});

it("Should fail to perform a swap if the amount of tokens are differen of the amount of percentages",
  async function (){
    const tokensOut = [tokenOut.address, link.address];
    const percentage = [60];
    await expect(swapper_V1.swapTokensForTokens(
    tokenIn.address, amountIn, amountOutMin, tokensOut, percentage, user.address)).
      to.be.revertedWith("The number of tokens has to be equal to the percentages.");
   });

it("Should fail to perform a swap if the token given by the user is the same token he wants",
  async function (){
  const tokensOut = [tokenIn.address];
  const percentage = [60];
  await expect(swapper_V1.swapTokensForTokens(
    tokenIn.address, amountIn, amountOutMin, tokensOut, percentage, user.address)).
      to.be.revertedWith("You have to change betwen diferent tokens.");
  });

it("Should perform a swap", async function (){
  await hre.network.provider.request({
    method: "hardhat_impersonateAccount",
    params: ["0x1e3D6eAb4BCF24bcD04721caA11C478a2e59852D"],
    });
  const signer = await ethers.getSigner("0x1e3D6eAb4BCF24bcD04721caA11C478a2e59852D")
    signer.sendTransaction(); 

  const tokensOut = [tokenOut.address, link.address];
  const percentage = [60, 40];
  await tokenIn.connect(signer).approve(swapper_V1.address, amountIn);
  const tx = await swapper_V1.connect(signer).swapTokensForTokens(
    tokenIn.address, amountIn, amountOutMin, tokensOut, percentage, user.address);

  await Gas(tx);
});
})

