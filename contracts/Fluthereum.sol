// SPDX-License-Identifier: MIT
pragma solidity 0.5.16;

contract Fluthereum {
    // amount returned to user
    int256 balanceAmount;
    
    // amount deposited by user
    int256 depositAmount;
    
    // minimum amount to be deposited by user
    int256 thresholdAmount;
    
    // amount to be returned in addition to depositAmount to user
    int256 returnOnInvestment;

    mapping(address => int256) public balances;

    constructor() public{
        balanceAmount = 0;
        depositAmount = 0;
        thresholdAmount =12;
        returnOnInvestment = 3;
    }
    
    function parseAddr(string memory _a) internal pure returns (address _parsedAddress) {
    bytes memory tmp = bytes(_a);
    uint160 iaddr = 0;
    uint160 b1;
    uint160 b2;
    for (uint i = 2; i < 2 + 2 * 20; i += 2) {
        iaddr *= 256;
        b1 = uint160(uint8(tmp[i]));
        b2 = uint160(uint8(tmp[i + 1]));
        if ((b1 >= 97) && (b1 <= 102)) {
            b1 -= 87;
        } else if ((b1 >= 65) && (b1 <= 70)) {
            b1 -= 55;
        } else if ((b1 >= 48) && (b1 <= 57)) {
            b1 -= 48;
        }
        if ((b2 >= 97) && (b2 <= 102)) {
            b2 -= 87;
        } else if ((b2 >= 65) && (b2 <= 70)) {
            b2 -= 55;
        } else if ((b2 >= 48) && (b2 <= 57)) {
            b2 -= 48;
        }
        iaddr += (b1 * 16 + b2);
    }
    return address(iaddr);
}
    
    function getBalanceAmount() public view returns (int256){
        return balanceAmount;
    }

    function getBalanceByAddress(address account) public view returns (int256){
        return balances[account];
    }

    function testeTuga2() public pure returns (string memory){
      return "ola";
    }
    
    function getDepositAmount() public view returns (int256){
        return depositAmount;
    }
    
    function addDepositAmount(int256 amount, address account) public{
        depositAmount = depositAmount + amount;
        balances[account] = balances[account] + amount;
        
        if(depositAmount >= thresholdAmount) {
            balanceAmount = depositAmount + returnOnInvestment;
        }
    }
    
    function withDrawBalance(address account) public{
        balanceAmount = balanceAmount - balances[account];
        depositAmount = depositAmount - balances[account];
        balances[account] = 0;
    }
}

