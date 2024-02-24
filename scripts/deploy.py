from brownie import Lottery
from scripts.helper import walletAddress, contractAddress


def deploy_contract():
    contract = Lottery[-1]
    print(contract.maxFee())


def main():
    deploy_contract()
