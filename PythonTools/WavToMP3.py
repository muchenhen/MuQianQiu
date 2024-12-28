import os
from pydub import AudioSegment
import logging

def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(levelname)s - %(message)s'
    )

def convert_wav_to_mp3(wav_path):
    try:
        # 构造MP3文件路径
        mp3_path = os.path.splitext(wav_path)[0] + '.mp3'
        
        # 转换音频
        audio = AudioSegment.from_file(wav_path, format="wav")
        audio.export(mp3_path, format='mp3', bitrate='320k')
        
        # 删除WAV文件
        os.remove(wav_path)
        logging.info(f'已转换并删除: {wav_path}')
        return True
    except Exception as e:
        logging.error(f'转换失败 {wav_path}: {str(e)}')
        return False

def process_directory(directory):
    success_count = 0
    fail_count = 0
    
    # 遍历目录
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.lower().endswith('.wav'):
                wav_path = os.path.join(root, file)
                if convert_wav_to_mp3(wav_path):
                    success_count += 1
                else:
                    fail_count += 1
    
    return success_count, fail_count

def main():
    setup_logging()
    
    # 设置要处理的目录路径
    directory = r"E:\GitHub\MuQianQiu\GodotVersion\Audios"  # 替换为你的音频文件目录
    
    if not os.path.exists(directory):
        logging.error(f'目录不存在: {directory}')
        return
    
    logging.info(f'开始处理目录: {directory}')
    success, fail = process_directory(directory)
    logging.info(f'处理完成！成功: {success} 失败: {fail}')

if __name__ == '__main__':
    main()