import torch
import torch.nn.functional as F

def fibonacci_cuda_kernel(n, fib):
    if n < 2:
        return
    fib[0] = 0
    fib[1] = 1
    for i in range(2, n):
        fib[i] = fib[i - 1] + fib[i - 2]

def fibonacci_cuda(n):
    fib = torch.zeros(n, device='cuda')

    fibonacci_cuda_kernel(n, fib)

    return fib

print(torch.__version__)
print(torch.cuda.is_available())
n = 10
result = fibonacci_cuda(n)
print(result[9].cpu())