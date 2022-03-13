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
            fee = _fee * 1 / 1000;        
    }
    /**
    * @notice a function to set the address who receive the fee for every swap.
    * @dev only the owner of the contract can change this address.
    * @param _recipient the percentage of the fee. it has to be multiplied by ten. Example for a 0.1%
    * the _fee is 1.
    */
    function setRecipient(address _recipient) 
        private
        onlyOwner {
            _recipient = owner();
            recipient = _recipient;
    }

    function swap (address tokenIn, 
                   address tokenOut, 
                   uint amountIn, 
                   uint amountOutMin, 
                   address to)
        internal{

            IERC20Upgradeable(tokenIn).transferFrom(msg.sender, address(this), amountIn);
            IERC20Upgradeable(tokenIn).approve(UniswapV2Router02, amountIn);
            address[] memory path;
            path = new address[](3);
            path[0] = tokenIn;
            path[1] = WETH;
            path[2] = tokenOut;
            IUniswapV2Router02(UniswapV2Router02).
                swapExactTokensForTokensSupportingFeeOnTransferTokens(
                    amountIn, amountOutMin, path, to, block.timestamp);

        }



}