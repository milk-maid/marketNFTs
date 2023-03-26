// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "./AggregatorV3Interface.sol";

/// @title Price Feed
/// @notice This gets the exchange rate of two Tokens

contract RateLookup is Ownable {

    /// @dev This maps the token address to the aggregator's address
    mapping (string => address) private aggregator;
    
    constructor() {
        addAggregator("ETH", 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
        addAggregator("EUR", 0xb49f677943BC038e9857d61E7d053CaA2C1734C1);
        addAggregator("USDT", 0x3E7d1eAB13ad0104d2750B8863b489D65364e32D);
        addAggregator("AAVE", 0x547a514d5e3769680Ce22B2361c10Ea13619e8a9);
        addAggregator("BNB", 0x14e613AC84a31f709eadbdF89C6CC390fDc9540A);
        addAggregator("BTC", 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c);
        addAggregator("CAKE", 0xEb0adf5C06861d6c07174288ce4D0a8128164003);
        addAggregator("DAI", 0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9);
        addAggregator("DOGE", 0x2465CefD3b488BE410b941b1d4b2767088e2A028);
        addAggregator("DOT", 0x1C07AFb8E2B827c5A4739C6d59Ae3A5035f28734);
        addAggregator("KNC", 0xf8fF43E991A81e6eC886a3D281A2C6cC19aE70Fc);
        addAggregator("NEAR", 0xC12A6d1D827e23318266Ef16Ba6F397F2F91dA9b);
        addAggregator("SUSHI", 0xCc70F09A6CC17553b2E31954cD36E4A2d89501f7);
        addAggregator("SOL", 0x4ffC43a60e009B551865A93d232E33Fce9f01507);
        addAggregator("FTT", 0x84e3946C6df27b453315a1B38e4dECEF23d9F16F);
        addAggregator("UNI", 0x553303d460EE0afB37EdFf9bE42922D8FF63220e);
    }

    function addAggregator(string memory _tokenName, address _aggregatorAddress) public onlyOwner() {
        require(aggregator[_tokenName] == address(0),"Aggregator Address already exist!");
        aggregator[_tokenName] = _aggregatorAddress;
    }


    function deleteAggregator(string calldata _tokenName) external onlyOwner() {
        require(aggregator[_tokenName] != address(0),"Aggregator Address does not exist");
        aggregator[_tokenName] = address(0);
    }

    /// This gets the exchange rate of two tokens
    /// @param _from This is the token you're swapping from
    // / @param _to This is the token you are swapping to    
    /// @param _decimals This is the decimal of the token you are swapping to
    function getDerivedPrice(
        string memory _from,
        string memory _to,
        uint8 _decimals
    ) public view returns (int256) {
        require(
            _decimals > uint8(0) && _decimals <= uint8(18),
            "Invalid _decimals"
        );
        int256 decimals = int256(10 ** uint256(_decimals));

        (, int256 fromPrice, , , ) = AggregatorV3Interface(aggregator[_from])
            .latestRoundData();

        uint8 fromDecimals = AggregatorV3Interface(aggregator[_from]).decimals();

        fromPrice = scalePrice(fromPrice, fromDecimals, _decimals);

        (, int256 toPrice, , , ) = AggregatorV3Interface(aggregator[_to])
            .latestRoundData();
            
        uint8 toDecimals = AggregatorV3Interface(aggregator[_to]).decimals();

        toPrice = scalePrice(toPrice, toDecimals, _decimals);

        return (fromPrice * decimals) / toPrice;
    }

    function scalePrice(
        int256 _price,
        uint8 _priceDecimals,
        uint8 _decimals
    ) internal pure returns (int256) {
        if (_priceDecimals < _decimals) {
            return _price * int256(10 ** uint256(_decimals - _priceDecimals));
        } else if (_priceDecimals > _decimals) {
            return _price / int256(10 ** uint256(_priceDecimals - _decimals));
        }
        return _price;
    }

    function getSwapTokenPrice(
        string memory _fromToken, 
        string memory _toToken,
        uint8 _decimals,
        int256 _amount
    ) internal view returns (int256) {

        require(aggregator[_fromToken] != address(0), "WE DON'T SUPPORT THIS TOKEN YET!");
        require(aggregator[_toToken] != address(0), "WE DON'T SUPPORT THIS TOKEN YET!");
        return _amount * getDerivedPrice(
            _fromToken,
             _toToken,
            _decimals);
    }


}
