const { expect, assert } = require("chai");
const { ethers } = require("hardhat");
const { Contract, BigNumber } = require("ethers");


//START OF TEST
describe("Swapper", function () {

  // TOKENS ADDRESSES //
  const DAI_Address = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
  const WBTC_Address = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
  const LINK_Address = 0x514910771AF9Ca656af840dff83E8264EcF986CA;
  const WETH_Address = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
  // INTERFACES //
  const UniswapV2Router02 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
  // PAYMENTS //
  const toWei = (num) => String(ethers.utils.parseEther(String(num)));
  const fromWei = (num) => Number(ethers.utils.formatEther(num));
  // GAS //
  const Gas = async (tx) => {
    const receipt = await tx.wait();
    console.log("Gas used", Number(receipt.gasUsed));
  }
  // VARIABLES //
    let Swapper;
    let swapper;
    let owner;
    let DAI;    
    let WBTC;    
    let LINK;
    let WETH;
    let router;
/*    
    const DAI_WHALE = 0x5D38B4e4783E34e2301A2a36c39a03c45798C4dD;
    let whale = DAI_WHALE;
    const amountIn = BigNumber.from(1000000);
    const amountOutMin = BigNumber.from(1);
    const tokenIn = DAI_Address;
    const tokenOut = WBTC_Address;
    const to = whale;
  */

// BEFORE EACH TEST //
  
beforeEach(async function () {

    // THE CONTRACT IS DEPLOYED //    
    Swapper = await ethers.getContractFactory("Swapper");
    // THE INTERFACES ARE INITIALIZED //
    DAI = await ethers.getContractAt("IERC20Upgradeable", DAI_Address); 
    WBTC = await ethers.getContractAt("IERC20Upgradeable", WBTC_Address);
    LINK = await ethers.getContractAt("IERC20Upgradeable", LINK_Address);
    WETH = await ethers.getContractAt("IERC20Upgradeable", WETH_Address);
    router = await ethers.getContractAt("IUniswapV2Router02", UniswapV2Router02);
    [owner] = await ethers.getSigners();
  });
//TESTS
  it("Should deploy the swapper contract, first version, upgradeable", async function (){
    swapper = await upgrades.deployProxy(Swapper);
    await swapper.deployed(); 
    const swapperAddress = swapper.address;
    console.log("Swapper deployed at", swapperAddress);      
  });

  xit("Should perform a swap", async function (){
    const tokensOut = [WBTC_Address, LINK_Address];
    const percentage = [70, 30];
    const tx = await swapper.connect(whale).swap(tokenIn, amountOutMin, tokensOut, percentage, {value: amountIn});


  });
})
