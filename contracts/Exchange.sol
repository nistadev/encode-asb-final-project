// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract TokenExchange is Ownable, ReentrancyGuard {
    IERC20 public platformToken;
    uint256 public exchangeRate; // How many platform tokens per 1 ETH (in wei)
    
    event TokensPurchased(address indexed buyer, uint256 ethAmount, uint256 tokenAmount);
    event TokensSold(address indexed seller, uint256 tokenAmount, uint256 ethAmount);
    event ExchangeRateUpdated(uint256 newRate);
    event TokensWithdrawn(uint256 amount);
    event EthWithdrawn(uint256 amount);

    error InvalidAmount();
    error TransferFailed();
    error InsufficientBalance();

    constructor(address _platformToken, uint256 _initialExchangeRate, address _platformOwnER) Ownable(_platformOwnER) {
        platformToken = IERC20(_platformToken);
        exchangeRate = _initialExchangeRate;
    }

    // Function to buy tokens with ETH
    function buyTokens() external payable nonReentrant {
        if(msg.value == 0) {
            revert InvalidAmount();
        }
    
        uint256 tokenAmount = getTokensForEth(msg.value);
        if(tokenAmount == 0) {
            revert InvalidAmount();
        }
        if(platformToken.balanceOf(address(this)) < tokenAmount) {
            revert InsufficientBalance();
        }        
        bool success = platformToken.transfer(msg.sender, tokenAmount);
        require(success, "Token transfer failed");
        
        emit TokensPurchased(msg.sender, msg.value, tokenAmount);
    }

    // Function to sell tokens for ETH
    function sellTokens(uint256 tokenAmount) external nonReentrant {
        if(tokenAmount == 0) {
            revert InvalidAmount();
        }

        uint256 ethAmount = getEthForTokens(tokenAmount);
        if(ethAmount == 0) {
            revert InvalidAmount();
        }
        if(address(this).balance < ethAmount) {
            revert InsufficientBalance();
        }
        
        bool success = platformToken.transferFrom(msg.sender, address(this), tokenAmount);
        require(success, "Token transfer failed");
        
        (bool ethSent, ) = payable(msg.sender).call{value: ethAmount}("");
        require(ethSent, "ETH transfer failed");
        
        emit TokensSold(msg.sender, tokenAmount, ethAmount);
    }

    // Function to update exchange rate (only owner)
    function setExchangeRate(uint256 _newRate) external onlyOwner {
        require(_newRate > 0, "Exchange rate must be greater than 0");
        exchangeRate = _newRate;
        emit ExchangeRateUpdated(_newRate);
    }

    // Function to withdraw tokens (only owner)
    function withdrawTokens(uint256 _amount) external onlyOwner {
        if(_amount > platformToken.balanceOf(address(this))) {
            revert InsufficientBalance();
        }
        bool success = platformToken.transfer(owner(), _amount);
        require(success, "Token transfer failed");
        emit TokensWithdrawn(_amount);
    }

    // Function to withdraw ETH (only owner)
    function withdrawETH() external onlyOwner {
        uint256 balance = address(this).balance;
        if(balance == 0) {
            revert InsufficientBalance();
        }
        (bool success, ) = owner().call{value: balance}("");
        require(success, "ETH transfer failed");
        emit EthWithdrawn(balance);
    }

    // Function to check current exchange rates and balances
    function getExchangeInfo() external view returns (
        uint256 ethBalance,
        uint256 tokenBalance,
        uint256 currentRate
    ) {
        return (
            address(this).balance,
            platformToken.balanceOf(address(this)),
            exchangeRate
        );
    }

    // Function to calculate how many tokens you get for a given ETH amount
    function getTokensForEth(uint256 ethAmount) public view returns (uint256) {
        return (ethAmount * exchangeRate) / 1 ether;
    }

    // Function to calculate how much ETH you get for a given token amount
    function getEthForTokens(uint256 tokenAmount) public view returns (uint256) {
        return (tokenAmount * 1 ether) / exchangeRate;
    }


    receive() external payable {
        // Allow contract to receive ETH
    }
}