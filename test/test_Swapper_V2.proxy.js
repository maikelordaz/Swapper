const { expect, assert, use } = require("chai");
const { network, ethers, web3 } = require("hardhat");
const { Contract, providers } = require("ethers");
const { BigNumber } = require ("bignumber.js");
const { ParaSwap } = require("paraswap");
const { SwapSide } = require("paraswap-core");
const { tokens } = require("./tokens1");

  // PAYMENTS //
  const toWei = (num) => String(ethers.utils.parseEther(String(num)));
  const fromWei = (num) => Number(ethers.utils.formatEther(num));
  // GAS //
  const Gas = async (tx) => {
    const receipt = await tx.wait();
    console.log("Gas used", Number(receipt.gasUsed));
  }
 

//START OF TEST
describe("Swapper_V2", function () {

  // SWAPPER ADDRESSES //
  const AUGUSTUS = "0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57";
  // CONTRACTS //
    let Swapper_V1;
    let Swapper_V2;
    let swapper_V1;
    let swapper_V2;
  // FOR SWAPPING //
    const networkID = 1;
    const amountIn = toWei(1);
    const partner = "Goku";
    const apiURL = "https://apiv5.paraswap.io";
    const slippage = 5;
  // SIGNERS //    
    let owner;
    let recipient;
    let user;  
      // TOKENS //
  function getToken(symbol) {
    const token = tokens[networkID]?.find((t) => t.symbol === symbol);  
    if (!token)
      throw new Error(`Token ${symbol} not available on network ${networkID}`);
    return token;
  }   
    
// BEFORE EACH TEST //
  
beforeEach(async function () {
    // THE CONTRACT IS INITIALIZED //    
    Swapper_V1 = await ethers.getContractFactory("Swapper_V1");
    Swapper_V2 = await ethers.getContractFactory("Swapper_V2");
    // THE API IS INITIALIZED //
    paraswap = new ParaSwap(networkID, apiURL, process.env.ALCHEMY_MAINNET_RPC_URL);    
    // THE ACCOUNTS AND SIGNERS ARE INITIALIZED //
    [owner, recipient, user] = await ethers.getSigners();
  });

// START OF THE TESTS //
it("Should deploy the second version upgrade.", async function (){
  swapper_V1 = await upgrades.deployProxy(Swapper_V1);
  await swapper_V1.deployed();
  swapper_V2 = await upgrades.upgradeProxy(swapper_V1.address, Swapper_V2);     
});  

it("Should set the right owner of the swapper_V2", async function (){
  expect(await swapper_V2.owner()).to.equal(owner.address);
});

it("Should set the fee", async function (){
  const _fee = 1;
  await swapper_V2.setFee(_fee);
});

it("Should set the  recipient of the fees", async function (){
  await swapper_V2.setRecipient(recipient.address);    
});

it("Should set the right address of the augustus swapper", async function (){
  await swapper_V2.setAugustusAddress();
});

it("Should fail to perform a swap if the user does not pay", async function (){
    const tokensOut = [tokenOut.address];
    const datas = [60];
    await expect(swapper_V2.swapParaswap(datas, tokensOut)).
        to.be.revertedWith("You have to change something.");
});

it("Should fail to perform a swap if the arguments does not complete the requirements",
  async function (){
    const tokensOut = [tokenOut.address];
    const datas = [60, 40];
    await expect(swapper_V2.swapParaswap(datas, tokensOut, {value: toWei(1)})).
        to.be.revertedWith("It has to be equal size");
});



it("Should perform a swap with paraswap", async function (){
  const srcToken = getToken("ETH");
  const destToken = getToken("AAVE");
  /* GET RATE PARAMS
    route: AddressOrSymbol[],
    amount: PriceString,
    userAddress?: Address,
    side: SwapSide = SwapSide.SELL,
    options?: RateOptions,
    srcDecimals?: number,
    destDecimals?: number,
  */
  const rateRoute = await paraswap.getRate(
    srcToken.address,
    destToken.address,
    amountIn,
    swapper_V2.address,
    SwapSide.SELL,
    { partner },
    srcToken.decimals,
    destToken.decimals);
  console.log("\ngetRate", rateRoute);
  if("message" in rateRoute) {
    throw new Error(rateRoute.message);
  }

  const amountOutMin = new BigNumber(rateRoute.destAmount).times(1-slippage/100).
    toFixed(0);
  /* BUILD TX PARAMS
  srcToken: Address,
    destToken: Address,
    srcAmount: PriceString,
    destAmount: PriceString,
    priceRoute: OptimalRate,
    userAddress: Address,
    partner?: string,
    partnerAddress?: string,
    partnerFeeBps?: number,
    receiver?: Address,
    options: BuildOptions = {},
    srcDecimals?: number,
    destDecimals?: number,
    permit?: string,
    deadline?: string,
  */
  const txRequest = await paraswap.buildTx(
    srcToken.address,
    destToken.address,
    amountIn,
    amountOutMin,
    rateRoute,
    swapper_V2.address,
    partner,
    undefined,
    undefined,
    swapper_V2.address,
    { ignoreChecks: true});
  console.log("\nbuildTx", txRequest);
  if("message" in txRequest) {
    throw new Error(txRequest.message);
  }
  
  expect(txRequest.chainId).to.eq(networkID);

  const tx = await swapper_V2.connect(user).swapParaswap(
    [txRequest.data],[destToken.address], { value: amountIn});    

  await Gas(tx);  

  const tokenReceived = await ethers.getContractAt(
    "IERC20Upgradeable", destToken.address);

  expect(await tokenReceived.balanceOf(user.address)).to.not.equal(0);
 });
  
})

