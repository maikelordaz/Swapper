//SPDX-License-Identifier: GNL

pragma solidity ^0.8.4;

// CONTRACTS INHERITED //
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
//INTERFACES USED //
//LIBRARIES USED //


// VERSION 1 //

contract Swapper is Initializable, OwnableUpgradeable {

// VARIABLES //

    uint public fee;
    address public recipient;

// MAPPINGS //
// EVENTS //
// FUNCTIONS //

    function initialize() 
        public
        initializer {
            __Ownable_init();            
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