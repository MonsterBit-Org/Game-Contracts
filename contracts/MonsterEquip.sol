pragma solidity ^0.4.25;


import "./ERC721.sol";
import "./Pausable.sol";
import "./MonsterBitSaleAuction.sol";
import "./MonsterAccessControl.sol";

contract MonsterEquipBase is MonsterAccessControl
{
    string public constant name = "MonsterBitEquip";
    string public constant symbol = "MBE";
    
    SaleClockAuction public saleAuction;
    
    mapping (uint256 => address) public equipIndexToOwner;
    mapping (uint256 => address) public equipIndexToApproved;
    mapping (address => uint256) public ownershipTokenCount;
    
    
    constructor() public
    {
        Equip memory eq = Equip({typeCode: 0});
        _createEquip(eq);
        equipIndexToOwner[0] = address(0);
    }
    
    struct Equip
    {
        uint8 typeCode;
    }
    
    Equip[] equips;
    
    function _createEquip(Equip eq) internal returns(uint)
    {
        uint256 newEquipId = equips.push(eq) - 1;
        return newEquipId;
    }
}



contract MonsterEquipERC is MonsterEquipBase, ERC721 
{
   
    
    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);
    
    
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return equipIndexToOwner[_tokenId] == _claimant;
    }

    /// @dev Checks if a given address currently has transferApproval for a particular Monster.
    /// @param _claimant the address we are confirming monster is approved for.
    /// @param _tokenId monster id, only valid when > 0
    function _approvedFor(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return equipIndexToApproved[_tokenId] == _claimant;
    }

    /// @dev Marks an address as being approved for transferFrom(), overwriting any previous
    ///  approval. Setting _approved to address(0) clears all transfer approval.
    ///  NOTE: _approve() does NOT send the Approval event. This is intentional because
    ///  _approve() and transferFrom() are used together for putting Monsters on auction, and
    ///  there is no value in spamming the log with Approval events in that case.
    function _approve(uint256 _tokenId, address _approved) internal {
        equipIndexToApproved[_tokenId] = _approved;
    }

    /// @notice Returns the number of Monsters owned by a specific address.
    /// @param _owner The owner address to check.
    /// @dev Required for ERC-721 compliance
    function balanceOf(address _owner) public view returns (uint256 count) {
        return ownershipTokenCount[_owner];
    }

    /// @notice Transfers a Monster to another address. If transferring to a smart
    ///  contract be VERY CAREFUL to ensure that it is aware of ERC-721 (or
    ///  MonsterBit specifically) or your Monster may be lost forever. Seriously.
    /// @param _to The address of the recipient, can be a user or contract.
    /// @param _tokenId The ID of the Monster to transfer.
    /// @dev Required for ERC-721 compliance.
    function transfer(
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any monsters (except very briefly
        // after a gen0 monster is created and before it goes on auction).
        require(_to != address(this));
        // Disallow transfers to the auction contracts to prevent accidental
        // misuse. Auction contracts should only take ownership of monsters
        // through the allow + transferFrom flow.
        require(_to != address(saleAuction));

        // You can only send your own monster.
        require(_owns(msg.sender, _tokenId));

        // Reassign ownership, clear pending approvals, emit Transfer event.
        _transfer(msg.sender, _to, _tokenId);
    }

    /// @notice Grant another address the right to transfer a specific Monster via
    ///  transferFrom(). This is the preferred flow for transfering NFTs to contracts.
    /// @param _to The address to be granted transfer approval. Pass address(0) to
    ///  clear all approvals.
    /// @param _tokenId The ID of the Monster that can be transferred if this call succeeds.
    /// @dev Required for ERC-721 compliance.
    function approve(
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        // Only an owner can grant transfer approval.
        require(_owns(msg.sender, _tokenId));

        // Register the approval (replacing any previous approval).
        _approve(_tokenId, _to);

        // Emit approval event.
        emit Approval(msg.sender, _to, _tokenId);
    }

    /// @notice Transfer a Monster owned by another address, for which the calling address
    ///  has previously been granted transfer approval by the owner.
    /// @param _from The address that owns the Monster to be transfered.
    /// @param _to The address that should take ownership of the Monster. Can be any address,
    ///  including the caller.
    /// @param _tokenId The ID of the Monster to be transferred.
    /// @dev Required for ERC-721 compliance.
    function transferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    )
        external
        whenNotPaused
    {
        // Safety check to prevent against an unexpected 0x0 default.
        require(_to != address(0));
        // Disallow transfers to this contract to prevent accidental misuse.
        // The contract should never own any monsters (except very briefly
        // after a gen0 monster is created and before it goes on auction).
        require(_to != address(this));
        // Check for approval and valid ownership
        require(_approvedFor(msg.sender, _tokenId));
        require(_owns(_from, _tokenId));

        // Reassign ownership (also clears pending approvals and emits Transfer event).
        _transfer(_from, _to, _tokenId);
    }

    /// @notice Returns the total number of Monsters currently in existence.
    /// @dev Required for ERC-721 compliance.
    function totalSupply() public view returns (uint) {
        return equips.length - 1;
    }

    /// @notice Returns the address currently assigned ownership of a given Monster.
    /// @dev Required for ERC-721 compliance.
    function ownerOf(uint256 _tokenId)
        external
        view
        returns (address owner)
    {
        owner = equipIndexToOwner[_tokenId];
        require(owner != address(0));
    }

    /// @notice Returns a list of all Monster IDs assigned to an address.
    /// @param _owner The owner whose Monsters we are interested in.
    /// @dev This method MUST NEVER be called by smart contract code. First, it's fairly
    ///  expensive (it walks the entire Monster array looking for monsters belonging to owner),
    ///  but it also returns a dynamic array, which is only supported for web3 calls, and
    ///  not contract-to-contract calls.
    function tokensOfOwner(address _owner) external view returns(uint256[] ownerTokens) {
        uint256 tokenCount = balanceOf(_owner);

        if (tokenCount == 0) {
            // Return an empty array
            return new uint256[](0);
        } else {
            uint256[] memory result = new uint256[](tokenCount);
            uint256 totalEquips = totalSupply();
            uint256 resultIndex = 0;

            // We count on the fact that all monsters have IDs starting at 1 and increasing
            // sequentially up to the totalMonsters count.
            uint256 id;

            for (id = 1; id <= totalEquips; id++) {
                if (equipIndexToOwner[id] == _owner) {
                    result[resultIndex] = id;
                    resultIndex++;
                }
            }

            return result;
        }
    }
    
    /// @dev Assigns ownership of a specific Monster to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        // Since the number of monsters is capped to 2^32 we can't overflow this
        uint count = ownershipTokenCount[_to];
        ownershipTokenCount[_to] = count + 1;
        
        // transfer ownership
        equipIndexToOwner[_tokenId] = _to;
        // When creating new monsters _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            count =  ownershipTokenCount[_from];
            ownershipTokenCount[_from] = count - 1;
            // clear any previously approved ownership exchange
            equipIndexToApproved[_tokenId] = address(0);
        }
        
        // Emit the transfer event.
        emit Transfer(_from, _to, _tokenId);
    }
    
}

contract MonsterEquipRepair is MonsterEquipERC
{
    mapping (uint8 => uint) public repairPrices;
    event Repair(uint equipId);
    
    constructor() public
    {
        repairPrices[111] = 1 ether;
    }
    
    function setRepairPrice(uint _typeCode, uint price) onlyCLevel public
    {
        require(uint(uint8(_typeCode)) == _typeCode);
        repairPrices[uint8(_typeCode)] = price;
    }
    
    function repair(uint _eqId) external payable
    {
        Equip storage eq = equips[_eqId];
        uint price = repairPrices[eq.typeCode];
        
        require(msg.value >= price);
        
        emit Repair(_eqId);
        
        msg.sender.transfer(msg.value - price);
    }
}

contract MonsterEquipAuc is MonsterEquipRepair
{
    function setSaleAuctionAddress(address _address) external onlyCEO {
        SaleClockAuction candidateContract = SaleClockAuction(_address);

        // NOTE: verify that a contract is what we expect - https://github.com/Lunyr/crowdsale-contracts/blob/cfadd15986c30521d8ba7d5b6f57b4fefcc7ac38/contracts/LunyrToken.sol#L117
        require(candidateContract.isSaleClockAuction());

        // Set the new contract address
        saleAuction = candidateContract;
    }


    /// @dev Put a monster up for auction.
    ///  Does some ownership trickery to create auctions in one tx.
    function createSaleAuction(
        uint256 _equipId,
        uint256 _startingPrice,
        uint256 _endingPrice,
        uint256 _duration
    )
        external
        whenNotPaused
    {
        // Auction contract checks input sizes
        // If monster is already on any auction, this will throw
        // because it will be owned by the auction contract.
        require(_owns(msg.sender, _equipId));
        // Ensure the monster is not pregnant to prevent the auction
        // contract accidentally receiving ownership of the child.
        // NOTE: the monster IS allowed to be in a cooldown.
        
        _approve(_equipId, saleAuction);
        // Sale auction throws if inputs are invalid and clears
        // transfer and sire approval after escrowing the monster.
        saleAuction.createAuction(
            _equipId,
            _startingPrice,
            _endingPrice,
            _duration,
            msg.sender
        );
    }
}

contract MonsterEquipMinting is MonsterEquipAuc
{
    
    function _createEquipOwned(uint _typeCode, address _owner) internal returns(uint)
    {
        require(uint(uint8(_typeCode)) == _typeCode);
        
        Equip memory eq = Equip({typeCode: uint8(_typeCode)});
        uint newEquipId = _createEquip(eq);
        _transfer(address(0), address(_owner), newEquipId);
        return newEquipId;
    }
    
    function createAuctionCustom(uint _typeCode, uint _startingPrice, uint _endingPrice, uint _duration) external onlyCOO {
        uint256 equipId = _createEquipOwned(_typeCode, address(this));
        _approve(equipId, saleAuction);

        saleAuction.createAuction(
            equipId,
            _startingPrice,
            _endingPrice,
            _duration,
            address(this)
        );
    }
    
    function createPromoEquip(uint _typeCode, address _owner) external onlyCOO {
        address eqOwner = _owner;
        if (eqOwner == address(0)) {
             eqOwner = eqOwner;
        }
        
        _createEquipOwned(_typeCode, address(_owner));
    }
    
    mapping (uint8 => uint) public publicMintablePrices;
    
    function setPublicMintablePrice(uint _typeCode, uint _price) onlyCLevel external
    {
        require(uint(uint8(_typeCode)) == _typeCode);
        require(_price > 0);
        
        publicMintablePrices[uint8(_typeCode)] = _price;
    }
    
    function deletePublicMintablePrice(uint _typeCode) onlyCLevel external
    {
        require(uint(uint8(_typeCode)) == _typeCode);
        delete publicMintablePrices[uint8(_typeCode)];
    }
    
    function publicMint(uint _typeCode) public payable
    {
        require(uint(uint8(_typeCode)) == _typeCode);
        uint price = publicMintablePrices[uint8(_typeCode)];
        require(price > 0);
        
        require(msg.value >= price);
        
        _createEquipOwned(_typeCode, address(msg.sender));
        
        address(msg.sender).transfer(msg.value - price);
    }
}

contract MonsterEquip is MonsterEquipMinting
{
    
    constructor() public {
        // Starts paused.
        paused = true;
        ceoAddress = msg.sender;
        cooAddress = msg.sender;
    }
    
    function withdrawDependentBalances() external onlyCFO {
        saleAuction.withdrawBalance();
    }
    
    function withdrawBalance() external onlyCFO {
        uint256 balance = address(this).balance;
        address(msg.sender).transfer(balance);
    }
    
    function unpause() public onlyCEO whenPaused  {
        require(saleAuction != address(0));
        super.unpause();
    }
    
    function() external payable {
        require(msg.sender == address(saleAuction));
    }
    
    
    
}