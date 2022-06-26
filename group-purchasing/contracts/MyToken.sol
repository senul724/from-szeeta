// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract MyToken is ERC721{

    uint public id = 1;

    constructor() ERC721("MyToken", "MTK") {
            safeMint();
        }

    function safeMint() public{
        _safeMint(msg.sender, id);
        id ++;
    }
}
