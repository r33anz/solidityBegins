// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;

contract CompoundInterest {
    string public constant nombre = "Anzaldo";
    string public constant simbolo = "ANZ";
    uint8 public constant decimals = 18;

    uint256 public constant interestRatePerPeriod = 5e16; // 5% = 0.05 con 18 decimales
    uint256 public constant periodDuration = 3 hours; // 3 horas simulan un "mes"
    
    address public immutable owner;

    mapping(address => uint256) public balance;
    mapping(address => uint256) public deposits;
    mapping(address => uint256) public depositTimestamp;

    constructor() {
        owner = msg.sender;
    }

    event Mint(address to, uint256 amount);
    event Transfer(address from, address to, uint256 amount);
    event Deposit(address user, uint256 amount);
    event Withdraw(address user, uint256 amount);

    function mint(address to, uint256 value) public {
        require(msg.sender == owner, "Solo el owner puede mintear");
        balance[to] += value;
        emit Mint(to, value);
    }

    function transfer(address from, address to, uint256 value) public {
        require(balance[from] >= value, "Saldo insuficiente");
        balance[from] -= value;
        balance[to] += value;
        emit Transfer(from, to, value);
    }

    function deposit(uint256 value) public {
        require(balance[msg.sender] >= value, "Saldo insuficiente");
        _applyInterest(msg.sender);

        balance[msg.sender] -= value;
        deposits[msg.sender] += value;
        depositTimestamp[msg.sender] = block.timestamp;

        emit Deposit(msg.sender, value);
    }

    function withdraw(uint256 value) public {
        _applyInterest(msg.sender);
        require(deposits[msg.sender] >= value, "No hay suficiente depositado");

        deposits[msg.sender] -= value;
        balance[msg.sender] += value;

        emit Withdraw(msg.sender, value);
    }

    function _applyInterest(address user) internal {
        uint256 elapsed = block.timestamp - depositTimestamp[user];
        uint256 periods = elapsed / periodDuration;

        if (periods == 0 || deposits[user] == 0) return;

        uint256 principal = deposits[user];

        for (uint256 i = 0; i < periods; i++) {
            principal += (principal * interestRatePerPeriod) / 1e18;
        }

        deposits[user] = principal;
        depositTimestamp[user] += periods * periodDuration;
    }

    function viewProfits() public view returns (uint256 gananciasPendientes) {
        uint256 elapsed = block.timestamp - depositTimestamp[msg.sender];
        uint256 periods = elapsed / periodDuration;

        if (periods == 0 || deposits[msg.sender] == 0) return 0;

        uint256 principal = deposits[msg.sender];
        uint256 simulated = principal;

        for (uint256 i = 0; i < periods; i++) {
            simulated += (simulated * interestRatePerPeriod) / 1e18;
        }

        return simulated - principal; // ganancias acumuladas no aplicadas
    }
}
