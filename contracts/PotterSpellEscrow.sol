// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title PotterSpellEscrow
 * @dev Autonomous Algorithmic Magic & Patronus PQC Escrow Protocol
 */
contract PotterSpellEscrow {
    struct SpellChannel {
        address wizard;
        address caster;
        uint256 manaDeposit;
        uint256 castAmount;
        bytes32 spellHash;
        bool isEnchanted;
    }

    mapping(bytes32 => SpellChannel) public spellChannels;
    address public immutable hogwartsTreasury;

    event SpellCast(bytes32 indexed channelId, address indexed wizard, address indexed caster, uint256 mana);
    event SpellSettled(bytes32 indexed channelId, uint256 mana, bytes32 patronusProof);
    event CounterCurseTriggered(bytes32 indexed channelId, string reason);

    constructor(address _treasury) {
        require(_treasury != address(0), "Invalid treasury");
        hogwartsTreasury = _treasury;
    }

    function castSpell(bytes32 channelId, address caster, bytes32 spellHash) external payable {
        require(msg.value > 0, "Mana required");
        require(!spellChannels[channelId].isEnchanted, "Spell already enchanted");

        spellChannels[channelId] = SpellChannel({
            wizard: msg.sender,
            caster: caster,
            manaDeposit: msg.value,
            castAmount: 0,
            spellHash: spellHash,
            isEnchanted: true
        });

        emit SpellCast(channelId, msg.sender, caster, msg.value);
    }

    function settleSpell(bytes32 channelId, uint256 mana, bytes32 patronusProof) external {
        SpellChannel storage sc = spellChannels[channelId];
        require(sc.isEnchanted, "Channel not enchanted");
        require(msg.sender == sc.wizard || msg.sender == sc.caster, "Unauthorized wizard");
        require(sc.castAmount + mana <= sc.manaDeposit, "Exceeds mana deposit");

        sc.castAmount += mana;
        payable(sc.caster).transfer(mana);

        emit SpellSettled(channelId, mana, patronusProof);
    }
}
