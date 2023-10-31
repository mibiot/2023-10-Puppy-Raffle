1.  Change the array players to the mapping to save gas. There will be high gas consumption when performing the loop in the original code. To check if a new address is already registered we use mapping isPlayer. mapping isPlayer added in the line 39. enterRaffle function is changed:  

        for (uint i = 0; i < newPlayers.length; i++) {
        require(!isPlayer[newPlayers[i]], "Player already exists in the raffle");
        isPlayer[newPlayers[i]] = true;
        players.push(newPlayers[i]);
        }
2. There should not be possible to add an array newPlayers that consists from zero addresses. 

        require(newPlayers[i] != address(0));


3. Reentrancy attack is possible in the base code version, index should be set to 0 before the transfer, line 110. The code for the attack is ReentrancyRaffle.sol.

4. The winner must have the valid ID in the players array, what happens when a player has been already refunded, the player address in the players[] was set to 0, and winnerIndex is hit the ID with address(0)?

the line 144 is added:

require(players[winnerIndex] != address(0), "call the function again");

5. Since the function withdrawFees() is set to be called manually, it is possible to manually create conditions when the owner can never get the fees. For this a user must enter the raffle just after the selectWinner() function has been called. This leads to changing the ballance of the contract by adding the entranceFee, and the condition:

        require(address(this).balance == uint256(totalFees), "PuppyRaffle: There are currently players active!");

will not be met. Therefore the function will be reverted. To avoid this it make sence to add a set up for automation calls functions withdrawFees() and selectWinner(). The other option is to transfer fees to the owner in the end of selectWinner() function.

