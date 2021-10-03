pragma solidity >=0.4.22 <0.9.0;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);
}

contract HashTimeLockedContract is Ownable {

    struct Swap {
        bytes32 hashedSecret;
        address erc20ContractAddress;
        address sender;
        address receiver;
        uint receivableTime;
        uint256 value;
    }

    //hash => Swap
    mapping(bytes32 => Swap) public swaps;

    uint public minLockTime;
    uint public maxLockTime;

    constructor () public {
        // 3hour
        minLockTime = 10800;

        // 3day
        maxLockTime = 2592000;
    }

    event LockToken(bytes32 _id, address _receiver, bytes32 _hashedSecret);
    event UnLockToken(bytes32 _id, address _receiver);

    modifier isExistId(bytes32 _id) {
        require(swaps[_id].sender != address(0));
        _;
    }
    modifier isNotExistId(bytes32 _id) {
        require(swaps[_id].sender == address(0));
        _;
    }

    function lockToken(bytes32 _id, address _erc20ContractAddress, address _receiver, bytes32 _hashedSecret, uint256 _value, uint _lockTimeSeconds) external isNotExistId(_id) {
        require(_erc20ContractAddress != address(0), "ERC20: approve from the zero address");
        require(_receiver != address(0), "ERC20: approve from the zero address");
        require(_lockTimeSeconds <= maxLockTime, "invalid lock time");
        require(_lockTimeSeconds >= minLockTime, "invalid lock time");

        swaps[_id].erc20ContractAddress = _erc20ContractAddress;
        swaps[_id].receiver = _receiver;
        swaps[_id].sender = msg.sender;
        swaps[_id].hashedSecret = _hashedSecret;
        swaps[_id].value = _value;
        swaps[_id].receivableTime = now + _lockTimeSeconds;

        IERC20 erc20Contract = IERC20(_erc20ContractAddress);
        require(_value <= erc20Contract.allowance(msg.sender, address(this)));
        require(erc20Contract.transferFrom(msg.sender, address(this), _value));

        emit LockToken(_id, _receiver, _hashedSecret);
    }

    function unlockToken(bytes32 _id, bytes calldata _secret) external isExistId(_id) {
        require(swaps[_id].hashedSecret == sha256(_secret));

        IERC20 erc20Contract = IERC20(swaps[_id].erc20ContractAddress);
        if (msg.sender == swaps[_id].receiver) {
            require(swaps[_id].receivableTime <= now, "this swap is expired");
            require(erc20Contract.transfer(swaps[_id].receiver, swaps[_id].value));

            emit UnLockToken(_id, swaps[_id].receiver);
        }
        if (msg.sender == swaps[_id].sender) {
            require(swaps[_id].receivableTime > now, "this swap cannot be unlocked");
            require(erc20Contract.transfer(swaps[_id].sender, swaps[_id].value));

            emit UnLockToken(_id, msg.sender);
        }

    }


    function getReceivableTime(bytes32 _id) public view returns (uint) {
        return swaps[_id].receivableTime;
    }

    function changeMaxLockTime(uint _maxLockTime) external onlyOwner {
        maxLockTime = _maxLockTime;
    }

    function changeMinLockTime(uint _minLockTime) external onlyOwner {
        minLockTime = _minLockTime;
    }


}