 // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import ERC20 interfaces for supported tokens
import "lib/openzeppelin-contracts/contracts/interfaces/IERC20.sol";
import "lib/openzeppelin-contracts/contracts/interfaces/IERC721.sol";
import "./RateLookup.sol";

contract NFTMarketplace is RateLookup {

    // NFT struct to represent an NFT for sale
    struct NFT {
        address seller;
        address contractAddress;
        uint256 tokenId;
        uint256 price;
        bool sold;
    }

    // Mapping of NFT ID to the NFT struct
    mapping (uint256 => NFT) public nftsForSale;

    // Mapping of supported token addresses to their on-chain value in ETH
    mapping (address => uint256) public tokenPricesInETH;

    //the market owner
    address marketOwner;

    constructor() {
        marketOwner = msg.sender;

    }

    // Events for when an NFT is put up for sale and when it is sold
    event NFTForSale(uint256 indexed id, address indexed seller, address indexed contractAddress, uint256 tokenId, uint256 price);
    event NFTSold(uint256 indexed id, address indexed buyer, uint256 price);

    // Function to put an NFT up for sale
    function sellNFT(address _contractAddress, uint256 _tokenId, uint256 _price) external {
        require(_price > 0, "Price cannot be zero");

        // Transfer NFT to the contract
        IERC721(_contractAddress).transferFrom(msg.sender, address(this), _tokenId);

        // Create new NFT struct
        uint256 id = uint256(keccak256(abi.encodePacked(_contractAddress, _tokenId, _price)));
        nftsForSale[id] = NFT(msg.sender, _contractAddress, _tokenId, _price, false);

        // Emit event
        emit NFTForSale(id, msg.sender, _contractAddress, _tokenId, _price);
    }

    // Function to buy an NFT with ETH
    function buyNFTWithETH(uint256 _id) external payable {
        NFT memory nft = nftsForSale[_id];
        require(nft.sold == false, "NFT already sold");
        require(msg.value == nft.price, "Incorrect ETH amount sent");

        // Mark NFT as sold
        nftsForSale[_id].sold = true;

        // Transfer NFT to buyer
        IERC721(nft.contractAddress).transferFrom(address(this), msg.sender, nft.tokenId);

        // Transfer ETH to seller
        (bool success, ) = nft.seller.call{value: nft.price}("");
        require(success, "ETH transfer failed");

        // Emit event
        emit NFTSold(_id, msg.sender, nft.price);
    }

    // function buyNFTWithUSDT(uint256 _id, address _tokenAddress, uint256 _amount) external {
    //     NFT memory nft = nftsForSale[_id];
    //     require(nft.sold == false, "NFT already sold");

    //     // Get on-chain value of token in ETH
    //     uint256 tokenPriceInETH = tokenPricesInETH[_tokenAddress];
    //     require(tokenPriceInETH > 0, "Token not supported");

    //     // Calculate required ETH amount
    //     uint256 ethAmount = (_amount * tokenPriceInETH) / (10 ** IERC20(_tokenAddress).decimals);

    //     // Transfer tokens from buyer to contract
    //     IERC20(_tokenAddress).transferFrom(msg.sender, address, ethAmount);
    // }

    // Function to buy an NFT with a supported token
    function buyNFTWithToken(uint256 _id, address _tokenAddress, uint256 _amount) external {
        NFT memory nft = nftsForSale[_id];
        require(nft.sold == false, "NFT already sold");

        // Get on-chain value of token in ETH

        // uint256 tokenPriceInETH = tokenPricesInETH[_tokenAddress];
        uint256 tokenPriceInETH = RateLookup.getDerivedPrice()

        require(tokenPriceInETH > 0, "Token not supported");

        // Calculate required ETH amount
        uint256 ethAmount = (_amount * tokenPriceInETH) / (10 ** IERC20(_tokenAddress).decimals);

        // Transfer tokens from buyer to contract
        IERC20(_tokenAddress).transferFrom(msg.sender, address, ethAmount);
    }





















































}
