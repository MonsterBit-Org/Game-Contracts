pragma solidity ^0.4.23;

import "./ERC721.sol";
import "./Pausable.sol";
import "./MonsterLib.sol";

contract MonsterBattles is Pausable {
    // Reference to contract tracking NFT ownership
    ERC721 public nonFungibleContract;
    
    bool public isBattleContract = true;
    address public backendAddress;
    address public ownerAddress;
    uint availableProfit = 0;
    
    
    constructor(address _nftAddress) public {
        ERC721 candidateContract = ERC721(_nftAddress);
        nonFungibleContract = candidateContract;
        backendAddress = msg.sender;
    }
    
    /// @dev Access modifier for CFO-only functionality
    modifier onlyBackend() {
        require(msg.sender == backendAddress);
        _;
    }
    
    modifier onlyProxy() {
        require(msg.sender == address(nonFungibleContract));
        _;
    }
    
    function setTokenContract(address _nftAddress) external onlyOwner
    {
        ERC721 candidateContract = ERC721(_nftAddress);
        nonFungibleContract = candidateContract;
    }
    
    function setBackendAddress(address _backend) external onlyOwner
    {
        backendAddress = _backend;
    }
    
    function withdrawBalance() external {
        address nftAddress = address(nonFungibleContract);

        require(
            msg.sender == ownerAddress ||
            msg.sender == nftAddress
        );
        // We are using this boolean method to make sure that even if one fails it will still work
        uint sending = availableProfit;    
        availableProfit = 0;
        nftAddress.send(sending);
    }
    
    /// @dev Returns true if the claimant owns the token.
    /// @param _claimant - Address claiming to own the token.
    /// @param _tokenId - ID of token whose ownership to verify.
    function _owns(address _claimant, uint256 _tokenId) internal view returns (bool) {
        return (nonFungibleContract.ownerOf(_tokenId) == _claimant);
    }
    
    //struct BattleBet
    //{
    //    uint32[] monsterIds;
    //    address owner;
    //}
    
    //BattleBet[] battleBets;
    
    uint256 public oneOnOneBet = 2 finney;
    uint256 public teamfightBet = 5 finney;
    
    function setOneOnOneBet(uint256 val) external onlyOwner {
        oneOnOneBet = val;
    }
    
    function setTeamfightBet(uint256 val) external onlyOwner {
        teamfightBet = val;
    }
    
    event BattleBetPlaced(address better, uint monster1, uint monster2, uint monster3);
    
    function prepareForBattle(address _originalCaller, uint _param1, uint _param2, uint _param3) public payable onlyProxy whenNotPaused returns(uint){
        require(_param1 > 0);
        require(_param2 > 0);
        require(_param3 > 0);
        
        require(_originalCaller != 0);
        
        uint mode = MonsterLib.getBits(_param3, 0, 8);
        uint betMode = MonsterLib.getBits(_param3, 8, 8);
        
        if(mode == 1){ // one one one
          if(betMode == 1)
          {
             require(msg.value >= oneOnOneBet);
             emit BattleBetPlaced(_originalCaller, 0, 0, 0);
          }
          else
          {
              uint monsterId = MonsterLib.getBits(_param1, 0, uint8(32));
              nonFungibleContract.transferFrom(_originalCaller, address(this), monsterId);
              emit BattleBetPlaced(_originalCaller, monsterId, 0, 0);
          }
        }
        else if(mode == 2){ // teamfight
          if(betMode == 1)
          {
            require(msg.value >= teamfightBet);  
            emit BattleBetPlaced(_originalCaller, 0, 0, 0);
          }
          else{
              uint monsterId1 = MonsterLib.getBits(_param1, uint8(0), uint8(32));
              uint monsterId2 = MonsterLib.getBits(_param1, uint8(32), uint8(32));
              uint monsterId3 = MonsterLib.getBits(_param1, uint8(64), uint8(32));
              nonFungibleContract.transferFrom(_originalCaller, address(this), monsterId1);
              nonFungibleContract.transferFrom(_originalCaller, address(this), monsterId2);
              nonFungibleContract.transferFrom(_originalCaller, address(this), monsterId3);
              emit BattleBetPlaced(_originalCaller, monsterId1, monsterId2, monsterId3);
          }
        }
    }
    
    function withdrawFromBattle(address _originalCaller, uint _param1, uint _param2, uint _param3) onlyProxy public returns(uint){

        require(_originalCaller == backendAddress);
        
        address winner = address(_param1);
        uint win = MonsterLib.getBits(_param3, 0, 128);
        uint profit = MonsterLib.getBits(_param3, 128, 128);
        availableProfit += profit;
        
        winner.transfer(win);
        
        //BattleBet storage _bet = battleBets[_param1];
        //uint i = 0;
        //for(i = 0; i< _bet.monsterIds.length; i++){
        //    nonFungibleContract.transfer(_bet.owner, _bet.monsterIds[i]);
        //}
    }
    
    function finishBattle(address _originalCaller, uint _param1, uint _param2, uint _param3) public onlyProxy returns(uint return1, uint return2, uint return3) {
        require(_originalCaller == backendAddress);

        
        //return1 reserved for monster ids (8 items)
        //return2 0-64 reserved for monster ids (2 items)
        return1 = 0;
        return2 = 0; 
        return3 = 0;
        
        
        uint win = MonsterLib.getBits(_param3, 0, 128);
        uint profit = MonsterLib.getBits(_param3, 128, 128);
        availableProfit += profit;
        
        address winner = address(_param1);
        for(uint i = 0; i < 6; i++)
        {
          uint monsterId = MonsterLib.getBits(_param2, uint8(i * 32), uint8(32));
          if(monsterId > 0)
          {
            if(nonFungibleContract.ownerOf(monsterId) == address(this))
            {
              nonFungibleContract.transfer(winner, monsterId);
            }
          }
        } 
        
        winner.transfer(win);
        
    }
    
    
}