import torch
import torch.nn as nn
from fastapi import FastAPI
import numpy as np
import torchvision.transforms as transforms
import cv2
import uvicorn
from fastapi.testclient import TestClient
import imageinput 
import requests
import asyncio
app=FastAPI()
client = TestClient(app)
class MyNeuralNet(nn.Module):
    def __init__(self):
        super().__init__()
        self.Matrix1 = nn.Linear(28**2,100)
        self.Matrix2 = nn.Linear(100,50)
        self.Matrix3 = nn.Linear(50,10)
        self.R = nn.ReLU()
    def forward(self,x):
        # x = x.reshape(-1,28*28)
        x = x.view(-1,28**2)
        x = self.R(self.Matrix1(x))
        x = self.R(self.Matrix2(x))
        x = self.Matrix3(x)
        return x.squeeze()
f = MyNeuralNet()
f.load_state_dict(torch.load("wt.pt", map_location=torch.device("cpu")))
f.eval()

@app.get("/predict")
def predict():
    input_image = imageinput.input_function()
    print(input_image)
    with torch.no_grad():
        output = f(torch.tensor(input_image, dtype=torch.float32))
    output = output.unsqueeze(0)
    _, class_index = torch.max(output, dim=1)
    prediction = class_index.item()
    prediction = f(input).detach().numpy()
    print("Output:", prediction)
    return("Output:", prediction)

if __name__ == '__main__':
    uvicorn.run(app,host='0.0.0.0', port=8000,debug=True)