# 必要なモジュールの読み込み
from flask import Flask, jsonify, abort, make_response, request
import os
import io
import time
import numpy as np
import cv2
import json

api = Flask(__name__)

# GET
@api.route('/get', methods=['GET'])
def get():
    return make_response(jsonify({'error': 'Not found'}), 404)


# POST
@api.route('/post', methods=['POST'])
def post():
    return make_response(jsonify({'error': 'Not found'}), 404)

# エラーハンドリング
@api.errorhandler(404)
def not_found(error):
    return make_response(jsonify({'error': 'Not found'}), 404)

if __name__ == '__main__':
    api.run(host='0.0.0.0', port=3001)