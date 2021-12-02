// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title EvmosNFT
 * EvmosNFT - ERC-721 EvmosNFT
 */
contract EvmosNFT is ERC721, Ownable {
    address marketplaceProxyAddress;
    string public contract_ipfs_json;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;
    uint256 HARD_CAP = 10001;
    bool public is_collection_revealed = false;
    string public notrevealed_nft = "https://raw.githubusercontent.com/ownlabs/evmos-erc-721-pfp/master/metadata/nft.json";
    string public contract_base_uri = "https://raw.githubusercontent.com/ownlabs/evmos-erc-721-pfp/master/metadata/";
    uint256 public mint_price = 0.0001 ether;
    constructor(
        address _marketplaceProxyAddress,
        string memory _name,
        string memory _ticker,
        string memory _contract_ipfs
    ) ERC721(_name, _ticker) {
        marketplaceProxyAddress = _marketplaceProxyAddress;
        contract_ipfs_json = _contract_ipfs;
    }

    function _baseURI() internal view override returns (string memory) {
        return contract_base_uri;
    }

    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter.current();
    }

    function tokensOfOwner(address _owner) external view returns(uint256[] memory ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);
        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalTkns = totalSupply();
            uint256 resultIndex = 0;
            uint256 tnkId;

            for (tnkId = 1; tnkId <= totalTkns; tnkId++) {
                if (ownerOf(tnkId) == _owner) {
                    result[resultIndex] = tnkId;
                    resultIndex++;
                }
            }

            return result;
        }
    }

    function tokenURI(uint256 _tokenId)
        public
        view
        override(ERC721)
        returns (string memory)
    {
        if(is_collection_revealed == true){
            string memory _tknId = Strings.toString(_tokenId);
            return string(abi.encodePacked(contract_base_uri, _tknId, ".json"));
        } else {
            return notrevealed_nft;
        }
    }

    /*
        This method will allow owner reveal the collection
     */

    function revealCollection() public onlyOwner {
        is_collection_revealed = true;
    }

    function contractURI() public view returns (string memory) {
        return contract_ipfs_json;
    }

    function fixContractURI(string memory _newURI) public onlyOwner {
        contract_ipfs_json = _newURI;
    }

    function fixBaseURI(string memory _newURI) public onlyOwner {
        contract_base_uri = _newURI;
    }

    /*
        This method will allow anyone to mint the token.
    */
    function buyNFT()
        public
        payable
    {
        require(msg.value % mint_price == 0, 'EvmosNFT, Amount must be a multiple of price');
        uint256 amount = msg.value / mint_price;
        require(amount >= 1, 'EvmosNFT: Amount should be at least 1');
        uint256 reached = _tokenIdCounter.current() + 1;
        require(reached <= HARD_CAP, "EvmosNFT: Hard cap reached");
        uint j = 0;
        for (j = 0; j < amount; j++) {
            _tokenIdCounter.increment();
            uint256 newTokenId = _tokenIdCounter.current();
            _mint(msg.sender, newTokenId);
        }
    }

    /*
        This method will allow owner to get the balance of the smart contract
     */

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    /*
        This method will allow owner tow withdraw all ethers
     */

    function withdrawMatic() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, 'EvmosNFT: Nothing to withdraw!');
        payable(msg.sender).transfer(balance);
    }

    /**
     * Override isApprovedForAll to whitelist proxy accounts
     */
    function isApprovedForAll(address _owner, address _operator)
        public
        view
        override
        returns (bool isOperator)
    {

        // Approving for UMi and Opensea address
        if (_operator == address(marketplaceProxyAddress)) {
            return true;
        }

        return super.isApprovedForAll(_owner, _operator);
    }
}
