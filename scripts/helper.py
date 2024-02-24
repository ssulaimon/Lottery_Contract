from brownie import accounts, config, network


def walletAddress() -> str:
    if network.show_active() == "development":
        return accounts[0]
    else:
        return accounts.add(config["wallet"][network.show_active()])


def contractAddress() -> str:
    if network.show_active() == "development":
        return ""
    else:
        return config["networks"][network.show_active()]["eth_usd_contract"]
