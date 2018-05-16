pragma solidity ^0.4.23;

import "./ERC721.sol";

contract MonsterBattles {
    // Reference to contract tracking NFT ownership
    ERC721 public nonFungibleContract;
    
    /// @dev Returns true if the claimant owns the token.
    /// @param _claimant - Address claiming to own the token.
    /// @param _tokenId - ID of token whose ownership to verify.
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (nonFungibleContract.ownerOf(_tokenId) == _claimant);
    }
    
    function PrepareForBattle(uint param1, uint param2, uint param3) public;
    
    function WithdrawFromBattle(uint param1, uint param2, uint param3) public;
    
    function FinishBattle(uint param1, uint param2, uint param3) public;
    
}