pragma solidity ^0.4.23;

import "./ERC721.sol";
import "./MonsterLib.sol";

contract MonsterFood {
    
    ERC721 public nonFungibleContract;
    
    bool public isMonsterFood = true;
    
    uint32 potionDuration = uint32(6 hours);
    
    event PotionCreated(uint code);
    event PotionDeleted(uint code);
    
    constructor(address _nftAddress) public {
        ownerAddress = msg.sender;
        ERC721 candidateContract = ERC721(_nftAddress);
        nonFungibleContract = candidateContract;
    }
    
    modifier onlyOwner() {
        require(msg.sender == ownerAddress);
        _;
    }
    
    modifier onlyCore() {
        require(msg.sender == address(nonFungibleContract));
        _;
    }
    
    function setTokenContract(address _nftAddress) external onlyOwner
    {
        ERC721 candidateContract = ERC721(_nftAddress);
        nonFungibleContract = candidateContract;
    }
    
    uint[] public cdPricesGrow = [
        10000 szabo,
        20000 szabo,
        30000 szabo,
        40000 szabo,
        50000 szabo,
        55000 szabo,
        60000 szabo,
        65000 szabo,
        70000 szabo,
        80000 szabo,
        85000 szabo,
        90000 szabo,
        108000 szabo,
        120000 szabo
        ];

    
    
    uint[] public cdPricesRest = [
        10000 szabo,
        20000 szabo,
        30000 szabo,
        40000 szabo,
        50000 szabo,
        55000 szabo,
        60000 szabo,
        65000 szabo,
        70000 szabo,
        80000 szabo,
        85000 szabo,
        90000 szabo,
        108000 szabo,
        120000 szabo
    ];
    
   
    struct Potion {
        uint16 code;
        uint256 priceWei;
        uint8 potionEffect;
        bool exists;
    }
    
    uint256 public feedingFee = 5 finney;
    
    function setFeedingFee(uint256 val) external onlyOwner {
        feedingFee = val;
    }
    
    address public ownerAddress;
    
    mapping (uint16 => Potion) codeToPotionIndex;
    
    function setOwner(address newOwner) public onlyOwner{
        require(newOwner != address(0));
        ownerAddress = newOwner;
    }
    
   
    function setPotionDuration(uint newDuration) external onlyOwner{
        require(newDuration > 0);
        potionDuration = uint32(newDuration);
    }
    
    function createPotion(uint _priceWei, uint _code, uint _potionEffect) external onlyOwner returns(uint) {
        require(_code > 2 && _potionEffect > 0);
        require(_code == uint(uint16(_code)));
        
        Potion memory _potion = Potion({
            priceWei: _priceWei,
            code: uint16(_code),
            potionEffect: uint8(_potionEffect),
            exists: true
        });
        
        codeToPotionIndex[uint16(_code)] = _potion;
        
        emit PotionCreated(_potion.code);
        return _potion.code;
    }
    
    function feedMonster(address originalCaller, uint foodCode, uint p1, uint p2, uint p3) onlyCore public payable
    returns(uint p1_, uint p2_, uint p3_)
    {
        require(foodCode == 1 || foodCode == 2);
        require(originalCaller != address(0));
        
       
        MonsterLib.Monster memory mon = MonsterLib.decodeMonsterBits(p1, p2, p3);
        
        if(foodCode == 1) // grow
        {
            applyGrow(originalCaller, mon);
        } 
        else if(foodCode == 2)
        {
            applyCDR(originalCaller, mon);
        }
        
        //applyPotion(_food, mon);

        (p1_, p2_, p3_) = MonsterLib.encodeMonsterBits(mon);
    }
    
    

    
    function applyCDR(address originalCaller, MonsterLib.Monster monster) internal
    {
        require(monster.cooldownEndTimestamp > now);
        require(monster.cooldownEndTimestamp > monster.cooldownStartTimestamp);
        uint totalPriceWei = cdPricesRest[monster.activeRestCooldownIndex];
        uint totalCdLength = monster.cooldownEndTimestamp - monster.cooldownStartTimestamp;
        uint remainingCdLength = monster.cooldownEndTimestamp - now;
        
        uint price = (10000 * remainingCdLength / totalCdLength) * totalPriceWei / 10000;
        price += feedingFee;
        require(msg.value >= price);
        
        monster.cooldownEndTimestamp = uint64(now);
        monster.activeRestCooldownIndex = 0;
        monster.activeGrowCooldownIndex = 0;
        
        originalCaller.transfer(msg.value - price);
    }
    
    function applyGrow(address originalCaller, MonsterLib.Monster monster)  internal 
    {
        require(monster.level < 1);
        require(monster.cooldownEndTimestamp > monster.cooldownStartTimestamp);
        
        uint totalPriceWei = cdPricesGrow[monster.activeRestCooldownIndex];
        uint totalCdLength = monster.cooldownEndTimestamp - monster.cooldownStartTimestamp;
        
        uint remainingCdLength = 0;
        if(monster.cooldownEndTimestamp > now)
        {
            remainingCdLength = monster.cooldownEndTimestamp - now;
        }

        uint price = (10000 * remainingCdLength / totalCdLength) * totalPriceWei / 10000;
        price += feedingFee;
        require(msg.value >= price);
        
        monster.level = 1;
        monster.cooldownEndTimestamp = uint64(now);
        monster.activeRestCooldownIndex = 0;
        monster.activeGrowCooldownIndex = 0;
        
        originalCaller.transfer(msg.value - price);
        
    }
    

    function getPotion(uint256 _potionCode)
        external
        view
        returns (
        uint256 priceWei,
        uint256 potionEffect,
        bool exists
    ) {
        Potion storage _potion = codeToPotionIndex[uint16(_potionCode)];
        require(_potion.exists);
        exists = _potion.exists;
        priceWei = _potion.priceWei;
        potionEffect = _potion.potionEffect;
    }
    
    
    function deletePotion(uint _code) public onlyOwner {
        delete codeToPotionIndex[uint16(_code)];
        emit PotionDeleted(_code);
    }
    
    function withdrawBalance() external {
        address nftAddress = address(nonFungibleContract);

        require(
            msg.sender == ownerAddress ||
            msg.sender == nftAddress
        );
        // We are using this boolean method to make sure that even if one fails it will still work
        nftAddress.transfer(address(this).balance);
    }
}
    
    
