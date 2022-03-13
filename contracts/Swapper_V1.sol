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

// MAPPINGS //
// EVENTS //
// FUNCTIONS //

    function initialize() 
        public
        initializer {
            __Ownable_init();
            
        }

    function setFee(uint _fee) private {
        fee = _fee * 1 / 100;
        
    }

}