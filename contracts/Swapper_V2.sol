//SPDX-License-Identifier: GNL
/**
* @title Swapper_V1 tool
* @author Maikel Ordaz.
* @notice a multitokens swap smart contract, that allows to make multiple transactions
* in one single operations, just giving the tokens that we want and the percentage that
* we want it.
* @dev this contract is upgradeable, and this is the second version.
*/
pragma solidity ^0.8.4;

// CONTRACTS INHERITED //
import "./Swapper_V1.sol";
import "hardhat/console.sol";

//================================ VERSION 2 ==========================================//

contract Swapper_V2 is Swapper_V1 {   

// VARIABLES //

    address public augustus; 

// FUNCTIONS //
    /**
    * @notice a setter function to get the Augustus Swapper address.
    */
    function setAugustusAddress() 
        public
        returns (address) {
            augustus = 0xDEF171Fe48CF0115B1d80b88dc8eAB59176FEe57;
            return augustus;
    }
    /**
    * @notice a function to use the Paraswap interfaces for swapping.
    * @dev this function is to swap ETH for tokens.
    * @param datas data needed by paraswap.
    * @param tokensOut the tokens the user wants.
    */
    function swapParaswap (bytes[] calldata datas, 
                           IERC20Upgradeable[] calldata tokensOut)
        public
        payable {

            require(msg.value > 0, "You have to change something.");
            require(datas.length == tokensOut.length, "It has to be equal size");
            for (uint256 i = 0; i < tokensOut.length; i++){                
                (bool success, bytes memory response) = 
                    augustus.call {value: msg.value}(datas[i]);
                if (!success) {
                    if (response.length < 68) revert ();
                    assembly { response := add(response,0x04)}
                    revert(abi.decode(response, (string)));
                }
            uint256 received = abi.decode(response, (uint256));
            require(received > 0, "There has been an error.");
            uint256 balance = tokensOut[i].balanceOf(address(this));
            require(balance > 0, "There has been an error...");
            tokensOut[i].transfer(recipient, fee);
            uint256 amountOut = msg.value - fee;
            tokensOut[i].transfer(msg.sender, amountOut);
            }
    } 
}