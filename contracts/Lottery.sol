//SPDX-License-Identifier:MIT
pragma solidity >=0.8.0 <0.9.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
contract Lottery{
    address owner;
    AggregatorV3Interface priceFeed;
    uint256 entryPrice;
    uint256 maxPayAmont;
    constructor(address _priceFeed, uint256 _entryFee, uint256 _maxPayAmount){
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeed);
        entryPrice = _entryFee * (10**18);
        maxPayAmont = _maxPayAmount * (10**18);
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
   //selecting a random winner of the lottery and lottery is closed 
  
    function selectWinner()public payable checkingstatus{}

    modifier onlyOwner{
        require(msg.sender == owner, "Only owner an call this function");
        _;
    }
    //deployer changing the lottery status 
    function changeLotteryStatus() public onlyOwner{

    }

    //check how much have been locked in the contract 
    function checkContractBalance() public view returns(uint256){
        return address(this).balance;
    }
}