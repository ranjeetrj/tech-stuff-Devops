# import speedtest module 
import speedtest

speed_test = speedtest.Speedtest()

download_speed = speed_test.download()
print("Your Download speed is", download_speed) 

upload_speed = speed_test.upload()
print("Your Upload speed is", upload_speed)