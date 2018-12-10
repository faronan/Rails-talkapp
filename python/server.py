# 必要なモジュールの読み込み
from flask import Flask, jsonify, abort, make_response, request
import os
import io
import time
import numpy as np
import cv2
import json
import tempfile
import requests
from image import get_landmarks, get_most_similar, get_similar_parts

api = Flask(__name__)

# GET
@api.route('/get', methods=['GET'])
def get():
    BASE_URL = "http://172.18.0.5:3000/"

    points = []
    for key in request.form.keys():
        res = requests.get(BASE_URL + request.form[key])
        # Tempfileを作成して即読み込む
        with tempfile.NamedTemporaryFile(dir='./') as fp:
            fp.write(res.content)
            fp.file.seek(0)
            image = cv2.imread(fp.name)
        points.append(get_landmarks(image))
    source = points[0]
    targets = points[1:]
    if any((target is None for target in targets)):
        return make_response(jsonify({'error': 'Not Face Image', 'index': targets.index(None)}), 200)
    index = get_most_similar(source, targets)
    parts = get_similar_parts(source, targets[index])
    return make_response(jsonify({'index': int(index), 'parts': parts}), 200)


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