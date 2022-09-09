// SPDX-License-Identifier: MIT

pragma solidity ^0.8.6;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";

contract Ownable {
    address private owner;

    constructor() {
        owner = msg.sender;
    }

    function isOwner() public view returns(bool) {
        return msg.sender == owner;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner");
        _;
    }

    function getOwner() public view returns (address) {
        return owner;
    }
}

contract Allowance is Ownable {

    using SafeMath for uint;
    mapping(address => uint) private allowance;

    modifier hasAllowance(uint amount) {
        require(allowance[msg.sender] >= amount, "You do not have enough allowance");
        _;
    }

    modifier isOwnerOrHasAllowance(uint amount) {
        require(isOwner() || allowance[msg.sender] >= amount, "You are not allowed to make this operation");
        _;
    }

    function setAllowance(address who, uint newAllowance) public onlyOwner {
        allowance[who] = newAllowance;
    }

    function reduceAllowance(address who, uint amount) internal {
        allowance[who] = allowance[who].sub(amount);
    }
}

contract SharedWallet is Allowance {

    receive() external payable {
        // plain Ether calls, no calldata field
    }

    fallback() external payable {
        // calldata field contains stuff
    }

    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    function withdraw(address payable to, uint amount) public isOwnerOrHasAllowance(amount) {
        require(amount < address(this).balance, "There are not enough funds");
        if(!isOwner()) {
            reduceAllowance(msg.sender, amount);
        }

        to.transfer(amount);
    }

}