import os
import time
import sys

def insert_string_below_target(file_path, target_string, insert_string):
    try:
        # 以只读模式打开文件，读取所有行
        with open(file_path, 'r', encoding='utf-8') as file:
            lines = file.readlines()

        new_lines = []
        for line in lines:
            if target_string in line:
                # 若找到目标字符串，在其下一行插入固定字符串
                new_lines.append(insert_string + '\n')
                continue
            new_lines.append(line)

        # 以写入模式打开文件，将修改后的内容写回
        with open(file_path, 'w', encoding='utf-8') as file:
            file.writelines(new_lines)

    except FileNotFoundError:
        print(f"文件 {file_path} 未找到，请检查文件路径。")
    except Exception as e:
        print(f"发生错误: {e}")

def get_target_platforms(file_path):
    try:
        # 以只读模式打开文件，读取所有行
        with open(file_path, 'r', encoding='utf-8') as file:
            lines = file.readlines()


        target_platforms = []
        for line in lines:
            platform = {}
            str = line.strip().split(',')
            platform['name'] = str[0]
            platform['id'] = str[1]
            platform['channel'] = str[2]
            platform['number'] = str[3]
            target_platforms.append(platform)
        return target_platforms

    except FileNotFoundError:
        print(f"文件 {file_path} 未找到，请检查文件路径。")
    except Exception as e:
        print(f"发生错误: {e}")


def change_platform(args = ''):
    workspace_path = os.getcwd()
    print(f"当前工作目录: {workspace_path}")
    platform_path = f'{workspace_path}/script/source.txt'
    pf = get_target_platforms(platform_path)


    package_output_path = f'{workspace_path}/script/output/one'
    if args == '--all':
        package_output_path = f'{workspace_path}/script/output/all'
    elif args == '--ios':
        package_output_path = f'{workspace_path}/script/output/ios'
    try:
        os.mkdir(package_output_path)
    except FileExistsError:
        print("文件夹已存在。")
    for platform in pf:
        file_path = f'{workspace_path}/lib/main.dart'
        target_string = '      channelType: ChannelType'
        id = platform['id']
        insert_string = f'{target_string}.{id},'
        insert_string_below_target(file_path, target_string, insert_string)
        #
        #
        platform_name = platform['number']
        buildPath = f'{workspace_path}/build/app/outputs/flutter-apk/app-release.apk'
        buildScript = 'flutter build apk'
        buildOutputFile = f'{package_output_path}/mbgf-{platform_name}-3.10.49.apk'
        #苹果渠道
        if id == 'iosAppStore' or args == '--ios':
            id = 'iosAppStore'
            platform_name = 'ios'
            buildScript = 'flutter build ipa'
            buildPath = f'{workspace_path}/build/ios/app-release.ipa'
            buildOutputFile = f'{package_output_path}/{platform_name}.ipa'
        os.system(f'echo "正在构建：{platform_name} 渠道包" ')
        os.system(buildScript)
        # 移动构建包
        os.rename(buildPath, buildOutputFile)
        os.system(f'echo "构建：{platform_name} 渠道包成功" ')
        if args == '--all':
            continue
        else:
            break

def main():
    # 获取命令行参数，去掉脚本名本身
    args = sys.argv[1:]
    if not args:
        change_platform()
        return

    for arg in args:
        if arg == '--all':
            change_platform(arg)
        elif arg == '--ios':
            change_platform(arg)
        else:
            print("参数错误 支持 --all 或 --ios")


if __name__ == "__main__":
    main()