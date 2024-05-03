// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Block_X {
    uint256 constant MAX_CHARACTER_AMOUNT = 140;

    struct Bloc {
        string content;
        address owner;
        uint256 timestamp;
        bytes32 uniqueIdentifier; 
    }

    mapping(address => Bloc[]) public userBlocs;
    mapping(address => uint256) public BlocTips;

    event BlocUpdated(address indexed user, string Bloc, uint256 timestamp, bytes32 uniqueId);
    event BlocTipped(address indexed from, address indexed to, uint256 amount);
    event BlocDeleted(address indexed user, string Bloc, uint256 timestamp, bytes32 uniqueId);

    function setBloc(string memory _Bloc) public {
        require(bytes(_Bloc).length <= MAX_CHARACTER_AMOUNT, "Bloc is too long");
        bytes32 uniqueId = keccak256(abi.encodePacked(block.timestamp, _Bloc, msg.sender));
        userBlocs[msg.sender].push(Bloc(_Bloc, msg.sender, block.timestamp, uniqueId));
        emit BlocUpdated(msg.sender, _Bloc, block.timestamp, uniqueId);
    }

    function getBlocTip(address _address) public view returns (uint256) {
        return BlocTips[_address];
    }

    function tipBloc(address _to) public payable {
        require(msg.value > 0, "Tip amount must be greater than zero");
        require(userBlocs[_to].length > 0, "Recipient must not have a bloc");
        uint256 tipAmount = msg.value;
        BlocTips[_to] += tipAmount;
        payable(_to).transfer(tipAmount);
    }

   function deleteBloc(bytes32 _uniqueId) public {
    uint256 blocCount = userBlocs[msg.sender].length;
    require(blocCount > 0, "No blocs found for this user");
    uint256 blocIndexToDelete = blocCount+10;

    for (uint256 i = 0; i < blocCount; i++) {
        if (userBlocs[msg.sender][i].uniqueIdentifier == _uniqueId) {
            blocIndexToDelete = i;
            break;
        }
    }

    require(blocIndexToDelete != blocCount + 10, "Bloc with the given unique ID not found");
    require(userBlocs[msg.sender][blocIndexToDelete].owner == msg.sender, "You are not the owner of this bloc");

    string memory deletedBloc = userBlocs[msg.sender][blocIndexToDelete].content;
    delete userBlocs[msg.sender][blocIndexToDelete];
    emit BlocDeleted(msg.sender, deletedBloc, block.timestamp, _uniqueId);
    }
}
