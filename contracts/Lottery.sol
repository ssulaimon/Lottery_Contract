//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/vrf/VRFConsumerBase.sol";
contract Lottery is VRFConsumerBase{
    address owner;
    AggregatorV3Interface priceFeed;
    uint256 entryPrice;
    uint256 maxPayAmont;
    bytes32 keyHash;
    uint256 linkFee;
    uint256 winner;

    constructor(address _priceFeed, uint256 _entryFee, uint256 _maxPayAmount, address _vrf, address _linkToken, bytes32 _keyHash, uint256 _fee) VRFConsumerBase(_vrf, _linkToken){
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeed);
        entryPrice = _entryFee * (10**18);
        maxPayAmont = _maxPayAmount * (10**18);
        keyHash = _keyHash;
        linkFee = _fee;
    }
    string public fee = Strings.toString(entryPrice / (10**18));
    string public feeMax = Strings.toString(maxPayAmont / (10**18));
    struct Player{
        address payable playerAddress;
        uint256 amountPlayed;
    }
    Player[] public players;
    enum Status{
        CLOSED,
        START,
        ENDED
    }
     Status public lotteryStatus = Status.CLOSED;
    //minimum amunt to play 
    function entryFee()public view returns(uint256){
        (,int256 answer,,,) = priceFeed.latestRoundData();
        uint256 ethPrice = uint256(answer) *10**10;
        uint256 price = (entryPrice * 10**18) / ethPrice;
        return price;
    }
    function maxFee()public view returns(uint256){
        (, int256 answer,,,) = priceFeed.latestRoundData();
        uint256 ethPrice = uint256(answer) * 10**10;
        uint256 price = (maxPayAmont * 10 **18)/ ethPrice;
        return price; 

    }
     modifier mnimumAmountSent{
    require(msg.value >= entryFee(), string(abi.encodePacked("Minimum amount required is ", fee)));
    _;
   }
   modifier maximumAmountSent{
    require(msg.value <= maxPayAmont , string(abi.encodePacked("The maximum amount required ", maxPayAmont)));
    _;
    
   }
    // player adding their money
    function fund()public payable mnimumAmountSent maximumAmountSent{

        Player memory player = Player({playerAddress: payable(msg.sender), amountPlayed: msg.value});
        players.push(player);
        

    }
    modifier checkingstatus{
        require(lotteryStatus == Status.ENDED, "You can select winner when the lottery is ended");
        _;
    }


   //selecting a random winner of the lottery and lottery is closed  and also request for a random number 
  
    function selectWinner()public payable checkingstatus onlyOwner {
        require(lotteryStatus == Status.CLOSED, "This function can only be called when the lottery is closed ");
        bytes32 requestId = requestRandomness(keyHash, linkFee);

        

    }
    // this function is called by the chianlink node that response the random number 
    function fulfillRandomness(bytes32 _requestId, uint256 _randomness) internal override{
        uint256 winnerIndex = _randomness % players.length;
        winner = winnerIndex;
    }

    modifier onlyOwner{
        require(msg.sender == owner, "Only owner an call this function");
        _;
    }
    //deployer changing the lottery status 
    function changeLotteryStatus(Status _status) public onlyOwner{
        lotteryStatus = _status;
    }

    //check how much have been locked in the contract 
    function checkContractBalance() public view returns(uint256){
        return address(this).balance;
    }
}