pragma solidity ^0.4.23;

import "./ERC721.sol";
import "./Pausable.sol";

contract MonsterLottery is Ownable
{
    
    ERC721 public nonFungibleContract;
    address backendAddress;
    uint public minimalBet = 10 finney;
    
    constructor(address _nftAddress, address _backend) public {
        require(_nftAddress != address(0));
        require(_backend != address(0));
        ERC721 candidateContract = ERC721(_nftAddress);
        nonFungibleContract = candidateContract;
        backendAddress = _backend;
        _createLottery(0, true, 0);
    }
    
    struct Bet
    {
        address sender;
        uint amount;
    }
    
    struct Lottery {
        uint32 monsterId;
        uint totalBet;
        uint64 endTimestamp;
        bool finished;
        uint[] betIds;
        address winner;
    }
    
    event LotteryStarted(uint lotteryId, uint monsterId, uint endTimestamp);
    event LotteryFinished(uint lotteryId, uint monsterId, address winner);
    event BetPlaced(uint lotteryId, uint monsterId, address sender, uint amount);
    
    Lottery[] lotteries;
    Bet[] bets;
    
    uint activeLottery = 0;
    
    modifier onlyAuthorized() 
    {
      require(msg.sender == owner || msg.sender == backendAddress);
      _;
    }
    
    function _createLottery(uint monsterId, bool finished, uint endTimestamp) internal returns(uint)
    {
        Lottery memory _lottery;
        _lottery.monsterId = uint32(monsterId);
        _lottery.finished = finished;
        _lottery.endTimestamp = uint64(endTimestamp);
        uint index = lotteries.push(_lottery) - 1;
        return index;
    }
    
    function _saveBet(address sender, uint amount) internal returns(uint)
    {
        Bet memory _bet;
        _bet.sender = sender;
        _bet.amount = amount;
        uint index = bets.push(_bet) - 1;
        return index;
    }
    
    function _isActive() internal view returns(bool) 
    {
        Lottery storage _lottery = lotteries[activeLottery];
        return !_lottery.finished;
    }
    
    function setMinimalBet(uint256 val) external onlyAuthorized {
        minimalBet = val;
    }
    
    function startLottery(uint monsterId, uint endTimestamp) onlyAuthorized external
    {
        require(uint(uint32(monsterId)) == monsterId);
        require(uint(uint64(endTimestamp)) == endTimestamp);
        require(!_isActive());
        require(nonFungibleContract.ownerOf(monsterId) == address(this));
        activeLottery = _createLottery(monsterId, false, endTimestamp);
        emit LotteryStarted(activeLottery, monsterId, endTimestamp);
    }
    
    function bet() external payable
    {
        require(_isActive());
        require(msg.value >= minimalBet && msg.value > 0);
        Lottery storage _lottery = lotteries[activeLottery];
        
        uint betIndex = _saveBet(msg.sender, msg.value);
        _lottery.betIds.push(betIndex);
        _lottery.totalBet += msg.value;
        
        emit BetPlaced(activeLottery, _lottery.monsterId, msg.sender, msg.value);
    }
    
    function _random() internal view returns (uint) 
    {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty)));
    }
    
    function finishLottery() onlyAuthorized external
    {
        Lottery storage _lottery = lotteries[activeLottery];
        require(!_lottery.finished);
        require(_lottery.betIds.length > 0);
        
        uint endpoint = _random() % _lottery.totalBet;
        uint currentValue = 0;
        address winner = address(0);
        
        for (uint i = 0; i < _lottery.betIds.length; i++) 
        {
            Bet storage _bet = bets[_lottery.betIds[i]];
            currentValue += _bet.amount;
            if(currentValue > endpoint)
            {
                winner = _bet.sender;
                break;
            }
        }
        
        if(winner == address(0))
        {
            winner = bets[_lottery.betIds[_lottery.betIds.length - 1]].sender;
        }
        
        nonFungibleContract.transfer(winner, _lottery.monsterId);
        _lottery.finished = true;
        _lottery.winner = winner;
        
        emit LotteryFinished(activeLottery, _lottery.monsterId, winner);
    }
    
    function withdrawBalance() external {
        address nftAddress = address(nonFungibleContract);

        require(
            msg.sender == owner ||
            msg.sender == nftAddress
        );
        
        msg.sender.transfer(address(this).balance);
    }
    
    function getActiveLottery() external view returns(uint lotteryId, uint monsterId, uint totalBet, bool finished, uint endTimestamp)
    {
        Lottery storage _lottery = lotteries[activeLottery];
        lotteryId = activeLottery;
        monsterId = _lottery.monsterId;
        totalBet = _lottery.totalBet;
        finished = _lottery.finished;
        endTimestamp = _lottery.endTimestamp;
    }
}