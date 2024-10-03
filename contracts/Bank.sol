// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Bank {
    struct Account {
        bool exists;
        uint256 balance;
    }

    mapping(address => Account) private accounts;

    error AccountAlreadyExists();
    error AccountDoesNotExist();
    error ZeroAddress();
    error NonPositiveValue();
    error InsufficientBalance();
    error WithdrawalFailed();
    error SelfTransferNotAllowed();

    event AccountCreated(
        address indexed accountHolder
    );
    event Deposit(
        address indexed accountHolder,
        uint256 amount
    );
    event Withdrawal(
        address indexed accountHolder,
        uint256 amount
    );
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 amount
    );

    modifier accountExists(address _account) {
        if (!accounts[_account].exists) {
            revert AccountDoesNotExist();
        }
        _;
    }

    function createAccount() external {
        if (accounts[msg.sender].exists) {
            revert AccountAlreadyExists();
        }

        accounts[msg.sender] = Account(true, 0);

        emit AccountCreated(msg.sender);
    }

    function deposit() external payable accountExists(msg.sender) {
        if (msg.sender == address(0)) {
            revert ZeroAddress();
        }

        if (msg.value <= 0) {
            revert NonPositiveValue();
        }

        accounts[msg.sender].balance += msg.value;
        
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 _amount) external accountExists(msg.sender) {
        uint256 balance = getBalance();

        if (msg.sender == address(0)) {
            revert ZeroAddress();
        }

        if (_amount <= 0) {
            revert NonPositiveValue();
        }

        if (balance < _amount) {
            revert InsufficientBalance();
        }

        accounts[msg.sender].balance -= _amount;
        
        (bool success, ) = msg.sender.call{value: _amount}("");
        if (!success) {
            revert WithdrawalFailed();
        }

        emit Withdrawal(msg.sender, _amount);
    }

    function transfer(address _to, uint256 _amount) external accountExists(msg.sender) accountExists(_to) {
        if (accounts[msg.sender].balance < _amount) {
            revert InsufficientBalance();
        }

        if (msg.sender == _to) {
            revert SelfTransferNotAllowed();
        }

        accounts[msg.sender].balance -= _amount;
        accounts[_to].balance += _amount;

        payable(_to).transfer(_amount);

        emit Transfer(msg.sender, _to, _amount);
    }

    function getBalance() public view accountExists(msg.sender) returns (uint256) {
        return accounts[msg.sender].balance;
    }
}
