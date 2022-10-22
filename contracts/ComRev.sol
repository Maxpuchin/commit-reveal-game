pragma solidity ^0.8.0;

contract ComRev {
    // схема ComRev была использована
    // чтобы нельзя было до окончания всех ходов понять,
    // кто как сходил.

    // Для тестирования кодировал через консоль:
    // закрытый ключ hardhat ether.utils.formatBytes32String('secret')
    // кто-то выбирает камень: ethers.utils.solidityKeccak256(["uint", "bytes32", "address"], ["1", "0x7365637265740000000000000000000000000000000000000000000000000000", "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2"])


    address[] public players = new address[](2);

    mapping (address => bytes32) public commits;
    mapping (address => uint) public player2move;
    event moneyGot(address indexed _from, uint _value);

    uint playersRevealed = 0;
    uint currentPlayer = 0;

    modifier gameFinished {
        require(currentPlayer == 2);
        _;
    }

    function commitMove(bytes32 _hashedMove) external payable {
        require(currentPlayer < 2);
        require(commits[msg.sender] == bytes32(0));

        players[currentPlayer] = msg.sender;
        commits[msg.sender] = _hashedMove;
        currentPlayer += 1;
        
        emit moneyGot(msg.sender, msg.value);
    }

    function revealMove(uint _move, bytes32 _secret) external gameFinished {
        // 1 - камень
        // 2 - бумага
        // 3 - ножницы

        require(playersRevealed < 2);

        bytes32 commit = keccak256(abi.encodePacked(_move, _secret, msg.sender));
        
        require(commit == commits[msg.sender]);
        require(player2move[msg.sender] == 0);

        delete commits[msg.sender];
        player2move[msg.sender] = _move;
        playersRevealed += 1;
    }

    function payToWinner() external gameFinished {
        require(currentPlayer == 2);
        
        address payable firstPlayer = payable(players[0]);
        address payable secondPlayer = payable(players[1]);

        uint firstPlayerMove = player2move[firstPlayer];
        uint secondPlayerMove = player2move[secondPlayer];

        if(firstPlayerMove == 1 && secondPlayerMove == 3) {
            firstPlayer.transfer(address(this).balance);
        } else if (firstPlayerMove == 2 && secondPlayerMove == 1) {
            firstPlayer.transfer(address(this).balance);
        } else if (firstPlayerMove == 3 && secondPlayerMove == 2) {
            firstPlayer.transfer(address(this).balance);
        } else {
            secondPlayer.transfer(address(this).balance);
        }
    }
}