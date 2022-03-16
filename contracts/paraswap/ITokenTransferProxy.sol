//SPDX-License-Identifier: unlicensed
pragma solidity ^0.8.4;



interface ITokenTransferProxy {

    function transferFrom(
        address token,
        address from,
        address to,
        uint256 amount
    )
        external;
}
