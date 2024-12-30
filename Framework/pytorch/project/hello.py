import torch
import torch.nn.functional as F

# 自定义CUDA内核
def fibonacci_cuda_kernel(n, fib):
    if n < 2:
        return
    fib[0] = 0
    fib[1] = 1
    for i in range(2, n):
        fib[i] = fib[i - 1] + fib[i - 2]

def fibonacci_cuda(n):
    # 创建一个CUDA张量来存储斐波那契数列
    fib = torch.zeros(n, device='cuda')

    # 调用自定义CUDA内核
    fibonacci_cuda_kernel(n, fib)

    return fib

# 获取cuda版本
print(torch.__version__)
print(torch.cuda.is_available())
# 示例：计算前100个斐波那契数
n = 10
result = fibonacci_cuda(n)
print(result[9].cpu()) # 将结果从CUDA设备转移到CPU并打印