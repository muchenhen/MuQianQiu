import os

audio_folder = r"E:\GitHub\MuQianQiu\Audio"

# 获取所有音频文件
audio_files = []
for root, dirs, files in os.walk(audio_folder):
    for file in files:
        if file.endswith(".WAV"):
            audio_files.append(os.path.join(root, file))

# 去掉所有文件的_fl
for file in audio_files:
    new_file = file.replace("_fl", "")
    os.rename(file, new_file)
    
print("Done!")