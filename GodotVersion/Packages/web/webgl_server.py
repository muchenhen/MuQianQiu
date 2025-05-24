from flask import Flask, send_from_directory
import os

app = Flask(__name__)

# 使用绝对路径
GAME_DIR = os.path.dirname(os.path.abspath(__file__))

@app.route('/')
def serve_game():
    return send_from_directory(GAME_DIR, 'MuQianQiu.html')  # 确认你的主HTML文件名

@app.route('/<path:path>')
def serve_files(path):
    return send_from_directory(GAME_DIR, path)

if __name__ == '__main__':
    print(f"服务器运行在: http://localhost:5000")
    print(f"游戏文件目录: {GAME_DIR}")
    app.run(host='localhost', port=5000, debug=True)