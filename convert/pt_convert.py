# 引入必要的依赖
import torch.nn as nn
import torch
from core.recognize.fmobilenet import FaceMobileNet
from core.recognize.config import config as conf
import coremltools as ct

# 打开一个测试图片，并转换出对应的特征信息
data = torch.randn(1, 1, 128, 128)

print(data.shape)
# 加载我们的模型
model = FaceMobileNet(512)
model = nn.DataParallel(model, [0])
model.load_state_dict(torch.load(conf.model_path, map_location=conf.device))
model.eval()
data = data.to(conf.device)
model = model.to(conf.device)

with torch.no_grad():
    # trace我们的模型，使用输入数据和模型
    trace = torch.jit.trace(model.module, data)
    out = trace(data)
    print(out)
    # 开始转换模型
    mlmodel = ct.convert(
        trace,
        inputs=[ct.ImageType(
            name="image",
            shape=data.shape,
            scale=1 / 255.0,
            bias=[0.5, 0.5, 0.5]
        )],
        outputs=[ct.TensorType(name="feature")]
    )

    mlmodel.save("arce_face.mlmodel")
