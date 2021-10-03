pragma solidity >=0.4.22 <0.9.0;


import 'openzeppelin-solidity/contracts/token/ERC20/ERC20.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/ERC20Burnable.sol';
import 'openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol';
import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract ZennyToken is ERC20Burnable, ERC20Detailed, Ownable {
    string public _name = "Zenny";
    string public _symbol = "zeni";
    uint8 public _decimals = 18;

    uint256 constant private INITIAL_SUPPLY = 1000e18;

    constructor() public ERC20Detailed(_name, _symbol, _decimals)
    {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}