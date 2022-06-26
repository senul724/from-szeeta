const abi = {

  ticketGet: [
    "function walletOfOwner(address person) public view returns (uint256[] memory)",
    "function tokenURI(uint tokenId) public view virtual override returns(string memory)",
  ],

  ticketSet: [
    "function mintTicket(address to) external payable valid notPaused",
    "function Withdraw() external onlyOwner",
    "function changeState() external valid onlyOwner",
    "function dropContributors(address person) external onlyOwner valid",
    "function addContributors(address person) external onlyOwner valid",
    "function changeMintAmount(uint maxMints) external onlyOwner valid",
    "function changeEndTime(uint time) external onlyOwner valid",
    "function changeStartTime(uint time) external onlyOwner valid",
    "function changeBase(string memory base_) external onlyOwner valid",
    "function changePrice(uint newPriceInWei) external onlyOwner valid",
  ],

  preMintTicketGet: [],

  preMintTicketSet: [
    "function Withdraw() external onlyOwner",
    "function changeState() external valid onlyOwner",
    "function dropContributors(address person) external onlyOwner valid",
    "function addContributors(address person) external onlyOwner valid",
    "function changeEndTime(uint time) external onlyOwner valid",
    "function changeStartTime(uint time) external onlyOwner valid",
  ],

  factoryGet: [
    "function getEventInfo(uint eventId) external view returns(address, address)",
    "function getEventAddresses() external view returns(address[])",
    "function getUserEvents(address user) external view returns(uint[] memory, address[] memory)",
    "function getBuyerTickets(address buyer) external view returns(uint[] memory)",
  ],

  factorySet: [
    "function addEvent(address owner__,string[] memory nameandSymbol__, string memory cid__,uint supply__,uint maxMints__,uint priceInWei__,uint startTime__,uint endTime__) external returns(address)",
  ],

  preMintFactorySet: [
    "function addEvent(address owner__,address collection__, uint startTime__,uint endTime__) external payable returns(address)",
  ],

  routerGet: [
    "function Check(address person, uint amount, address contract_) public view returns(bool, uint[] memory)",
  ],

  routerSet: [
    "function BulkMint(address contract_, uint amount, address to) external payable",
    "function Mark(address person,uint amount, address contract_) external returns(uint[] memory)",
    "function DropContributors(address[] memory list, address contract_) external",
    "function AddContributors(address[] memory list, address contract_) external",
  ],

  preMintRouterSet: [
    "function Mark(address person,uint amount, address contract_) external returns(uint[] memory)",
    "function DropContributors(address[] memory list, address contract_) external",
    "function AddContributors(address[] memory list, address contract_) external",
  ],
};

const addresses = {
  factory: {
    5777: "0x6833e72e34b8A517DC4428Baa49868C3e5b7F3c4",
  },
  preMintFactory: {},
  router: {},
  preMintRouter: {}
};


// ** Exports ** //
export { abi };
export { addresses };
