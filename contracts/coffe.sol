// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract BuyACoffe{
    address payable  immutable owner;
    uint256  minAmmount;
    mapping (address => uint256) public funders;

    constructor(){
        owner = payable (msg.sender);
        minAmmount = 5;
    }

    function donate() external payable{
        require(msg.value >= minAmmount,"No cumple el saldo minimo");
        funders[msg.sender] += msg.value;
    }

    function withdraw()external{
        require(msg.sender == owner,"No es el duenio");
        (bool succes,) = owner.call{value: address(this).balance}("");
        require(succes,"transaccion fallida");
    }
    
}