from brownie import Lottery, config, network, accounts
from web3 import Web3
from scripts.helper import walletAddress


def test_checkMinum():
    contract = Lottery[-1]
    entryFee = contract.entryFee()
    assert Web3.to_wei(0.009, "ether") < entryFee


def test_checkMaxFee():
    contract = Lottery[-1]
    maxFee = contract.maxFee()
    assert Web3.to_wei(0.1, "ether") > maxFee


def test_enum():
    contract = Lottery[-1]
    change_status = contract.changeLotteryStatus(
        1,
        {
            "from": walletAddress(),
        },
    )
    change_status.wait(1)
    status = contract.lotteryStatus()

    assert status == 1
