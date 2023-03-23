// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./AggregatorV3Interface.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "lib/openzeppelin-contracts/contracts/token/ERC20/utils/SafeERC20.sol";
import "lib/openzeppelin-contracts/contracts/utils/math/SafeMath.sol";

contract NftForSale {
    address public owner;
    uint256 public price;
    IERC20 public usdtToken;
    AggregatorV3Interface private priceFeed;

    event Purchase(address indexed buyer, uint256 amount);

    constructor(uint256 _price, address _usdtTokenAddr) {
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(
            0xEe9F2375b4bdF6387aa8265dD4FB8F16512A1d46
        );
        usdtToken = IERC20(_usdtTokenAddr);
    }

    function getLatestPrice()
        public
        view
        returns (
            int _price
        )
    {
        (, _price, , , ) = priceFeed
            .latestRoundData();
    }

    function purchase(uint256 _amount) public {
        require(_amount >= price, "Insufficient payment");

        uint256 tokenAmount = _amount.div(price);
        uint256 excessPayment = _amount.mod(price);

        usdtToken.safeTransferFrom(msg.sender, owner, tokenAmount);
        if (excessPayment > 0) {
            payable(msg.sender).transfer(excessPayment);
        }

        emit Purchase(msg.sender, tokenAmount);
    }

    function setPrice(uint256 _price) public {
        require(msg.sender == owner, "Unauthorized");
        price = _price;
    }

    function withdrawTokens(IERC20 _token, uint256 _amount) public {
        require(msg.sender == owner, "Unauthorized");
        _token.safeTransfer(owner, _amount);
    }

    function withdrawEther(uint256 _amount) public {
        require(msg.sender == owner, "Unauthorized");
        payable(owner).transfer(_amount);
    }
}
