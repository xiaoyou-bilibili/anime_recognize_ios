## 模型转换

这里我们可以把pt模型转换为ios端模型

```bash
# yolov5 安装
git clone https://github.com/ultralytics/yolov5.git
cd yolov5
git checkout v6.2                    # (recommend)switch to v6.2 tag
pip install -r requirements.txt
# 转换代码库
git clone https://github.com/ClintRen/yolov5_convert_weight_to_coreml.git
cd yolov5_convert_weight_to_coreml
pip install coremltools==6.0         # install
pip install numpy==1.23.1 

# 转换
python convert.py --yolov5-repo /code/yolov5 --weight /code/model/best.pt --img-size 640 --quantize
# 这里会转换出3个模型
best_FP16.mlmodel  best_Int8.mlmodel  best.mlmodel
```
