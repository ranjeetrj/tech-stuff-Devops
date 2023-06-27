
import cv2
import torch
import requests
def input_function():
    img = cv2.imread("2.png")
    img = cv2.resize(img, (28, 28))
    img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img = img / 255.0
    input = torch.from_numpy(img).unsqueeze(0).float()
    return input

