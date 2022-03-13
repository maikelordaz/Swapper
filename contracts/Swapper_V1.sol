//SPDX-License-Identifier: GNL

pragma solidity ^0.8.4;

// CONTRACTS INHERITED //
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
// INTERFACES USED //
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
// LIBRARIES USED //


// VERSION 1 //

contract Swapper is Initializable, OwnableUpgradeable {

// VARIABLES //

    uint public fee;
    address public recipient;
    address private UniswapV2Router02;
    address private WETH;

// MAPPINGS //
// EVENTS //
// FUNCTIONS //

    function initialize() 
        public
        initializer {
            __Ownable_init(); 
            UniswapV2Router02 = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D; 
            WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;          
        }
    /**
    * @notice a function to set the fee for every swap.
    * @dev only the owner of the contract can change the fee.
    * @param _fee the percentage of the fee. it has to be multiplied by ten. Example for a 0.1%
    * the _fee is 1.
    */
    function setFee(uint _fee) 
        private
        onlyOwner {
            require(_fee > 0);
            fee = _fee * 1 / 1000;        
    }
    /**
    * @notice a function to set the address who receive the fee for every swap.
    * @dev only the owner of the contract can change this address.
    */
    function setRecipient() 
        private
        onlyOwner {
            address _recipient = owner();
            recipient = _recipient;
    }
    /**
    * @notice a function to swap betwen tokens.
    * @dev this is an auxiliar function.
    * @param _tokenIn is the address of the token that the user have.
    * @param _tokenOut is the address of the token that the user wants.
    * @param _amountIn is the amount of tokens the user has.
    * @param _amountOutMin is the amount of tokens the user wants.
    * @param _to is the address of the swap recipient. 
    */
    function _swap(address _tokenIn, 
                   address _tokenOut, 
                   uint _amountIn, 
                   uint _amountOutMin, 
                   address _to)
        internal{

            require(_tokenIn != _tokenOut, "You have to change betwen diferent tokens.");
            require(_amountIn > 0, "You have to change something.");
            IERC20Upgradeable(_tokenIn).transferFrom(msg.sender, address(this), _amountIn);
            IERC20Upgradeable(_tokenIn).approve(UniswapV2Router02, _amountIn);
            address[] memory _path;
            _path = new address[](3);
            _path[0] = _tokenIn;
            _path[1] = WETH;
            _path[2] = _tokenOut;
            IUniswapV2Router02(UniswapV2Router02).
                swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    _amountIn, _amountOutMin, _path, _to, block.timestamp);
        }
    /**
    * @notice a function to make multiple swaps given a percentage of wanted tokens.
    * @dev this is the mai function.
    * @param tokenIn the address of the token that the use has.
    * @param tokensOut an array with addresses of tokens that the user wants.
    * @param percentage an array with percentages of every token that the user wants. 
    */
    function swap(address tokenIn, address[] memory tokensOut, uint[] memory percentage) 
        public 
        payable {

            require(msg.value > 0, "You have to change something.");
            require(tokensOut.length == percentage.length, 
                    "The number of tokens has to be equal to the percentages.");
            uint minusFee = msg.value - (msg.value*fee);
            for (uint i = 0; i < tokensOut.length; i++) {
                _swap(
                    tokenIn, 
                    tokensOut[i], 
                    minusFee*percentage[i], 
                    1, 
                    msg.sender);
            }
            payable(recipient).transfer(address(this).balance);
    }

}