//SPDX-License-Identifier: GNL

pragma solidity ^0.8.4;

// CONTRACTS INHERITED //
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
//INTERFACES USED //
import "@openzeppelin/contracts-upgradeable/token/ERC20/IERC20Upgradeable.sol";
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
//LIBRARIES USED //
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";


// VERSION 1 //

contract Swapper is Initializable, OwnableUpgradeable {

// VARIABLES //

    uint public fee;
    address public recipient;
    address private constant UniswapV2Router02;
    address private constant WETH;

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

    function swap (address TokenIn, address TokenOut, uint amount)
        internal {

        }



}