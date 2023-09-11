//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

abstract contract NexusBridge {

    // To be changed to the respective network addresses:
    address public constant DEPOSIT_CONTRACT=0xff50ed3d0ec03aC01D4C79aAd74928BFF48a7b2b;
    address public constant NEXUS_NETWORK=0xff50ed3d0ec03aC01D4C79aAd74928BFF48a7b2b;
    bytes public WITHDRAWAL_CREDENTAILS;
    uint256 constant VALIDATOR_DEPOSIT = 32 ether;

    error NotNexus();
    error ValidatorDepositFailed();
    error WithdrawalAddressExists();
    error IncorrectWithdrawalCredentials();

    modifier onlyNexus() {
        if (msg.sender!=NEXUS_NETWORK) revert NotNexus();
        _;
    }

    function setWithdrawal(bytes memory withdrawal_credential) external onlyNexus() {
        if (WITHDRAWAL_CREDENTAILS.length != 0) revert WithdrawalAddressExists();
        WITHDRAWAL_CREDENTAILS = withdrawal_credential;
    }

    function depositValidator(bytes calldata pubkey,bytes calldata withdrawal_credential,bytes calldata signature,bytes calldata deposit_root) external onlyNexus {
        if (keccak256(abi.encodePacked(withdrawal_credential)) != keccak256(abi.encodePacked(WITHDRAWAL_CREDENTAILS))) revert IncorrectWithdrawalCredentials();
        (bool success,bytes memory data) = DEPOSIT_CONTRACT.call{value: VALIDATOR_DEPOSIT}(abi.encodeWithSignature("deposit(bytes,bytes,bytes,bytes32)", pubkey,withdrawal_credential,signature,deposit_root));
        if(!success){
            revert ValidatorDepositFailed();
        }

    }


}
