from brownie import Lottery
from scripts.helper import walletAddress, contractAddress


def deploy_contract():
    address = walletAddress()
    price_feed = contractAddress()
    contract = Lottery.deploy(
        price_feed,
        50,
        100,
        {
            "from": address,
        },
    )


def main():
    deploy_contract()
