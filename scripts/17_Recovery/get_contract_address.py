import rlp
from eth_utils import keccak, to_checksum_address, to_bytes


def mk_contract_address(sender: str, nonce: int) -> str:
    """Create a contract address using eth-utils.

    # https://ethereum.stackexchange.com/a/761/620
    """
    sender_bytes = to_bytes(hexstr=sender)
    raw = rlp.encode([sender_bytes, nonce])
    h = keccak(raw)
    address_bytes = h[12:]
    return to_checksum_address(address_bytes)


def main():
    challenge_address = '0xb780e10749E56c44951595878e1c1634F5BC14e2'
    contract_address = mk_contract_address(challenge_address, 1)
    print(f'contract address is: {contract_address}')
    return contract_address
