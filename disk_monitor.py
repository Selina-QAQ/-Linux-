#!/usr/bin/env python3
import os
import re

# 用正则匹配百分比，彻底规避中文/英文表头问题
cmd_result = os.popen("df -h /").read()

# 正则匹配：数字+%，提取实际数据行的使用率
match = re.search(r'(\d+)%', cmd_result)

if match:
    use_percent = int(match.group(1))
    print(f"当前根分区磁盘使用率: {use_percent}%")

    # 自定义告警阈值（比如80%，可自行修改）
    if use_percent >= 80:
        with open("/opt/disk_warning.log", "a", encoding="utf-8") as f:
            f.write(f"【警告】磁盘使用率过高！当前使用率: {use_percent}% 时间: {os.popen('date').read()}")
else:
    print("无法获取磁盘使用率，请检查命令")
