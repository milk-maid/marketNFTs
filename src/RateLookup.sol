// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "./AggregatorV3Interface.sol";
import "lib/openzeppelin-contracts/contracts/access/Ownable.sol";


/// @title Price Feed
/// @notice This gets the exchange rate of two Tokens

contract RateLookup is Ownable {

    /// @dev This maps the token address to the aggregator's address
    mapping (string => address) private aggregrator;
    
    constructor() {
        addAggregator("USDT", 0xEe9F2375b4bdF6387aa8265dD4FB8F16512A1d46);
        addAggregator("AAVE", 0x6Df09E975c830ECae5bd4eD9d90f3A95a4f88012);
        addAggregator("BNB", 0xc546d2d06144F9DD42815b8bA46Ee7B8FcAFa4a2);
        addAggregator("BTC", 0xdeb288F737066589598e9214E782fa5A8eD689e8);
        addAggregator("CELO", 0x9ae96129ed8FE0C707D6eeBa7b90bB1e139e543e);
        addAggregator("DAI", 0x773616E4d11A78F511299002da57A0a94577F1f4);
        addAggregator("FIL", 0x0606Be69451B1C9861Ac6b3626b99093b713E801);
        addAggregator("FTM", 0x2DE7E4a9488488e0058B95854CC2f7955B35dC9b);
        addAggregator("FTT", 0xF0985f7E2CaBFf22CecC5a71282a89582c382EFE);
        addAggregator("SHIB", 0x8dD1CD88F43aF196ae478e91b9F5E4Ac69A97C61);
    }

    function addAggregator(string memory _tokenName, address _aggregatorAddress) public onlyOwner() {
        require(aggregrator[_tokenName] == address(0),"Aggregator Address already exist!");
        aggregrator[_tokenName] = _aggregatorAddress;
    }


    function deleteAggregator(string calldata _tokenName) external onlyOwner() {
        require(aggregrator[_tokenName] != address(0),"Aggregator Address does not exist");
        aggregrator[_tokenName] = address(0);
    }

    /// This gets the exchange rate of two tokens
    /// @param _from This is the token you're swapping from
    // / @param _to This is the token you are swapping to    
    /// @param _decimals This is the decimal of the token you are swapping to
    function getDerivedPrice(
        string calldata _from,
        string calldata _to,
        uint8 _decimals
    ) public view returns (int256) {
        require(
            _decimals > uint8(0) && _decimals <= uint8(18),
            "Invalid _decimals"
        );
        int256 decimals = int256(10 ** uint256(_decimals));

        (, int256 fromPrice, , , ) = AggregatorV3Interface(aggregrator[_from])
            .latestRoundData();

        uint8 fromDecimals = AggregatorV3Interface(aggregrator[_from]).decimals();

        fromPrice = scalePrice(fromPrice, fromDecimals, _decimals);

        (, int256 toPrice, , , ) = AggregatorV3Interface(aggregrator[_to])
            .latestRoundData();
            
        uint8 toDecimals = AggregatorV3Interface(aggregrator[_to]).decimals();

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
        string calldata _fromToken, 
        string calldata _toToken,
        uint8 _decimals,
        int256 _amount
    ) external view returns (int256) {
        return _amount * getDerivedPrice(
            _fromToken,
             _toToken,
            _decimals);
    }


}
