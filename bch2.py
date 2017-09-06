#!/usr/bin/python

import hashlib as hasher
import datetime as date

from flask import Flask
from flask import reqeust


class Block:
    def __init__(self, index, timestamp, data, previous_hash):
        self.index = index
        self.timestamp = timestamp
        self.data = data
        self.previous_hash = previous_hash
        self.hash = self.hash_block()

    def hash_block(self):
        sha = hasher.sha256()
        sha.update(str(self.index) +
                   str(self.timestamp) +
                   str(self.data) +
                   str(self.previous_hash))
        return sha.hexdigest()


def create_genesis_block():
    return Block(0, date.datetime.now(), 'Genesis Block', '0')


def next_block(last_block):
    this_index = last_block.index + 1
    this_timestamp = date.datetime.now()
    this_data = 'Hey! Im block ' + str(this_index)
    this_hash = last_block.hash
    return Block(this_index, this_timestamp, this_data, this_hash)


blockchain = [create_genesis_block()]
previous_block = blockchain[0]

num_of_blocks_to_add = 20


for i in range(0, num_of_blocks_to_add):
    block_to_add = next_block(previous_block)
    blockchain.append(block_to_add)
    previous_block = block_to_add

    print 'Block #{} has been added to the blockchain!'.format(block_to_add.index)
    print 'Hash: {}\n'.format(block_to_add.hash)


##### II-part

node = Flask(__name__)

this_nodes_transactions = []


@node.route('/txion', methods=['POST'])
def transaction():
    if request.method == 'POST':
        new_txion = request.get_json()
        this_nodes_transactions.append(new_txion)
        print 'New transaction'
        print 'FROM: {}'.format(new_txion['from'])
        print 'TO: {}'.format(new_txion['to'])
        print 'AMOUNT: {}\n'.format(new_txion['amount'])
        
        return 'Transaction submission successful\n'


node.run()




