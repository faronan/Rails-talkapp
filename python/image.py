# coding:utf-8
import numpy as np
import cv2
from glob import glob
import os
import dlib


IMAGE_FOLDA_PATH = "python_assets"

#顔画像から顔枠、顔の個数を求める
def get_rects(image):
    detector = dlib.get_frontal_face_detector()
    rects = detector(image, 1)
    return rects

#画像のパスから顔の特徴量を求める
def get_landmarks(image_path):
    image = cv2.imread(image_path, cv2.COLOR_BGR2GRAY)
    rects = get_rects(image)
    if len(rects) != 1:
        #顔が一つじゃない時のエラーハンドリング
        return None
    rect = rects[0]
    PREDICTOR_PATH = 'shape_predictor_68_face_landmarks.dat'
    predictor = dlib.shape_predictor(os.path.join(IMAGE_FOLDA_PATH, PREDICTOR_PATH))
    landmarks = np.matrix([[p.x, p.y] for p in predictor(image, rect).parts()])
    return landmarks

#最も顔特徴量が近い画像のインデックスを求める
def get_most_similar(source, targets):
    min_index = np.argmin([np.linalg.norm(source - target) for target in targets])
    return min_index

#二つの顔特徴量同士で最も近い顔のパーツを求める
def get_similar_parts(source, target):
    source_chin = source[0:17]
    source_right_eyebrow = source[17:22]
    source_left_eyebrow = source[22:27]
    source_nose = source[27:35]
    source_right_eye = source[36:42]
    source_left_eye = source[42:48]
    source_mouth = source[48:68]
    
    target_chin = target[0:17]
    target_right_eyebrow = target[17:22]
    target_left_eyebrow = target[22:27]
    target_nose = target[27:35]
    target_right_eye = target[36:42]
    target_left_eye = target[42:48]
    target_mouth = target[48:68]
    
    parts_dict = {0:"chin",1:"right_eyebrow",2:"left_eyebrow", 3:"nose", 4:"right_eye", 5:"left_eye", 6:"mouth"}
    
    dis_chin = np.linalg.norm(source_chin - target_chin) / source_chin.shape[0]
    dis_right_eyebrow = np.linalg.norm(source_right_eyebrow - target_right_eyebrow) / source_right_eyebrow.shape[0]
    dis_left_eyebrow = np.linalg.norm(source_left_eyebrow - target_left_eyebrow) / source_left_eyebrow.shape[0]
    dis_nose = np.linalg.norm(source_nose - target_nose) / source_nose.shape[0]
    dis_right_eye = np.linalg.norm(source_right_eye - target_right_eye) / source_right_eye.shape[0]
    dis_left_eye = np.linalg.norm(source_left_eye - target_left_eye) / source_left_eye.shape[0]
    dis_mouth = np.linalg.norm(source_mouth - target_mouth) / source_mouth.shape[0]
    
    index = np.argmin([dis_chin,dis_right_eyebrow,dis_left_eyebrow,dis_nose,dis_right_eye,dis_left_eye,dis_mouth])
    
    return parts_dict[index]

def main():
    image_path_list= []
    image_path_list.extend(glob(os.path.join(IMAGE_FOLDA_PATH, '*.jpg')))
    source_path = [path for path in image_path_list if 'source' in path]
    if len(source_path) != 1:
        #ファイルの名前が不正時
        print("file name error")
    source_path = source_path[0]
    image_path_list.remove(source_path)
    source = get_landmarks(source_path)
    targets = [get_landmarks(target_path) for target_path in image_path_list]
    targets = [target for target in targets if target is not None]
    index = get_most_similar(source, targets)
    name = image_path_list[index].split("/")[1].split(".")[0]
    parts = get_similar_parts(source, targets[index])
    print("あなたが一番似ているのは{0}です、特に{1}の辺りです".format(name, parts))


if __name__ == '__main__':
    main()