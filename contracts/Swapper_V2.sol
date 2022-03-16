//SPDX-License-Identifier: GNL
/**
* @title Swapper_V2 tool
* @author Maikel Ordaz.
* @notice a multitokens swap smart contract, that allows to make multiple transactions
* in one single operations, just giving the tokens that we want and the percentage that
* we want it.
* @dev this contract is upgradeable, and this is the second version.
*/
pragma solidity ^0.8.4;

// CONTRACTS INHERITED //
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// INTERFACES USED //
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
import "./paraswap/IParaswap.sol";
import "./paraswap/ITokenTransferProxy.sol";
// LIBRARIES USED //
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "./paraswap/lib/UtilsParaswap.sol";

//============================= VERSION 2 =============================================//

contract Swapper_V2 is Initializable, OwnableUpgradeable {

using SafeMathUpgradeable for uint256;

// VARIABLES //

    uint256 public fee;
    address payable recipient;
    address private UniswapV2Router02;
    address private WETH;
    address private tokenTransferProxy;
    address private augustusSwapper;
    IParaswap internal Paraswap;
    IParaswap internal paraswapTransfers;


// FUNCTIONS //

    function initialize() 
        public
        initializer {
            __Ownable_init(); 
            UniswapV2Router02 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
            tokenTransferProxy = 0x216B4B4Ba9F3e719726886d34a177484278Bfcae;
            augustusSwapper = 0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57;
            Paraswap = IParaswap(augustusSwapper);
            paraswapTransfers = IParaswap(tokenTransferProxy);
                      
        }
    /**
    * @notice a function to set the fee for every swap.
    * @dev only the owner of the contract can change the fee.
    * @param _fee the percentage of the fee. it has to be multiplied by ten. Example for
    * a 0.1% the _fee is 1.
    */
    function setFee(uint _fee) 
        public
        onlyOwner {
            require(_fee > 0);
            fee = _fee.div(1000);        
    }
    /**
    * @notice a function to set the address who receive the fee for every swap.
    * @dev only the owner of the contract can change this address.
    */
    function setRecipient(address payable _recipient) 
        public
        onlyOwner {
            require(_recipient != address(0));
            recipient = _recipient;
    }

//================================= UNISWAP ===========================================//    
 
    /**
    * @notice a function to swap betwen tokens.
    * @dev this is an auxiliar function.
    * @param _tokenIn is the address of the token that the user have.
    * @param _tokenOut is the address of the token that the user wants.
    * @param _amountIn is the amount of tokens the user has.
    * @param _amountOutMin is the amount of tokens the user wants.
    * @param _to is the address of the swap recipient. 
    */
    function _swapUniswap(address _tokenIn, 
                          address _tokenOut, 
                          uint256 _amountIn, 
                          uint256 _amountOutMin, 
                          address _to)
        internal{

            require(_tokenIn != _tokenOut, "You have to change betwen diferent tokens.");
            IERC20Upgradeable(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
            IERC20Upgradeable(_tokenIn).approve(UniswapV2Router02, _amountIn);
            address[] memory _path;
            _path = new address[](2);
            _path[0] = _tokenIn;
            _path[1] = _tokenOut;
            IUniswapV2Router02(UniswapV2Router02).
                swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    _amountIn, _amountOutMin, _path, _to, block.timestamp);
        }
    /**
    * @notice a function to make multiple token swaps given a percentage of wanted tokens.
    * @dev this is the mai function.
    * @param tokenIn the address of the token that the use has.
    * @param amountIn is the amount of tokens the user has.
    * @param amountOutMin the minimum tokens to get.
    * @param tokensOut an array with addresses of tokens that the user wants.
    * @param percentage an array with percentages of every token that the user wants.
    * @param to is the address of the swap recipient. 
    */
    function swapUniswap(address tokenIn,
                         uint256 amountIn,
                         uint256 amountOutMin, 
                         address[] memory tokensOut, 
                         uint256[] memory percentage,
                         address to) 
        public {

            require(amountIn > 0, "You have to change something.");
            require(tokensOut.length == percentage.length, 
                    "The number of tokens has to be equal to the percentages.");
            uint256 minusFee = amountIn.sub(amountIn.mul(fee));
            for (uint i = 0; i < tokensOut.length; i++) {
                _swapUniswap(
                    tokenIn, 
                    tokensOut[i], 
                    minusFee.mul(percentage[i]).div(100), 
                    amountOutMin, 
                    to);
            }
            payable(recipient).transfer(address(this).balance);
    }

//==================================== PARASWAP =======================================//
  
    function _swapParaswap(address _tokenIn, 
                           address _tokenOut, 
                           uint256 _amountIn,
                           uint256 _slippage)
        internal{

            require(_tokenIn != _tokenOut, "You have to change betwen diferent tokens.");
            IERC20Upgradeable(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
            IERC20Upgradeable(_tokenIn).approve(tokenTransferProxy, _amountIn);
            uint256[] memory startIndexes = new uint256[](1);
            startIndexes[1] = 1;
            uint256 _toAmount = _amountIn * (1 - _slippage / 100);           
            address[] memory _path;
            _path = new address[](2);
            _path[0] = _tokenIn;
            _path[1] = _tokenOut;
            (bool result, ) = augustusSwapper.call{value: _amountIn, gas: 10000}(
            abi.encodeWithSignature("swapOnUniswap(uint256 amountIn, uint256 amountOutMin, address[] calldata path)",
            _amountIn,
            _toAmount,
            _path
            )
        );
/*


 




            Utils.Route memory _route = Utils.Route(_index,
                                                    _exchange,
                                                    _slippage,
                                                    _payload,
                                                    _networkFee);

                                                    

            Utils.Adapter memory _adapter = Utils.Adapter(_exchange,
                                                          _percent,
                                                          _networkFee,
                                                          _route);

            Utils.Path memory _path = Utils.Path(_tokenOut,
                                                 _networkFee,
                                                 _adapter);
            
            Utils.SellData memory _sellData = Utils.SellData(_tokenIn,
                                                             _amountIn,
                                                             _toAmount,
                                                             _toAmount,
                                                             _to,
                                                             _path,
                                                             recipient,
                                                             fee,
                                                             _permit,
                                                             block.timestamp + 1,
                                                             "");
            
            (bool result,) = augustusSwapper.call{value: _amountIn, gas: 10000}(
                abi.encodeWithSignature("megaSwap(Utils.MegaSwapSellData calldata data)",
                 _sellData));
                 */
        }


}